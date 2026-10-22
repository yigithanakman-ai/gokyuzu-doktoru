import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/astrology_engine.dart';

class SavedProfile {
  final String id;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String birthTime; // HH:mm
  final String birthCity;
  final String birthCountry;
  final String gender;
  final bool isPinned;
  final String? notes;
  final DateTime createdAt;
  final String? _sunSign;
  final String? _moonSign;
  final String? _risingSign;

  SavedProfile({
    required this.id,
    required this.name,
    this.surname = '',
    required this.birthDate,
    required this.birthTime,
    required this.birthCity,
    required this.birthCountry,
    required this.gender,
    this.isPinned = false,
    this.notes,
    DateTime? createdAt,
    String? sunSign,
    String? moonSign,
    String? risingSign,
  })  : createdAt = createdAt ?? DateTime.now(),
        // ignore: prefer_initializing_formals
        _sunSign = sunSign,
        // ignore: prefer_initializing_formals
        _moonSign = moonSign,
        // ignore: prefer_initializing_formals
        _risingSign = risingSign;

  String get fullName => '$name $surname'.trim();

  String get sunSign {
    final parts = birthTime.split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 12) : 12;
    final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return AstrologyEngine.calculateSunSign(
      birthDate,
      TimeOfDay(hour: h, minute: min),
      birthCity,
      birthCountry,
    );
  }

  String get moonSign {
    final parts = birthTime.split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 12) : 12;
    final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return AstrologyEngine.calculateMoonSign(
      birthDate,
      TimeOfDay(hour: h, minute: min),
      city: birthCity,
      country: birthCountry,
    );
  }

  String get risingSign {
    final parts = birthTime.split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 12) : 12;
    final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return AstrologyEngine.calculateRisingSign(
      birthDate,
      TimeOfDay(hour: h, minute: min),
      city: birthCity,
      country: birthCountry,
    );
  }

  SavedProfile copyWith({
    String? id,
    String? name,
    String? surname,
    DateTime? birthDate,
    String? birthTime,
    String? birthCity,
    String? birthCountry,
    String? gender,
    bool? isPinned,
    String? notes,
    DateTime? createdAt,
    String? sunSign,
    String? moonSign,
    String? risingSign,
  }) {
    return SavedProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthCity: birthCity ?? this.birthCity,
      birthCountry: birthCountry ?? this.birthCountry,
      gender: gender ?? this.gender,
      isPinned: isPinned ?? this.isPinned,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      sunSign: sunSign ?? _sunSign,
      moonSign: moonSign ?? _moonSign,
      risingSign: risingSign ?? _risingSign,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime,
      'birthCity': birthCity,
      'birthCountry': birthCountry,
      'gender': gender,
      'isPinned': isPinned,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'sunSign': _sunSign,
      'moonSign': _moonSign,
      'risingSign': _risingSign,
    };
  }

  factory SavedProfile.fromMap(Map<String, dynamic> map) {
    return SavedProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      birthDate:
          DateTime.tryParse(map['birthDate'] ?? '') ?? DateTime(1995, 1, 1),
      birthTime: map['birthTime'] ?? '12:00',
      birthCity: map['birthCity'] ?? '',
      birthCountry: map['birthCountry'] ?? 'Türkiye',
      gender: map['gender'] ?? 'Diğer',
      isPinned: map['isPinned'] ?? false,
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      sunSign: map['sunSign'],
      moonSign: map['moonSign'],
      risingSign: map['risingSign'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedProfile.fromJson(String source) =>
      SavedProfile.fromMap(json.decode(source));
}
