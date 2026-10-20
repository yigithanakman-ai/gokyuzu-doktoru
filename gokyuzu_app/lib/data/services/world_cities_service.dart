import 'dart:convert';
import 'package:http/http.dart' as http;

typedef WorldCity = CityLocation;

class CityLocation {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double timezoneOffset; // UTC offset in hours

  const CityLocation({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
  });

  String get displayName => '$city, $country';

  Map<String, dynamic> toJson() => {
    'city': city,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'timezoneOffset': timezoneOffset,
  };

  factory CityLocation.fromJson(Map<String, dynamic> json) => CityLocation(
    city: json['city'] ?? '',
    country: json['country'] ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    timezoneOffset: (json['timezoneOffset'] as num?)?.toDouble() ?? 0.0,
  );
}

class WorldCitiesService {
  static const List<CityLocation> allCities = [
    // --- TÜRKİYE (81 İL) ---
    CityLocation(city: 'Adana', country: 'Türkiye', latitude: 37.0000, longitude: 35.3213, timezoneOffset: 3.0),
    CityLocation(city: 'Adıyaman', country: 'Türkiye', latitude: 37.7648, longitude: 38.2786, timezoneOffset: 3.0),
    CityLocation(city: 'Afyonkarahisar', country: 'Türkiye', latitude: 38.7507, longitude: 30.5567, timezoneOffset: 3.0),
    CityLocation(city: 'Ağrı', country: 'Türkiye', latitude: 39.7191, longitude: 43.0503, timezoneOffset: 3.0),
    CityLocation(city: 'Aksaray', country: 'Türkiye', latitude: 38.3687, longitude: 34.0370, timezoneOffset: 3.0),
    CityLocation(city: 'Amasya', country: 'Türkiye', latitude: 40.6534, longitude: 35.8331, timezoneOffset: 3.0),
    CityLocation(city: 'Ankara', country: 'Türkiye', latitude: 39.9334, longitude: 32.8597, timezoneOffset: 3.0),
    CityLocation(city: 'Antalya', country: 'Türkiye', latitude: 36.8969, longitude: 30.7133, timezoneOffset: 3.0),
    CityLocation(city: 'Ardahan', country: 'Türkiye', latitude: 41.1105, longitude: 42.7022, timezoneOffset: 3.0),
    CityLocation(city: 'Artvin', country: 'Türkiye', latitude: 41.1828, longitude: 41.8183, timezoneOffset: 3.0),
    CityLocation(city: 'Aydın', country: 'Türkiye', latitude: 37.8560, longitude: 27.8416, timezoneOffset: 3.0),
    CityLocation(city: 'Balıkesir', country: 'Türkiye', latitude: 39.6484, longitude: 27.8826, timezoneOffset: 3.0),
    CityLocation(city: 'Bartın', country: 'Türkiye', latitude: 41.6344, longitude: 32.3375, timezoneOffset: 3.0),
    CityLocation(city: 'Batman', country: 'Türkiye', latitude: 37.8812, longitude: 41.1294, timezoneOffset: 3.0),
    CityLocation(city: 'Bayburt', country: 'Türkiye', latitude: 40.2552, longitude: 40.2249, timezoneOffset: 3.0),
    CityLocation(city: 'Bilecik', country: 'Türkiye', latitude: 40.1451, longitude: 29.9799, timezoneOffset: 3.0),
    CityLocation(city: 'Bingöl', country: 'Türkiye', latitude: 38.8853, longitude: 40.4983, timezoneOffset: 3.0),
    CityLocation(city: 'Bitlis', country: 'Türkiye', latitude: 38.4006, longitude: 42.1095, timezoneOffset: 3.0),
    CityLocation(city: 'Bolu', country: 'Türkiye', latitude: 40.7392, longitude: 31.6089, timezoneOffset: 3.0),
    CityLocation(city: 'Burdur', country: 'Türkiye', latitude: 37.7203, longitude: 30.2908, timezoneOffset: 3.0),
    CityLocation(city: 'Bursa', country: 'Türkiye', latitude: 40.1885, longitude: 29.0610, timezoneOffset: 3.0),
    CityLocation(city: 'Çanakkale', country: 'Türkiye', latitude: 40.1553, longitude: 26.4142, timezoneOffset: 3.0),
    CityLocation(city: 'Çankırı', country: 'Türkiye', latitude: 40.6013, longitude: 33.6134, timezoneOffset: 3.0),
    CityLocation(city: 'Çorum', country: 'Türkiye', latitude: 40.5506, longitude: 34.9556, timezoneOffset: 3.0),
    CityLocation(city: 'Denizli', country: 'Türkiye', latitude: 37.7765, longitude: 29.0864, timezoneOffset: 3.0),
    CityLocation(city: 'Diyarbakır', country: 'Türkiye', latitude: 37.9144, longitude: 40.2306, timezoneOffset: 3.0),
    CityLocation(city: 'Düzce', country: 'Türkiye', latitude: 40.8438, longitude: 31.1565, timezoneOffset: 3.0),
    CityLocation(city: 'Edirne', country: 'Türkiye', latitude: 41.6771, longitude: 26.5557, timezoneOffset: 3.0),
    CityLocation(city: 'Elazığ', country: 'Türkiye', latitude: 38.6810, longitude: 39.2264, timezoneOffset: 3.0),
    CityLocation(city: 'Erzincan', country: 'Türkiye', latitude: 39.7500, longitude: 39.5000, timezoneOffset: 3.0),
    CityLocation(city: 'Erzurum', country: 'Türkiye', latitude: 39.9043, longitude: 41.2679, timezoneOffset: 3.0),
    CityLocation(city: 'Eskişehir', country: 'Türkiye', latitude: 39.7767, longitude: 30.5206, timezoneOffset: 3.0),
    CityLocation(city: 'Gaziantep', country: 'Türkiye', latitude: 37.0662, longitude: 37.3833, timezoneOffset: 3.0),
    CityLocation(city: 'Giresun', country: 'Türkiye', latitude: 40.9128, longitude: 38.3895, timezoneOffset: 3.0),
    CityLocation(city: 'Gümüşhane', country: 'Türkiye', latitude: 40.4600, longitude: 39.4814, timezoneOffset: 3.0),
    CityLocation(city: 'Hakkari', country: 'Türkiye', latitude: 37.5833, longitude: 43.7333, timezoneOffset: 3.0),
    CityLocation(city: 'Hatay', country: 'Türkiye', latitude: 36.2023, longitude: 36.1606, timezoneOffset: 3.0),
    CityLocation(city: 'Iğdır', country: 'Türkiye', latitude: 39.9196, longitude: 44.0450, timezoneOffset: 3.0),
    CityLocation(city: 'Isparta', country: 'Türkiye', latitude: 37.7648, longitude: 30.5566, timezoneOffset: 3.0),
    CityLocation(city: 'İstanbul', country: 'Türkiye', latitude: 41.0082, longitude: 28.9784, timezoneOffset: 3.0),
    CityLocation(city: 'İzmir', country: 'Türkiye', latitude: 38.4192, longitude: 27.1287, timezoneOffset: 3.0),
    CityLocation(city: 'Kahramanmaraş', country: 'Türkiye', latitude: 37.5858, longitude: 36.9371, timezoneOffset: 3.0),
    CityLocation(city: 'Karabük', country: 'Türkiye', latitude: 41.2061, longitude: 32.6204, timezoneOffset: 3.0),
    CityLocation(city: 'Karaman', country: 'Türkiye', latitude: 37.1759, longitude: 33.2287, timezoneOffset: 3.0),
    CityLocation(city: 'Kars', country: 'Türkiye', latitude: 40.6013, longitude: 43.0975, timezoneOffset: 3.0),
    CityLocation(city: 'Kastamonu', country: 'Türkiye', latitude: 41.3887, longitude: 33.7827, timezoneOffset: 3.0),
    CityLocation(city: 'Kayseri', country: 'Türkiye', latitude: 38.7205, longitude: 35.4826, timezoneOffset: 3.0),
    CityLocation(city: 'Kilis', country: 'Türkiye', latitude: 36.7184, longitude: 37.1212, timezoneOffset: 3.0),
    CityLocation(city: 'Kırıkkale', country: 'Türkiye', latitude: 39.8468, longitude: 33.5153, timezoneOffset: 3.0),
    CityLocation(city: 'Kırklareli', country: 'Türkiye', latitude: 41.7333, longitude: 27.2167, timezoneOffset: 3.0),
    CityLocation(city: 'Kırşehir', country: 'Türkiye', latitude: 39.1425, longitude: 34.1709, timezoneOffset: 3.0),
    CityLocation(city: 'Kocaeli', country: 'Türkiye', latitude: 40.8533, longitude: 29.8815, timezoneOffset: 3.0),
    CityLocation(city: 'Konya', country: 'Türkiye', latitude: 37.8667, longitude: 32.4833, timezoneOffset: 3.0),
    CityLocation(city: 'Kütahya', country: 'Türkiye', latitude: 39.4167, longitude: 29.9833, timezoneOffset: 3.0),
    CityLocation(city: 'Malatya', country: 'Türkiye', latitude: 38.3552, longitude: 38.3095, timezoneOffset: 3.0),
    CityLocation(city: 'Manisa', country: 'Türkiye', latitude: 38.6191, longitude: 27.4289, timezoneOffset: 3.0),
    CityLocation(city: 'Mardin', country: 'Türkiye', latitude: 37.3212, longitude: 40.7245, timezoneOffset: 3.0),
    CityLocation(city: 'Mersin', country: 'Türkiye', latitude: 36.8000, longitude: 34.6333, timezoneOffset: 3.0),
    CityLocation(city: 'Muğla', country: 'Türkiye', latitude: 37.2153, longitude: 28.3636, timezoneOffset: 3.0),
    CityLocation(city: 'Muş', country: 'Türkiye', latitude: 38.7432, longitude: 41.5064, timezoneOffset: 3.0),
    CityLocation(city: 'Nevşehir', country: 'Türkiye', latitude: 38.6244, longitude: 34.7144, timezoneOffset: 3.0),
    CityLocation(city: 'Niğde', country: 'Türkiye', latitude: 37.9667, longitude: 34.6833, timezoneOffset: 3.0),
    CityLocation(city: 'Ordu', country: 'Türkiye', latitude: 40.9839, longitude: 37.8764, timezoneOffset: 3.0),
    CityLocation(city: 'Osmaniye', country: 'Türkiye', latitude: 37.0742, longitude: 36.2472, timezoneOffset: 3.0),
    CityLocation(city: 'Rize', country: 'Türkiye', latitude: 41.0201, longitude: 40.5234, timezoneOffset: 3.0),
    CityLocation(city: 'Sakarya', country: 'Türkiye', latitude: 40.7569, longitude: 30.3783, timezoneOffset: 3.0),
    CityLocation(city: 'Samsun', country: 'Türkiye', latitude: 41.2928, longitude: 36.3313, timezoneOffset: 3.0),
    CityLocation(city: 'Şanlıurfa', country: 'Türkiye', latitude: 37.1674, longitude: 38.7955, timezoneOffset: 3.0),
    CityLocation(city: 'Siirt', country: 'Türkiye', latitude: 37.9333, longitude: 41.9500, timezoneOffset: 3.0),
    CityLocation(city: 'Sinop', country: 'Türkiye', latitude: 42.0231, longitude: 35.1531, timezoneOffset: 3.0),
    CityLocation(city: 'Şırnak', country: 'Türkiye', latitude: 37.5164, longitude: 42.4594, timezoneOffset: 3.0),
    CityLocation(city: 'Sivas', country: 'Türkiye', latitude: 39.7477, longitude: 37.0179, timezoneOffset: 3.0),
    CityLocation(city: 'Tekirdağ', country: 'Türkiye', latitude: 40.9833, longitude: 27.5167, timezoneOffset: 3.0),
    CityLocation(city: 'Tokat', country: 'Türkiye', latitude: 40.3167, longitude: 36.5500, timezoneOffset: 3.0),
    CityLocation(city: 'Trabzon', country: 'Türkiye', latitude: 41.0015, longitude: 39.7178, timezoneOffset: 3.0),
    CityLocation(city: 'Tunceli', country: 'Türkiye', latitude: 39.1079, longitude: 39.5401, timezoneOffset: 3.0),
    CityLocation(city: 'Uşak', country: 'Türkiye', latitude: 38.6823, longitude: 29.4082, timezoneOffset: 3.0),
    CityLocation(city: 'Van', country: 'Türkiye', latitude: 38.4891, longitude: 43.4089, timezoneOffset: 3.0),
    CityLocation(city: 'Yalova', country: 'Türkiye', latitude: 40.6500, longitude: 29.2667, timezoneOffset: 3.0),
    CityLocation(city: 'Yozgat', country: 'Türkiye', latitude: 39.8181, longitude: 34.8147, timezoneOffset: 3.0),
    CityLocation(city: 'Zonguldak', country: 'Türkiye', latitude: 41.4564, longitude: 31.7987, timezoneOffset: 3.0),
    CityLocation(city: 'Datça', country: 'Türkiye', latitude: 36.7265, longitude: 27.6853, timezoneOffset: 3.0),
    CityLocation(city: 'Bodrum', country: 'Türkiye', latitude: 37.0344, longitude: 27.4305, timezoneOffset: 3.0),
    CityLocation(city: 'Marmaris', country: 'Türkiye', latitude: 36.8550, longitude: 28.2742, timezoneOffset: 3.0),
    CityLocation(city: 'Fethiye', country: 'Türkiye', latitude: 36.6217, longitude: 29.1164, timezoneOffset: 3.0),
    CityLocation(city: 'Kaş', country: 'Türkiye', latitude: 36.2003, longitude: 29.6377, timezoneOffset: 3.0),
    CityLocation(city: 'Alanya', country: 'Türkiye', latitude: 36.5438, longitude: 31.9998, timezoneOffset: 3.0),
    CityLocation(city: 'Çeşme', country: 'Türkiye', latitude: 38.3236, longitude: 26.3044, timezoneOffset: 3.0),
    CityLocation(city: 'Kuşadası', country: 'Türkiye', latitude: 37.8579, longitude: 27.2610, timezoneOffset: 3.0),
    CityLocation(city: 'Ayvalık', country: 'Türkiye', latitude: 39.3197, longitude: 26.6969, timezoneOffset: 3.0),

    // --- AZERBAYCAN (KAPSAMLI BÖLGE VE ŞEHİRLER) ---
    CityLocation(city: 'Yevlax (Yevlakh)', country: 'Azerbaycan', latitude: 40.6172, longitude: 47.1500, timezoneOffset: 4.0),
    CityLocation(city: 'Yevlakh', country: 'Azerbaycan', latitude: 40.6172, longitude: 47.1500, timezoneOffset: 4.0),
    CityLocation(city: 'Bakü (Baku)', country: 'Azerbaycan', latitude: 40.4093, longitude: 49.8671, timezoneOffset: 4.0),
    CityLocation(city: 'Gence (Ganja)', country: 'Azerbaycan', latitude: 40.6828, longitude: 46.3606, timezoneOffset: 4.0),
    CityLocation(city: 'Sumqayıt (Sumgait)', country: 'Azerbaycan', latitude: 40.5897, longitude: 49.6686, timezoneOffset: 4.0),
    CityLocation(city: 'Mingəçevir (Mingachevir)', country: 'Azerbaycan', latitude: 40.7640, longitude: 47.0595, timezoneOffset: 4.0),
    CityLocation(city: 'Naxçıvan (Nakhchivan)', country: 'Azerbaycan', latitude: 39.2089, longitude: 45.4122, timezoneOffset: 4.0),
    CityLocation(city: 'Lənkəran (Lankaran)', country: 'Azerbaycan', latitude: 38.7543, longitude: 48.8506, timezoneOffset: 4.0),
    CityLocation(city: 'Şəki (Sheki)', country: 'Azerbaycan', latitude: 41.1919, longitude: 47.1706, timezoneOffset: 4.0),
    CityLocation(city: 'Şirvan (Shirvan)', country: 'Azerbaycan', latitude: 39.9378, longitude: 48.9290, timezoneOffset: 4.0),
    CityLocation(city: 'Xırdalan (Khirdalan)', country: 'Azerbaycan', latitude: 40.4481, longitude: 49.7550, timezoneOffset: 4.0),
    CityLocation(city: 'Şuşa (Shusha)', country: 'Azerbaycan', latitude: 39.7537, longitude: 46.7465, timezoneOffset: 4.0),
    CityLocation(city: 'Xankəndi (Khankendi)', country: 'Azerbaycan', latitude: 39.8177, longitude: 46.7528, timezoneOffset: 4.0),
    CityLocation(city: 'Quba (Guba)', country: 'Azerbaycan', latitude: 41.3643, longitude: 48.5134, timezoneOffset: 4.0),
    CityLocation(city: 'Qusar (Gusar)', country: 'Azerbaycan', latitude: 41.4275, longitude: 48.4302, timezoneOffset: 4.0),
    CityLocation(city: 'Zaqatala', country: 'Azerbaycan', latitude: 41.6336, longitude: 46.6433, timezoneOffset: 4.0),
    CityLocation(city: 'Qəbələ (Gabala)', country: 'Azerbaycan', latitude: 40.9982, longitude: 47.8499, timezoneOffset: 4.0),
    CityLocation(city: 'Bərdə (Barda)', country: 'Azerbaycan', latitude: 40.3758, longitude: 47.1261, timezoneOffset: 4.0),
    CityLocation(city: 'Sabirabad', country: 'Azerbaycan', latitude: 40.0089, longitude: 48.4770, timezoneOffset: 4.0),
    CityLocation(city: 'Xaçmaz (Khachmaz)', country: 'Azerbaycan', latitude: 41.4639, longitude: 48.8061, timezoneOffset: 4.0),
    CityLocation(city: 'Tovuz', country: 'Azerbaycan', latitude: 40.9922, longitude: 45.6289, timezoneOffset: 4.0),
    CityLocation(city: 'Qazax (Gazakh)', country: 'Azerbaycan', latitude: 41.0925, longitude: 45.3656, timezoneOffset: 4.0),
    CityLocation(city: 'İmişli (Imishli)', country: 'Azerbaycan', latitude: 39.8708, longitude: 48.0600, timezoneOffset: 4.0),
    CityLocation(city: 'Cəlilabad (Jalilabad)', country: 'Azerbaycan', latitude: 39.2072, longitude: 48.4917, timezoneOffset: 4.0),
    CityLocation(city: 'Masallı (Masally)', country: 'Azerbaycan', latitude: 39.0342, longitude: 48.6653, timezoneOffset: 4.0),
    CityLocation(city: 'Salyan', country: 'Azerbaycan', latitude: 39.5961, longitude: 48.9792, timezoneOffset: 4.0),
    CityLocation(city: 'Ağdam (Aghdam)', country: 'Azerbaycan', latitude: 39.9911, longitude: 46.9297, timezoneOffset: 4.0),
    CityLocation(city: 'Ağdaş (Agdash)', country: 'Azerbaycan', latitude: 40.6481, longitude: 47.4744, timezoneOffset: 4.0),
    CityLocation(city: 'Göyçay (Goychay)', country: 'Azerbaycan', latitude: 40.6533, longitude: 47.7406, timezoneOffset: 4.0),
    CityLocation(city: 'Şamaxı (Shamakhi)', country: 'Azerbaycan', latitude: 40.6319, longitude: 48.6414, timezoneOffset: 4.0),

    // --- KAZAKİSTAN ---
    CityLocation(city: 'Almatı (Almaty)', country: 'Kazakistan', latitude: 43.2220, longitude: 76.8512, timezoneOffset: 5.0),
    CityLocation(city: 'Astana (Nur-Sultan)', country: 'Kazakistan', latitude: 51.1694, longitude: 71.4491, timezoneOffset: 5.0),
    CityLocation(city: 'Şımkent (Shymkent)', country: 'Kazakistan', latitude: 42.3417, longitude: 69.5901, timezoneOffset: 5.0),
    CityLocation(city: 'Aktobe (Aqtobe)', country: 'Kazakistan', latitude: 50.2839, longitude: 57.1670, timezoneOffset: 5.0),
    CityLocation(city: 'Karagandı (Karaganda)', country: 'Kazakistan', latitude: 49.8019, longitude: 73.1021, timezoneOffset: 5.0),
    CityLocation(city: 'Taraz', country: 'Kazakistan', latitude: 42.9000, longitude: 71.3667, timezoneOffset: 5.0),
    CityLocation(city: 'Pavlodar', country: 'Kazakistan', latitude: 52.2873, longitude: 76.9674, timezoneOffset: 5.0),
    CityLocation(city: 'Öskemen (Ust-Kamenogorsk)', country: 'Kazakistan', latitude: 49.9535, longitude: 82.6095, timezoneOffset: 5.0),
    CityLocation(city: 'Semey (Semipalatinsk)', country: 'Kazakistan', latitude: 50.4111, longitude: 80.2275, timezoneOffset: 5.0),
    CityLocation(city: 'Atırau (Atyrau)', country: 'Kazakistan', latitude: 47.1167, longitude: 51.8833, timezoneOffset: 5.0),
    CityLocation(city: 'Kostanay', country: 'Kazakistan', latitude: 53.2198, longitude: 63.6354, timezoneOffset: 5.0),
    CityLocation(city: 'Kızılorda (Kyzylorda)', country: 'Kazakistan', latitude: 44.8528, longitude: 65.5092, timezoneOffset: 5.0),
    CityLocation(city: 'Oral (Uralsk)', country: 'Kazakistan', latitude: 51.2222, longitude: 51.3703, timezoneOffset: 5.0),
    CityLocation(city: 'Aktau (Aqtau)', country: 'Kazakistan', latitude: 43.6500, longitude: 51.1667, timezoneOffset: 5.0),
    CityLocation(city: 'Ekibastuz', country: 'Kazakistan', latitude: 51.7236, longitude: 75.3228, timezoneOffset: 5.0),
    CityLocation(city: 'Temirtau', country: 'Kazakistan', latitude: 50.0544, longitude: 72.9575, timezoneOffset: 5.0),

    // --- ÖZBEKİSTAN, TÜRKMENİSTAN, KIRGIZİSTAN, TACİKİSTAN ---
    CityLocation(city: 'Taşkent (Tashkent)', country: 'Özbekistan', latitude: 41.2995, longitude: 69.2401, timezoneOffset: 5.0),
    CityLocation(city: 'Semerkant (Samarkand)', country: 'Özbekistan', latitude: 39.6270, longitude: 66.9750, timezoneOffset: 5.0),
    CityLocation(city: 'Buhara (Bukhara)', country: 'Özbekistan', latitude: 39.7681, longitude: 64.4556, timezoneOffset: 5.0),
    CityLocation(city: 'Namangan', country: 'Özbekistan', latitude: 40.9983, longitude: 71.6726, timezoneOffset: 5.0),
    CityLocation(city: 'Andican (Andijan)', country: 'Özbekistan', latitude: 40.7821, longitude: 72.3442, timezoneOffset: 5.0),
    CityLocation(city: 'Hive (Khiva)', country: 'Özbekistan', latitude: 41.3783, longitude: 60.3639, timezoneOffset: 5.0),
    CityLocation(city: 'Aşkabat (Ashgabat)', country: 'Türkmenistan', latitude: 37.9601, longitude: 58.3261, timezoneOffset: 5.0),
    CityLocation(city: 'Türkmenabat', country: 'Türkmenistan', latitude: 39.0733, longitude: 63.5786, timezoneOffset: 5.0),
    CityLocation(city: 'Bişkek (Bishkek)', country: 'Kırgızistan', latitude: 42.8746, longitude: 74.5698, timezoneOffset: 6.0),
    CityLocation(city: 'Oş (Osh)', country: 'Kırgızistan', latitude: 40.5140, longitude: 72.8161, timezoneOffset: 6.0),
    CityLocation(city: 'Duşanbe (Dushanbe)', country: 'Tacikistan', latitude: 38.5598, longitude: 68.7870, timezoneOffset: 5.0),

    // --- RUSYA FEDERASYONU (TÜM ZAMAN DİLİMLERİ & BAŞLICA MERKEZLER) ---
    CityLocation(city: 'Moskova (Moscow)', country: 'Rusya', latitude: 55.7558, longitude: 37.6173, timezoneOffset: 3.0),
    CityLocation(city: 'St. Petersburg', country: 'Rusya', latitude: 59.9343, longitude: 30.3351, timezoneOffset: 3.0),
    CityLocation(city: 'Novosibirsk', country: 'Rusya', latitude: 55.0084, longitude: 82.9357, timezoneOffset: 7.0),
    CityLocation(city: 'Yekaterinburg', country: 'Rusya', latitude: 56.8389, longitude: 60.6057, timezoneOffset: 5.0),
    CityLocation(city: 'Kazan', country: 'Rusya', latitude: 55.8304, longitude: 49.0661, timezoneOffset: 3.0),
    CityLocation(city: 'Nijniy Novgorod', country: 'Rusya', latitude: 56.3269, longitude: 44.0059, timezoneOffset: 3.0),
    CityLocation(city: 'Çelyabinsk (Chelyabinsk)', country: 'Rusya', latitude: 55.1644, longitude: 61.4368, timezoneOffset: 5.0),
    CityLocation(city: 'Samara', country: 'Rusya', latitude: 53.1959, longitude: 50.1002, timezoneOffset: 4.0),
    CityLocation(city: 'Omsk', country: 'Rusya', latitude: 54.9885, longitude: 73.3242, timezoneOffset: 6.0),
    CityLocation(city: 'Rostov-na-Donu', country: 'Rusya', latitude: 47.2357, longitude: 39.7015, timezoneOffset: 3.0),
    CityLocation(city: 'Ufa', country: 'Rusya', latitude: 54.7388, longitude: 55.9721, timezoneOffset: 5.0),
    CityLocation(city: 'Krasnoyarsk', country: 'Rusya', latitude: 56.0153, longitude: 92.8932, timezoneOffset: 7.0),
    CityLocation(city: 'Voronej (Voronezh)', country: 'Rusya', latitude: 51.6755, longitude: 39.2089, timezoneOffset: 3.0),
    CityLocation(city: 'Perm', country: 'Rusya', latitude: 58.0105, longitude: 56.2502, timezoneOffset: 5.0),
    CityLocation(city: 'Volgograd', country: 'Rusya', latitude: 48.7080, longitude: 44.5133, timezoneOffset: 3.0),
    CityLocation(city: 'Krasnodar', country: 'Rusya', latitude: 45.0393, longitude: 38.9872, timezoneOffset: 3.0),
    CityLocation(city: 'Saratov', country: 'Rusya', latitude: 51.5406, longitude: 46.0086, timezoneOffset: 4.0),
    CityLocation(city: 'Tyumen', country: 'Rusya', latitude: 57.1530, longitude: 65.5343, timezoneOffset: 5.0),
    CityLocation(city: 'Barnaul', country: 'Rusya', latitude: 53.3606, longitude: 83.7636, timezoneOffset: 7.0),
    CityLocation(city: 'İrkutsk (Irkutsk)', country: 'Rusya', latitude: 52.2870, longitude: 104.3050, timezoneOffset: 8.0),
    CityLocation(city: 'Habarovsk (Khabarovsk)', country: 'Rusya', latitude: 48.4827, longitude: 135.0838, timezoneOffset: 10.0),
    CityLocation(city: 'Vladivostok', country: 'Rusya', latitude: 43.1155, longitude: 131.8855, timezoneOffset: 10.0),
    CityLocation(city: 'Soçi (Sochi)', country: 'Rusya', latitude: 43.6028, longitude: 39.7342, timezoneOffset: 3.0),
    CityLocation(city: 'Mahaçkale (Makhachkala)', country: 'Rusya', latitude: 42.9849, longitude: 47.5047, timezoneOffset: 3.0),
    CityLocation(city: 'Grozni (Grozny)', country: 'Rusya', latitude: 43.3183, longitude: 45.6986, timezoneOffset: 3.0),
    CityLocation(city: 'Kaliningrad', country: 'Rusya', latitude: 54.7104, longitude: 20.4522, timezoneOffset: 2.0),

    // --- ÇİN HALK CUMHURİYETİ, HONG KONG, TAYVAN ---
    CityLocation(city: 'Pekin (Beijing)', country: 'Çin', latitude: 39.9042, longitude: 116.4074, timezoneOffset: 8.0),
    CityLocation(city: 'Şanghay (Shanghai)', country: 'Çin', latitude: 31.2304, longitude: 121.4737, timezoneOffset: 8.0),
    CityLocation(city: 'Guangzhou', country: 'Çin', latitude: 23.1291, longitude: 113.2644, timezoneOffset: 8.0),
    CityLocation(city: 'Shenzhen', country: 'Çin', latitude: 22.5431, longitude: 114.0579, timezoneOffset: 8.0),
    CityLocation(city: 'Chengdu', country: 'Çin', latitude: 30.5728, longitude: 104.0668, timezoneOffset: 8.0),
    CityLocation(city: 'Wuhan', country: 'Çin', latitude: 30.5928, longitude: 114.3055, timezoneOffset: 8.0),
    CityLocation(city: "Xi'an", country: 'Çin', latitude: 34.3416, longitude: 108.9398, timezoneOffset: 8.0),
    CityLocation(city: 'Hangzhou', country: 'Çin', latitude: 30.2741, longitude: 120.1551, timezoneOffset: 8.0),
    CityLocation(city: 'Chongqing', country: 'Çin', latitude: 29.5630, longitude: 106.5516, timezoneOffset: 8.0),
    CityLocation(city: 'Nanjing', country: 'Çin', latitude: 32.0603, longitude: 118.7969, timezoneOffset: 8.0),
    CityLocation(city: 'Tianjin', country: 'Çin', latitude: 39.3434, longitude: 117.3616, timezoneOffset: 8.0),
    CityLocation(city: 'Urumçi (Urumqi)', country: 'Çin', latitude: 43.8256, longitude: 87.6168, timezoneOffset: 8.0),
    CityLocation(city: 'Kaşgar (Kashgar)', country: 'Çin', latitude: 39.4677, longitude: 75.9898, timezoneOffset: 8.0),
    CityLocation(city: 'Hong Kong', country: 'Çin', latitude: 22.3193, longitude: 114.1694, timezoneOffset: 8.0),
    CityLocation(city: 'Taipei', country: 'Tayvan', latitude: 25.0330, longitude: 121.5654, timezoneOffset: 8.0),

    // --- ABD (UNITED STATES - TÜM BÖLGELER & EYALETLER) ---
    CityLocation(city: 'New York (NY)', country: 'ABD', latitude: 40.7128, longitude: -74.0060, timezoneOffset: -5.0),
    CityLocation(city: 'Los Angeles (CA)', country: 'ABD', latitude: 34.0522, longitude: -118.2437, timezoneOffset: -8.0),
    CityLocation(city: 'Chicago (IL)', country: 'ABD', latitude: 41.8781, longitude: -87.6298, timezoneOffset: -6.0),
    CityLocation(city: 'Houston (TX)', country: 'ABD', latitude: 29.7604, longitude: -95.3698, timezoneOffset: -6.0),
    CityLocation(city: 'Phoenix (AZ)', country: 'ABD', latitude: 33.4484, longitude: -112.0740, timezoneOffset: -7.0),
    CityLocation(city: 'Philadelphia (PA)', country: 'ABD', latitude: 39.9526, longitude: -75.1652, timezoneOffset: -5.0),
    CityLocation(city: 'San Antonio (TX)', country: 'ABD', latitude: 29.4241, longitude: -98.4936, timezoneOffset: -6.0),
    CityLocation(city: 'San Diego (CA)', country: 'ABD', latitude: 32.7157, longitude: -117.1611, timezoneOffset: -8.0),
    CityLocation(city: 'Dallas (TX)', country: 'ABD', latitude: 32.7767, longitude: -96.7970, timezoneOffset: -6.0),
    CityLocation(city: 'San Jose (CA)', country: 'ABD', latitude: 37.3382, longitude: -121.8863, timezoneOffset: -8.0),
    CityLocation(city: 'Austin (TX)', country: 'ABD', latitude: 30.2672, longitude: -97.7431, timezoneOffset: -6.0),
    CityLocation(city: 'San Francisco (CA)', country: 'ABD', latitude: 37.7749, longitude: -122.4194, timezoneOffset: -8.0),
    CityLocation(city: 'Seattle (WA)', country: 'ABD', latitude: 47.6062, longitude: -122.3321, timezoneOffset: -8.0),
    CityLocation(city: 'Denver (CO)', country: 'ABD', latitude: 39.7392, longitude: -104.9903, timezoneOffset: -7.0),
    CityLocation(city: 'Washington D.C.', country: 'ABD', latitude: 38.9072, longitude: -77.0369, timezoneOffset: -5.0),
    CityLocation(city: 'Boston (MA)', country: 'ABD', latitude: 42.3601, longitude: -71.0589, timezoneOffset: -5.0),
    CityLocation(city: 'Las Vegas (NV)', country: 'ABD', latitude: 36.1699, longitude: -115.1398, timezoneOffset: -8.0),
    CityLocation(city: 'Miami (FL)', country: 'ABD', latitude: 25.7617, longitude: -80.1918, timezoneOffset: -5.0),
    CityLocation(city: 'Orlando (FL)', country: 'ABD', latitude: 28.5383, longitude: -81.3792, timezoneOffset: -5.0),
    CityLocation(city: 'Atlanta (GA)', country: 'ABD', latitude: 33.7490, longitude: -84.3880, timezoneOffset: -5.0),
    CityLocation(city: 'Detroit (MI)', country: 'ABD', latitude: 42.3314, longitude: -83.0458, timezoneOffset: -5.0),
    CityLocation(city: 'Minneapolis (MN)', country: 'ABD', latitude: 44.9778, longitude: -93.2650, timezoneOffset: -6.0),
    CityLocation(city: 'Richmond (VA)', country: 'ABD', latitude: 37.5407, longitude: -77.4360, timezoneOffset: -5.0),
    CityLocation(city: 'Virginia Beach (VA)', country: 'ABD', latitude: 36.8529, longitude: -75.9780, timezoneOffset: -5.0),
    CityLocation(city: 'Charlotte (NC)', country: 'ABD', latitude: 35.2271, longitude: -80.8431, timezoneOffset: -5.0),
    CityLocation(city: 'Nashville (TN)', country: 'ABD', latitude: 36.1627, longitude: -86.7816, timezoneOffset: -6.0),
    CityLocation(city: 'New Orleans (LA)', country: 'ABD', latitude: 29.9511, longitude: -90.0715, timezoneOffset: -6.0),
    CityLocation(city: 'Honolulu (HI)', country: 'ABD', latitude: 21.3069, longitude: -157.8583, timezoneOffset: -10.0),
    CityLocation(city: 'Anchorage (AK)', country: 'ABD', latitude: 61.2181, longitude: -149.9003, timezoneOffset: -9.0),
    CityLocation(city: 'Portland (OR)', country: 'ABD', latitude: 45.5152, longitude: -122.6784, timezoneOffset: -8.0),
    CityLocation(city: 'Salt Lake City (UT)', country: 'ABD', latitude: 40.7608, longitude: -111.8910, timezoneOffset: -7.0),
    CityLocation(city: 'Kansas City (MO)', country: 'ABD', latitude: 39.0997, longitude: -94.5786, timezoneOffset: -6.0),
    CityLocation(city: 'Cleveland (OH)', country: 'ABD', latitude: 41.4993, longitude: -81.6944, timezoneOffset: -5.0),
    CityLocation(city: 'Columbus (OH)', country: 'ABD', latitude: 39.9612, longitude: -82.9988, timezoneOffset: -5.0),
    CityLocation(city: 'Indianapolis (IN)', country: 'ABD', latitude: 39.7684, longitude: -86.1581, timezoneOffset: -5.0),
    CityLocation(city: 'Milwaukee (WI)', country: 'ABD', latitude: 43.0389, longitude: -87.9065, timezoneOffset: -6.0),
    CityLocation(city: 'Pittsburgh (PA)', country: 'ABD', latitude: 40.4406, longitude: -79.9959, timezoneOffset: -5.0),
    CityLocation(city: 'Baltimore (MD)', country: 'ABD', latitude: 39.2904, longitude: -76.6122, timezoneOffset: -5.0),
    CityLocation(city: 'Tampa (FL)', country: 'ABD', latitude: 27.9506, longitude: -82.4572, timezoneOffset: -5.0),

    // --- AVRUPA (TÜM BAŞKENTLER VE METROPOLLER) ---
    CityLocation(city: 'Londra (London)', country: 'İngiltere', latitude: 51.5074, longitude: -0.1278, timezoneOffset: 0.0),
    CityLocation(city: 'Manchester', country: 'İngiltere', latitude: 53.4808, longitude: -2.2426, timezoneOffset: 0.0),
    CityLocation(city: 'Birmingham', country: 'İngiltere', latitude: 52.4862, longitude: -1.8904, timezoneOffset: 0.0),
    CityLocation(city: 'Edinburgh', country: 'İskoçya', latitude: 55.9533, longitude: -3.1883, timezoneOffset: 0.0),
    CityLocation(city: 'Paris', country: 'Fransa', latitude: 48.8566, longitude: 2.3522, timezoneOffset: 1.0),
    CityLocation(city: 'Marsilya (Marseille)', country: 'Fransa', latitude: 43.2965, longitude: 5.3698, timezoneOffset: 1.0),
    CityLocation(city: 'Lyon', country: 'Fransa', latitude: 45.7640, longitude: 4.8357, timezoneOffset: 1.0),
    CityLocation(city: 'Nice', country: 'Fransa', latitude: 43.7102, longitude: 7.2620, timezoneOffset: 1.0),
    CityLocation(city: 'Berlin', country: 'Almanya', latitude: 52.5200, longitude: 13.4050, timezoneOffset: 1.0),
    CityLocation(city: 'Münih (Munich)', country: 'Almanya', latitude: 48.1351, longitude: 11.5820, timezoneOffset: 1.0),
    CityLocation(city: 'Frankfurt', country: 'Almanya', latitude: 50.1109, longitude: 8.6821, timezoneOffset: 1.0),
    CityLocation(city: 'Hamburg', country: 'Almanya', latitude: 53.5511, longitude: 9.9937, timezoneOffset: 1.0),
    CityLocation(city: 'Köln (Cologne)', country: 'Almanya', latitude: 50.9375, longitude: 6.9603, timezoneOffset: 1.0),
    CityLocation(city: 'Stuttgart', country: 'Almanya', latitude: 48.7758, longitude: 9.1829, timezoneOffset: 1.0),
    CityLocation(city: 'Düsseldorf', country: 'Almanya', latitude: 51.2277, longitude: 6.7735, timezoneOffset: 1.0),
    CityLocation(city: 'Roma (Rome)', country: 'İtalya', latitude: 41.9028, longitude: 12.4964, timezoneOffset: 1.0),
    CityLocation(city: 'Milano (Milan)', country: 'İtalya', latitude: 45.4642, longitude: 9.1900, timezoneOffset: 1.0),
    CityLocation(city: 'Napoli (Naples)', country: 'İtalya', latitude: 40.8518, longitude: 14.2681, timezoneOffset: 1.0),
    CityLocation(city: 'Floransa (Florence)', country: 'İtalya', latitude: 43.7696, longitude: 11.2558, timezoneOffset: 1.0),
    CityLocation(city: 'Venedik (Venice)', country: 'İtalya', latitude: 45.4408, longitude: 12.3155, timezoneOffset: 1.0),
    CityLocation(city: 'Madrid', country: 'İspanya', latitude: 40.4168, longitude: -3.7038, timezoneOffset: 1.0),
    CityLocation(city: 'Barselona (Barcelona)', country: 'İspanya', latitude: 41.3879, longitude: 2.1699, timezoneOffset: 1.0),
    CityLocation(city: 'Valensiya (Valencia)', country: 'İspanya', latitude: 39.4699, longitude: -0.3763, timezoneOffset: 1.0),
    CityLocation(city: 'Sevilla', country: 'İspanya', latitude: 37.3891, longitude: -5.9845, timezoneOffset: 1.0),
    CityLocation(city: 'Lizbon (Lisbon)', country: 'Portekiz', latitude: 38.7223, longitude: -9.1393, timezoneOffset: 0.0),
    CityLocation(city: 'Porto', country: 'Portekiz', latitude: 41.1579, longitude: -8.6291, timezoneOffset: 0.0),
    CityLocation(city: 'Amsterdam', country: 'Hollanda', latitude: 52.3676, longitude: 4.9041, timezoneOffset: 1.0),
    CityLocation(city: 'Rotterdam', country: 'Hollanda', latitude: 51.9244, longitude: 4.4777, timezoneOffset: 1.0),
    CityLocation(city: 'Brüksel (Brussels)', country: 'Belçika', latitude: 50.8503, longitude: 4.3517, timezoneOffset: 1.0),
    CityLocation(city: 'Zürih (Zurich)', country: 'İsviçre', latitude: 47.3769, longitude: 8.5417, timezoneOffset: 1.0),
    CityLocation(city: 'Cenevre (Geneva)', country: 'İsviçre', latitude: 46.2044, longitude: 6.1432, timezoneOffset: 1.0),
    CityLocation(city: 'Viyana (Vienna)', country: 'Avusturya', latitude: 48.2082, longitude: 16.3738, timezoneOffset: 1.0),
    CityLocation(city: 'Stockholm', country: 'İsveç', latitude: 59.3293, longitude: 18.0686, timezoneOffset: 1.0),
    CityLocation(city: 'Oslo', country: 'Norveç', latitude: 59.9139, longitude: 10.7522, timezoneOffset: 1.0),
    CityLocation(city: 'Kopenhag (Copenhagen)', country: 'Danimarka', latitude: 55.6761, longitude: 12.5683, timezoneOffset: 1.0),
    CityLocation(city: 'Helsinki', country: 'Finlandiya', latitude: 60.1699, longitude: 24.9384, timezoneOffset: 2.0),
    CityLocation(city: 'Dublin', country: 'İrlanda', latitude: 53.3498, longitude: -6.2603, timezoneOffset: 0.0),
    CityLocation(city: 'Atina (Athens)', country: 'Yunanistan', latitude: 37.9838, longitude: 23.7275, timezoneOffset: 2.0),
    CityLocation(city: 'Selanik (Thessaloniki)', country: 'Yunanistan', latitude: 40.6401, longitude: 22.9444, timezoneOffset: 2.0),
    CityLocation(city: 'Lefkoşa (Nicosia)', country: 'KKTC', latitude: 35.1856, longitude: 33.3823, timezoneOffset: 3.0),
    CityLocation(city: 'Girne (Kyrenia)', country: 'KKTC', latitude: 35.3364, longitude: 33.3182, timezoneOffset: 3.0),
    CityLocation(city: 'Varşova (Warsaw)', country: 'Polonya', latitude: 52.2297, longitude: 21.0122, timezoneOffset: 1.0),
    CityLocation(city: 'Krakow', country: 'Polonya', latitude: 50.0647, longitude: 19.9450, timezoneOffset: 1.0),
    CityLocation(city: 'Prag (Prague)', country: 'Çekya', latitude: 50.0755, longitude: 14.4378, timezoneOffset: 1.0),
    CityLocation(city: 'Budapeşte (Budapest)', country: 'Macaristan', latitude: 47.4979, longitude: 19.0402, timezoneOffset: 1.0),
    CityLocation(city: 'Bükreş (Bucharest)', country: 'Romanya', latitude: 44.4268, longitude: 26.1025, timezoneOffset: 2.0),
    CityLocation(city: 'Sofya (Sofia)', country: 'Bulgaristan', latitude: 42.6977, longitude: 23.3219, timezoneOffset: 2.0),
    CityLocation(city: 'Filibe (Plovdiv)', country: 'Bulgaristan', latitude: 42.1354, longitude: 24.7453, timezoneOffset: 2.0),
    CityLocation(city: 'Belgrad (Belgrade)', country: 'Sırbistan', latitude: 44.7866, longitude: 20.4489, timezoneOffset: 1.0),
    CityLocation(city: 'Zagreb', country: 'Hırvatistan', latitude: 45.8150, longitude: 15.9819, timezoneOffset: 1.0),
    CityLocation(city: 'Saraybosna (Sarajevo)', country: 'Bosna-Hersek', latitude: 43.8563, longitude: 18.4131, timezoneOffset: 1.0),
    CityLocation(city: 'Üsküp (Skopje)', country: 'Kuzey Makedonya', latitude: 41.9981, longitude: 21.4254, timezoneOffset: 1.0),
    CityLocation(city: 'Tiran (Tirana)', country: 'Arnavutluk', latitude: 41.3275, longitude: 19.8187, timezoneOffset: 1.0),
    CityLocation(city: 'Priştine (Pristina)', country: 'Kosova', latitude: 42.6629, longitude: 21.1655, timezoneOffset: 1.0),
    CityLocation(city: 'Kiev (Kyiv)', country: 'Ukrayna', latitude: 50.4501, longitude: 30.5234, timezoneOffset: 2.0),
    CityLocation(city: 'Odessa', country: 'Ukrayna', latitude: 46.4825, longitude: 30.7233, timezoneOffset: 2.0),
    CityLocation(city: 'Lviv', country: 'Ukrayna', latitude: 49.8397, longitude: 24.0297, timezoneOffset: 2.0),
    CityLocation(city: 'Minsk', country: 'Belarus', latitude: 53.9006, longitude: 27.5590, timezoneOffset: 3.0),

    // --- ASYA & OKYANUSYA ---
    CityLocation(city: 'Tokyo', country: 'Japonya', latitude: 35.6762, longitude: 139.6503, timezoneOffset: 9.0),
    CityLocation(city: 'Osaka', country: 'Japonya', latitude: 34.6937, longitude: 135.5023, timezoneOffset: 9.0),
    CityLocation(city: 'Kyoto', country: 'Japonya', latitude: 35.0116, longitude: 135.7681, timezoneOffset: 9.0),
    CityLocation(city: 'Seul (Seoul)', country: 'Güney Kore', latitude: 37.5665, longitude: 126.9780, timezoneOffset: 9.0),
    CityLocation(city: 'Busan', country: 'Güney Kore', latitude: 35.1796, longitude: 129.0756, timezoneOffset: 9.0),
    CityLocation(city: 'Mumbai', country: 'Hindistan', latitude: 19.0760, longitude: 72.8777, timezoneOffset: 5.5),
    CityLocation(city: 'Yeni Delhi (New Delhi)', country: 'Hindistan', latitude: 28.6139, longitude: 77.2090, timezoneOffset: 5.5),
    CityLocation(city: 'Bangalore', country: 'Hindistan', latitude: 12.9716, longitude: 77.5946, timezoneOffset: 5.5),
    CityLocation(city: 'Karaçi (Karachi)', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011, timezoneOffset: 5.0),
    CityLocation(city: 'Lahor (Lahore)', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587, timezoneOffset: 5.0),
    CityLocation(city: 'İslamabad (Islamabad)', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479, timezoneOffset: 5.0),
    CityLocation(city: 'Dakka (Dhaka)', country: 'Bangladeş', latitude: 23.8103, longitude: 90.4125, timezoneOffset: 6.0),
    CityLocation(city: 'Cakarta (Jakarta)', country: 'Endonezya', latitude: -6.2088, longitude: 106.8456, timezoneOffset: 7.0),
    CityLocation(city: 'Bali (Denpasar)', country: 'Endonezya', latitude: -8.6705, longitude: 115.2126, timezoneOffset: 8.0),
    CityLocation(city: 'Kuala Lumpur', country: 'Malezya', latitude: 3.1390, longitude: 101.6869, timezoneOffset: 8.0),
    CityLocation(city: 'Manila', country: 'Filipinler', latitude: 14.5995, longitude: 120.9842, timezoneOffset: 8.0),
    CityLocation(city: 'Singapur (Singapore)', country: 'Singapur', latitude: 1.3521, longitude: 103.8198, timezoneOffset: 8.0),
    CityLocation(city: 'Bangkok', country: 'Tayland', latitude: 13.7563, longitude: 100.5018, timezoneOffset: 7.0),
    CityLocation(city: 'Hanoi', country: 'Vietnam', latitude: 21.0285, longitude: 105.8542, timezoneOffset: 7.0),
    CityLocation(city: 'Ho Chi Minh Kenti', country: 'Vietnam', latitude: 10.8231, longitude: 106.6297, timezoneOffset: 7.0),
    CityLocation(city: 'Sidney (Sydney)', country: 'Avustralya', latitude: -33.8688, longitude: 151.2093, timezoneOffset: 10.0),
    CityLocation(city: 'Melbourne', country: 'Avustralya', latitude: -37.8136, longitude: 144.9631, timezoneOffset: 10.0),
    CityLocation(city: 'Brisbane', country: 'Avustralya', latitude: -27.4698, longitude: 153.0251, timezoneOffset: 10.0),
    CityLocation(city: 'Perth', country: 'Avustralya', latitude: -31.9505, longitude: 115.8605, timezoneOffset: 8.0),
    CityLocation(city: 'Auckland', country: 'Yeni Zelanda', latitude: -36.8485, longitude: 174.7633, timezoneOffset: 12.0),

    // --- ORTA DOĞU & KAFKASYA ---
    CityLocation(city: 'Tahran (Tehran)', country: 'İran', latitude: 35.6892, longitude: 51.3890, timezoneOffset: 3.5),
    CityLocation(city: 'İsfahan (Isfahan)', country: 'İran', latitude: 32.6546, longitude: 51.6680, timezoneOffset: 3.5),
    CityLocation(city: 'Tebriz (Tabriz)', country: 'İran', latitude: 38.0800, longitude: 46.2919, timezoneOffset: 3.5),
    CityLocation(city: 'Şiraz (Shiraz)', country: 'İran', latitude: 29.5918, longitude: 52.5837, timezoneOffset: 3.5),
    CityLocation(city: 'Bağdat (Baghdad)', country: 'Irak', latitude: 33.3152, longitude: 44.3661, timezoneOffset: 3.0),
    CityLocation(city: 'Erbil', country: 'Irak', latitude: 36.1901, longitude: 44.0091, timezoneOffset: 3.0),
    CityLocation(city: 'Basra', country: 'Irak', latitude: 30.5081, longitude: 47.7835, timezoneOffset: 3.0),
    CityLocation(city: 'Tiflis (Tbilisi)', country: 'Gürcistan', latitude: 41.7151, longitude: 44.8271, timezoneOffset: 4.0),
    CityLocation(city: 'Batum (Batumi)', country: 'Gürcistan', latitude: 41.6168, longitude: 41.6367, timezoneOffset: 4.0),
    CityLocation(city: 'Erivan (Yerevan)', country: 'Ermenistan', latitude: 40.1792, longitude: 44.4991, timezoneOffset: 4.0),
    CityLocation(city: 'Dubai', country: 'BAE', latitude: 25.2048, longitude: 55.2708, timezoneOffset: 4.0),
    CityLocation(city: 'Abu Dabi (Abu Dhabi)', country: 'BAE', latitude: 24.4539, longitude: 54.3773, timezoneOffset: 4.0),
    CityLocation(city: 'Riyad (Riyadh)', country: 'Suudi Arabistan', latitude: 24.7136, longitude: 46.6753, timezoneOffset: 3.0),
    CityLocation(city: 'Cidde (Jeddah)', country: 'Suudi Arabistan', latitude: 21.4858, longitude: 39.1925, timezoneOffset: 3.0),
    CityLocation(city: 'Mekke (Mecca)', country: 'Suudi Arabistan', latitude: 21.3891, longitude: 39.8579, timezoneOffset: 3.0),
    CityLocation(city: 'Medine (Medina)', country: 'Suudi Arabistan', latitude: 24.5247, longitude: 39.5692, timezoneOffset: 3.0),
    CityLocation(city: 'Doha', country: 'Katar', latitude: 25.2854, longitude: 51.5310, timezoneOffset: 3.0),
    CityLocation(city: 'Kuveyt (Kuwait City)', country: 'Kuveyt', latitude: 29.3759, longitude: 47.9774, timezoneOffset: 3.0),
    CityLocation(city: 'Manama', country: 'Bahreyn', latitude: 26.2285, longitude: 50.5860, timezoneOffset: 3.0),
    CityLocation(city: 'Maskat (Muscat)', country: 'Umman', latitude: 23.5859, longitude: 58.4059, timezoneOffset: 4.0),
    CityLocation(city: 'Beyrut (Beirut)', country: 'Lübnan', latitude: 33.8938, longitude: 35.5018, timezoneOffset: 2.0),
    CityLocation(city: 'Amman', country: 'Ürdün', latitude: 31.9454, longitude: 35.9284, timezoneOffset: 3.0),
    CityLocation(city: 'Şam (Damascus)', country: 'Suriye', latitude: 33.5138, longitude: 36.2765, timezoneOffset: 3.0),
    CityLocation(city: 'Halep (Aleppo)', country: 'Suriye', latitude: 36.2021, longitude: 37.1343, timezoneOffset: 3.0),
    CityLocation(city: 'Tel Aviv', country: 'İsrail', latitude: 32.0853, longitude: 34.7818, timezoneOffset: 2.0),
    CityLocation(city: 'Kudüs (Jerusalem)', country: 'Filistin', latitude: 31.7683, longitude: 35.2137, timezoneOffset: 2.0),

    // --- AFRİKA (KUZEY, DOĞU, BATI & GÜNEY) ---
    CityLocation(city: 'Kahire (Cairo)', country: 'Mısır', latitude: 30.0444, longitude: 31.2357, timezoneOffset: 2.0),
    CityLocation(city: 'İskenderiye (Alexandria)', country: 'Mısır', latitude: 31.2001, longitude: 29.9187, timezoneOffset: 2.0),
    CityLocation(city: 'Kazablanka (Casablanca)', country: 'Fas', latitude: 33.5731, longitude: -7.5898, timezoneOffset: 1.0),
    CityLocation(city: 'Rabat', country: 'Fas', latitude: 34.0209, longitude: -6.8416, timezoneOffset: 1.0),
    CityLocation(city: 'Marakeş (Marrakech)', country: 'Fas', latitude: 31.6295, longitude: -7.9811, timezoneOffset: 1.0),
    CityLocation(city: 'Tunus (Tunis)', country: 'Tunus', latitude: 36.8065, longitude: 10.1815, timezoneOffset: 1.0),
    CityLocation(city: 'Cezayir (Algiers)', country: 'Cezayir', latitude: 36.7538, longitude: 3.0588, timezoneOffset: 1.0),
    CityLocation(city: 'Trablus (Tripoli)', country: 'Libya', latitude: 32.8872, longitude: 13.1913, timezoneOffset: 2.0),
    CityLocation(city: 'Johannesburg', country: 'Güney Afrika', latitude: -26.2041, longitude: 28.0473, timezoneOffset: 2.0),
    CityLocation(city: 'Cape Town', country: 'Güney Afrika', latitude: -33.9249, longitude: 18.4241, timezoneOffset: 2.0),
    CityLocation(city: 'Durban', country: 'Güney Afrika', latitude: -29.8587, longitude: 31.0218, timezoneOffset: 2.0),
    CityLocation(city: 'Lagos', country: 'Nijerya', latitude: 6.5244, longitude: 3.3792, timezoneOffset: 1.0),
    CityLocation(city: 'Abuja', country: 'Nijerya', latitude: 9.0765, longitude: 7.3986, timezoneOffset: 1.0),
    CityLocation(city: 'Nairobi', country: 'Kenya', latitude: -1.2921, longitude: 36.8219, timezoneOffset: 3.0),
    CityLocation(city: 'Addis Ababa', country: 'Etiyopya', latitude: 9.0300, longitude: 38.7400, timezoneOffset: 3.0),
    CityLocation(city: 'Akra (Accra)', country: 'Gana', latitude: 5.6037, longitude: -0.1870, timezoneOffset: 0.0),

    // --- AMERİKA KITASI (KANADA, LATİN AMERİKA) ---
    CityLocation(city: 'Toronto', country: 'Kanada', latitude: 43.6532, longitude: -79.3832, timezoneOffset: -5.0),
    CityLocation(city: 'Montreal', country: 'Kanada', latitude: 45.5017, longitude: -73.5673, timezoneOffset: -5.0),
    CityLocation(city: 'Vancouver', country: 'Kanada', latitude: 49.2827, longitude: -123.1207, timezoneOffset: -8.0),
    CityLocation(city: 'Calgary', country: 'Kanada', latitude: 51.0447, longitude: -114.0719, timezoneOffset: -7.0),
    CityLocation(city: 'Meksiko City (Mexico City)', country: 'Meksika', latitude: 19.4326, longitude: -99.1332, timezoneOffset: -6.0),
    CityLocation(city: 'Guadalajara', country: 'Meksika', latitude: 20.6597, longitude: -103.3496, timezoneOffset: -6.0),
    CityLocation(city: 'Monterrey', country: 'Meksika', latitude: 25.6866, longitude: -100.3161, timezoneOffset: -6.0),
    CityLocation(city: 'Havana', country: 'Küba', latitude: 23.1136, longitude: -82.3666, timezoneOffset: -5.0),
    CityLocation(city: 'Bogota', country: 'Kolombiya', latitude: 4.7110, longitude: -74.0721, timezoneOffset: -5.0),
    CityLocation(city: 'Medellin', country: 'Kolombiya', latitude: 6.2442, longitude: -75.5812, timezoneOffset: -5.0),
    CityLocation(city: 'Lima', country: 'Peru', latitude: -12.0464, longitude: -77.0428, timezoneOffset: -5.0),
    CityLocation(city: 'São Paulo', country: 'Brezilya', latitude: -23.5505, longitude: -46.6333, timezoneOffset: -3.0),
    CityLocation(city: 'Rio de Janeiro', country: 'Brezilya', latitude: -22.9068, longitude: -43.1729, timezoneOffset: -3.0),
    CityLocation(city: 'Brasilia', country: 'Brezilya', latitude: -15.7975, longitude: -47.8919, timezoneOffset: -3.0),
    CityLocation(city: 'Buenos Aires', country: 'Arjantin', latitude: -34.6037, longitude: -58.3816, timezoneOffset: -3.0),
    CityLocation(city: 'Cordoba', country: 'Arjantin', latitude: -31.4201, longitude: -64.1888, timezoneOffset: -3.0),
    CityLocation(city: 'Santiago', country: 'Şili', latitude: -33.4489, longitude: -70.6693, timezoneOffset: -3.0),
    CityLocation(city: 'Karakas (Caracas)', country: 'Venezuela', latitude: 10.4806, longitude: -66.9036, timezoneOffset: -4.0),
  ];

  /// Yerel hızlı arama (Offline öncelikli, anlık 0ms gecikme)
  static List<CityLocation> search(String query, {int limit = 8}) {
    final q = _normalize(query.trim().toLowerCase());
    if (q.isEmpty) return [];

    final cityStartsWith = <CityLocation>[];
    final cityContains = <CityLocation>[];
    final countryMatches = <CityLocation>[];

    for (final loc in allCities) {
      final cityNorm = _normalize(loc.city.toLowerCase());
      final countryNorm = _normalize(loc.country.toLowerCase());

      if (cityNorm.startsWith(q)) {
        cityStartsWith.add(loc);
      } else if (cityNorm.contains(q)) {
        cityContains.add(loc);
      } else if (countryNorm.startsWith(q) || countryNorm.contains(q)) {
        countryMatches.add(loc);
      }
    }

    return [...cityStartsWith, ...cityContains, ...countryMatches].take(limit).toList();
  }

  /// Canlı Küresel Solar Fire Atlası Arama Motoru (OpenStreetMap / Photon Geocoding Entegrasyonu)
  /// Dünyadaki her köy, kasaba ve koordinatı canlı bularak haritaya bağlar.
  static Future<List<CityLocation>> searchGlobal(String query, {int limit = 8}) async {
    final localMatches = search(query, limit: limit);
    if (localMatches.length >= limit || query.trim().length < 2) {
      return localMatches;
    }

    try {
      final url = Uri.parse('https://photon.komoot.io/api/?q=${Uri.encodeComponent(query.trim())}&limit=6');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final features = (data['features'] as List?) ?? [];

        final remoteResults = <CityLocation>[];
        for (final feat in features) {
          final props = feat['properties'] ?? {};
          final geom = feat['geometry'] ?? {};
          final coords = (geom['coordinates'] as List?) ?? [0.0, 0.0];

          final String name = props['name'] ?? props['city'] ?? props['town'] ?? props['village'] ?? '';
          final String country = props['country'] ?? '';
          if (name.isEmpty) continue;

          final double lon = (coords[0] as num).toDouble();
          final double lat = (coords[1] as num).toDouble();
          final double tzOffset = _estimateTimezoneOffset(lon: lon, country: country);

          remoteResults.add(CityLocation(
            city: name,
            country: country.isNotEmpty ? country : 'Dünya',
            latitude: lat,
            longitude: lon,
            timezoneOffset: tzOffset,
          ));
        }

        final combined = <CityLocation>[...localMatches];
        for (final r in remoteResults) {
          if (!combined.any((c) => _normalize(c.city) == _normalize(r.city))) {
            combined.add(r);
          }
        }
        return combined.take(limit).toList();
      }
    } catch (_) {
      // Çevrimdışı durumda yerel sonuçlarla devam et
    }

    return localMatches;
  }

  static double _estimateTimezoneOffset({required double lon, required String country}) {
    final cLower = country.toLowerCase();
    if (cLower.contains('azerb') || cLower.contains('azer')) return 4.0;
    if (cLower.contains('türk') || cLower.contains('turk')) return 3.0;
    if (cLower.contains('kazak') || cLower.contains('kazakh')) return 5.0;
    if (cLower.contains('özbek') || cLower.contains('uzbek')) return 5.0;
    if (cLower.contains('rus') || cLower.contains('russia')) {
      if (lon < 40) return 3.0;
      if (lon < 55) return 4.0;
      if (lon < 70) return 5.0;
      if (lon < 85) return 6.0;
      if (lon < 100) return 7.0;
      if (lon < 115) return 8.0;
      if (lon < 130) return 9.0;
      return 10.0;
    }
    if (cLower.contains('çin') || cLower.contains('china')) return 8.0;
    if (cLower.contains('japon') || cLower.contains('japan')) return 9.0;
    if (cLower.contains('kore') || cLower.contains('korea')) return 9.0;
    if (cLower.contains('alman') || cLower.contains('germany') || cLower.contains('fran') || cLower.contains('ital') || cLower.contains('ispan') || cLower.contains('spain')) return 1.0;
    if (cLower.contains('ingil') || cLower.contains('uk') || cLower.contains('brit')) return 0.0;
    if (cLower.contains('abd') || cLower.contains('usa') || cLower.contains('united states')) {
      if (lon > -80) return -5.0; // Eastern
      if (lon > -95) return -6.0; // Central
      if (lon > -110) return -7.0; // Mountain
      if (lon > -130) return -8.0; // Pacific
      if (lon > -160) return -9.0; // Alaska
      return -10.0; // Hawaii
    }
    // Genel meridyen tahmini: Her 15 derece 1 saattir
    return (lon / 15.0).roundToDouble();
  }

  /// Şehir adına veya ülke bilgisine göre en uygun koordinatı döner
  static CityLocation findCity(String cityName, [String? countryName]) {
    final cNorm = _normalize(cityName.trim().toLowerCase());
    
    // 1. Birebir veya normalize edilmiş şehir eşleşmesi
    for (final loc in allCities) {
      final lNorm = _normalize(loc.city.toLowerCase());
      if (lNorm == cNorm ||
          lNorm.startsWith('$cNorm ') ||
          lNorm.contains('($cNorm)') ||
          lNorm.startsWith('$cNorm(') ||
          lNorm.endsWith(' $cNorm)')) {
        return loc;
      }
    }

    // 2. İçerme kontrolü (minimum 3 karakter)
    if (cNorm.length >= 3) {
      for (final loc in allCities) {
        final lNorm = _normalize(loc.city.toLowerCase());
        if (lNorm.contains(cNorm)) {
          return loc;
        }
      }
    }

    // 3. Özel bilinen takma adlar (Alias eşleşmesi)
    if (cNorm.contains('yevlax') || cNorm.contains('yevlakh') || cNorm.contains('yevlah')) {
      return const CityLocation(city: 'Yevlax (Yevlakh)', country: 'Azerbaycan', latitude: 40.6172, longitude: 47.1500, timezoneOffset: 4.0);
    }
    if (cNorm.contains('baku') || cNorm.contains('baki')) {
      return const CityLocation(city: 'Bakü (Baku)', country: 'Azerbaycan', latitude: 40.4093, longitude: 49.8671, timezoneOffset: 4.0);
    }
    if (cNorm.contains('moscow') || cNorm.contains('moskva') || cNorm.contains('moskov')) {
      return const CityLocation(city: 'Moskova (Moscow)', country: 'Rusya', latitude: 55.7558, longitude: 37.6173, timezoneOffset: 3.0);
    }
    if (cNorm.contains('almaty') || cNorm.contains('almati')) {
      return const CityLocation(city: 'Almatı (Almaty)', country: 'Kazakistan', latitude: 43.2220, longitude: 76.8512, timezoneOffset: 5.0);
    }
    if (cNorm.contains('astana') || cNorm.contains('nursultan')) {
      return const CityLocation(city: 'Astana (Nur-Sultan)', country: 'Kazakistan', latitude: 51.1694, longitude: 71.4491, timezoneOffset: 5.0);
    }

    // 3. Ülkeye göre akıllı başkent fallback'i (Asla rastgele Bolu'ya düşmez)
    if (countryName != null && countryName.trim().isNotEmpty) {
      final countryNorm = _normalize(countryName.trim().toLowerCase());
      if (countryNorm.contains('azerb') || countryNorm.contains('azer')) {
        return const CityLocation(city: 'Bakü (Baku)', country: 'Azerbaycan', latitude: 40.4093, longitude: 49.8671, timezoneOffset: 4.0);
      }
      if (countryNorm.contains('kazak') || countryNorm.contains('kazakh')) {
        return const CityLocation(city: 'Astana (Nur-Sultan)', country: 'Kazakistan', latitude: 51.1694, longitude: 71.4491, timezoneOffset: 5.0);
      }
      if (countryNorm.contains('rus') || countryNorm.contains('russia')) {
        return const CityLocation(city: 'Moskova (Moscow)', country: 'Rusya', latitude: 55.7558, longitude: 37.6173, timezoneOffset: 3.0);
      }
      if (countryNorm.contains('cin') || countryNorm.contains('china')) {
        return const CityLocation(city: 'Pekin (Beijing)', country: 'Çin', latitude: 39.9042, longitude: 116.4074, timezoneOffset: 8.0);
      }
      if (countryNorm.contains('abd') || countryNorm.contains('usa') || countryNorm.contains('united states')) {
        return const CityLocation(city: 'Washington D.C.', country: 'ABD', latitude: 38.9072, longitude: -77.0369, timezoneOffset: -5.0);
      }
      if (countryNorm.contains('alman') || countryNorm.contains('germany')) {
        return const CityLocation(city: 'Berlin', country: 'Almanya', latitude: 52.5200, longitude: 13.4050, timezoneOffset: 1.0);
      }
      if (countryNorm.contains('ingil') || countryNorm.contains('uk') || countryNorm.contains('brit')) {
        return const CityLocation(city: 'Londra (London)', country: 'İngiltere', latitude: 51.5074, longitude: -0.1278, timezoneOffset: 0.0);
      }
      if (countryNorm.contains('fran')) {
        return const CityLocation(city: 'Paris', country: 'Fransa', latitude: 48.8566, longitude: 2.3522, timezoneOffset: 1.0);
      }
      if (countryNorm.contains('japon') || countryNorm.contains('japan')) {
        return const CityLocation(city: 'Tokyo', country: 'Japonya', latitude: 35.6762, longitude: 139.6503, timezoneOffset: 9.0);
      }
    }

    // Default fallback to Datça, Türkiye
    return const CityLocation(
      city: 'Datça',
      country: 'Türkiye',
      latitude: 36.7265,
      longitude: 27.6853,
      timezoneOffset: 3.0,
    );
  }

  static String _normalize(String input) {
    return input
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('ə', 'e')
        .replaceAll('Ə', 'e')
        .replaceAll('x', 'h')
        .replaceAll('X', 'h');
  }
}
