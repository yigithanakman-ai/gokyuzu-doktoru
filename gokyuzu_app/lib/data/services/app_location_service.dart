import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'world_cities_service.dart';

/// GPS Konum Servisi — Gerçek zamanlı astronomik gezegen saatleri ve efemeris için
class AppLocationService {
  static const String _keyCity = 'cached_gps_location_city';
  static const String _keyCountry = 'cached_gps_location_country';
  static const String _keyLat = 'cached_gps_location_lat';
  static const String _keyLon = 'cached_gps_location_lon';
  static const String _keyTz = 'cached_gps_location_tz';

  /// Konum izni durumunu kontrol et
  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Önbelleğe alınmış son GPS konumunu getir
  static Future<CityLocation?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final city = prefs.getString(_keyCity);
      final lat = prefs.getDouble(_keyLat);
      final lon = prefs.getDouble(_keyLon);
      final tz = prefs.getDouble(_keyTz) ?? 3.0;
      final country = prefs.getString(_keyCountry) ?? 'Türkiye';

      if (city != null && lat != null && lon != null) {
        return CityLocation(
          city: city,
          country: country,
          latitude: lat,
          longitude: lon,
          timezoneOffset: tz,
        );
      }
    } catch (e) {
      debugPrint('Error getting cached location: $e');
    }
    return null;
  }

  /// Kullanıcının anlık GPS konumunu al ve en yakın şehri eşleştir
  /// [requestPermission] true ise izin yoksa kullanıcıdan sistem diyalogu ile ister
  static Future<CityLocation?> getCurrentLocation({bool requestPermission = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Konum servisi (GPS donanımı) kapalı
        return await getCachedLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return await getCachedLocation();
      }

      // Konum bilgisini al (zaman aşımı ve doğruluk ayarlı)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 6),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return await getCachedLocation();
      }

      String detectedCity = '';
      String detectedCountry = 'Türkiye';
      double detectedTimezone = 3.0;

      // 1. Yerel Android/iOS Geocoder üzerinden cihazın bulunduğu tam ilçe/şehri öğren
      try {
        final geocoding = Geocoding();
        final placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final district = place.subAdministrativeArea?.trim(); // Örn: Datça, Kadıköy, Bodrum
          final locality = place.locality?.trim(); // Örn: Datça, İstanbul, Berlin
          final state = place.administrativeArea?.trim(); // Örn: Muğla, İstanbul, Ankara
          final country = place.country?.trim();

          if (district != null && district.isNotEmpty) {
            detectedCity = district;
          } else if (locality != null && locality.isNotEmpty) {
            detectedCity = locality;
          } else if (state != null && state.isNotEmpty) {
            detectedCity = state;
          }

          if (country != null && country.isNotEmpty) {
            detectedCountry = country;
          }
        }
      } catch (e) {
        debugPrint('Geocoding reverse lookup note: $e');
      }

      // 2. Eğer Geocoder boş veya offline ise, en yakın bilinen şehri koordinat bazlı bul
      final matchedCity = findClosestCity(position.latitude, position.longitude);
      if (detectedCity.isEmpty) {
        detectedCity = matchedCity.city;
        detectedCountry = matchedCity.country;
      }
      detectedTimezone = matchedCity.timezoneOffset;

      final result = CityLocation(
        city: detectedCity,
        country: detectedCountry,
        latitude: position.latitude,
        longitude: position.longitude,
        timezoneOffset: detectedTimezone,
      );

      // Önbelleğe kaydet (Sonraki açılışlarda anında kullanılsın)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCity, result.city);
      await prefs.setString(_keyCountry, result.country);
      await prefs.setDouble(_keyLat, result.latitude);
      await prefs.setDouble(_keyLon, result.longitude);
      await prefs.setDouble(_keyTz, result.timezoneOffset);

      return result;
    } catch (e) {
      debugPrint('AppLocationService getCurrentLocation error: $e');
      return await getCachedLocation();
    }
  }

  /// Koordinatlara en yakın şehri WorldCitiesService listesinden bulur
  static CityLocation findClosestCity(double lat, double lon) {
    if (WorldCitiesService.allCities.isEmpty) {
      return const CityLocation(
        city: 'Datça',
        country: 'Türkiye',
        latitude: 36.7265,
        longitude: 27.6853,
        timezoneOffset: 3.0,
      );
    }

    CityLocation closest = WorldCitiesService.allCities.first;
    double minDistance = double.infinity;

    for (final city in WorldCitiesService.allCities) {
      // Öklid tabanlı coğrafi mesafe yaklaşımı (küçük mesafeler için son derece hızlı ve hassas)
      final dLat = (city.latitude - lat);
      final dLon = (city.longitude - lon) * cos(lat * pi / 180.0);
      final distSq = dLat * dLat + dLon * dLon;

      if (distSq < minDistance) {
        minDistance = distSq;
        closest = city;
      }
    }

    return closest;
  }
}
