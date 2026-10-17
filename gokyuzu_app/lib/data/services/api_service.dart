import 'package:flutter/material.dart';
import 'astrology_engine.dart';
import '../models/birth_chart_model.dart';
import '../models/brutal_truth_model.dart';
import '../models/daily_horoscope_model.dart';

class ApiService {
  /// Calculates birth chart using Geocentric, Placidus House System, Tropical Western astrology

  /// Connects to the Swiss Ephemeris engine on backend, with seamless local fallback
  static Future<BirthChartModel> calculateChart({
    required String name,
    required String birthDate,
    required String birthTime,
    required String city,
    String? country,
  }) async {
    // Parse Date & Time safely
    DateTime date;
    if (birthDate.contains('-')) {
      final p = birthDate.split('-');
      date = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } else if (birthDate.contains('.')) {
      final p = birthDate.split('.');
      date = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } else {
      date = DateTime(1990, 1, 1);
    }

    final tp = birthTime.split(':');
    final hour = tp.isNotEmpty ? (int.tryParse(tp[0]) ?? 12) : 12;
    final minute = tp.length > 1 ? (int.tryParse(tp[1]) ?? 0) : 0;
    final time = TimeOfDay(hour: hour, minute: minute);

    // Unified deterministic calculation (Keplerian ephemeris + Historical Timezone + Placidus ASC/MC)
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

  /// Returns real-time daily transit horoscope
  static Future<DailyHoroscopeModel> getDailyHoroscope({
    required String name,
    required Map<String, dynamic> chart,
    String language = 'sade',
  }) async {
    final targetSign = chart['ascendant']?.toString() ??
        chart['sun']?.toString() ??
        'Koç';

    return AstrologyEngine.getDailyHoroscope(
      name: name,
      targetSign: targetSign,
      sunSign: chart['sun']?.toString(),
      moonSign: chart['moon']?.toString(),
    );
  }
}

