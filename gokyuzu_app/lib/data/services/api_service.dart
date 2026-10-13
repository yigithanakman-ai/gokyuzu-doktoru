import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'astrology_engine.dart';
import '../models/birth_chart_model.dart';
import '../models/brutal_truth_model.dart';
import '../models/daily_horoscope_model.dart';

class ApiService {
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    ApiConstants.appSecretHeader: ApiConstants.appSecret,
  };

  /// Calculates birth chart using Geocentric, Placidus House System, Tropical Western astrology
  /// Connects to the Swiss Ephemeris engine on backend, with seamless local fallback
  static Future<BirthChartModel> calculateChart({
    required String name,
    required String birthDate,
    required String birthTime,
    required String city,
    String? country,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.chartEndpoint),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'birth_date': birthDate,
              'birth_time': birthTime,
              'city': city,
              'country': country,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return BirthChartModel.fromJson(data);
      }
    } catch (_) {
      // Fallback to local offline calculation if network is unavailable
    }

    // Parse Date & Time for local fallback
    DateTime date;
    if (birthDate.contains('-')) {
      final p = birthDate.split('-');
      date = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } else {
      final p = birthDate.split('.');
      date = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    final tp = birthTime.split(':');
    final time = TimeOfDay(hour: int.parse(tp[0]), minute: int.parse(tp[1]));

    return AstrologyEngine.calculateChart(
      name: name,
      birthDate: date,
      birthTime: time,
      city: city,
      country: country,
    );
  }

  /// Returns 3 conversational, witty, and brutally honest truths
  static Future<List<BrutalTruthModel>> getBrutalTruths({
    required String name,
    required String sun,
    required String moon,
    required String ascendant,
    String? northNode,
    String gender = 'Erkek',
    String? mars,
    String? venus,
  }) async {
    return AstrologyEngine.getBrutalTruths(
      name: name,
      sun: sun,
      moon: moon,
      ascendant: ascendant,
      northNode: northNode,
      gender: gender,
      mars: mars,
      venus: venus,
    );
  }

  /// Returns conversational daily transit horoscope
  static Future<DailyHoroscopeModel> getDailyHoroscope({
    required String name,
    required Map<String, dynamic> chart,
    String language = 'sade',
  }) async {
    final targetSign = chart['ascendant']?.toString() ??
        chart['sun']?.toString() ??
        'Koç';
    final cleanSign = targetSign.split(' ').last;

    return AstrologyEngine.getDailyHoroscope(
      name: name,
      targetSign: cleanSign,
    );
  }
}
