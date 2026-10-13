import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String birthDate;
  final String birthTime;
  final String birthCountry;
  final String birthCity;
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final String gender; // 'Erkek', 'Kadın', 'Hermafrodit / Diğer'
  final String language; // 'tr', 'en', 'ja'
  final bool isVip;
  final Map<String, dynamic> rawChart;

  UserProfile({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    this.birthCountry = 'Türkiye',
    required this.birthCity,
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    this.gender = 'Erkek',
    this.language = 'tr',
    this.isVip = false,
    this.rawChart = const {},
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate,
    'birthTime': birthTime,
    'birthCountry': birthCountry,
    'birthCity': birthCity,
    'sunSign': sunSign,
    'moonSign': moonSign,
    'risingSign': risingSign,
    'gender': gender,
    'language': language,
    'isVip': isVip,
    'rawChart': rawChart,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    birthDate: json['birthDate'] ?? '',
    birthTime: json['birthTime'] ?? '',
    birthCountry: json['birthCountry'] ?? 'Türkiye',
    birthCity: json['birthCity'] ?? '',
    sunSign: json['sunSign'] ?? 'Koç',
    moonSign: json['moonSign'] ?? 'Koç',
    risingSign: json['risingSign'] ?? 'Koç',
    gender: json['gender'] ?? 'Erkek',
    language: json['language'] ?? 'tr',
    isVip: json['isVip'] == true,
    rawChart: json['rawChart'] is Map<String, dynamic>
        ? json['rawChart'] as Map<String, dynamic>
        : {},
  );
}

enum VipTier { free, silver, gold, platinum }

class StorageService {
  static const _profileKey = 'gokyuzu_user_profile';
  static const _chartKey = 'gokyuzu_cached_chart';
  static const _vipKey = 'gokyuzu_vip_status';
  static const _vipTierKey = 'gokyuzu_vip_tier';
  static const _languageKey = 'gokyuzu_selected_language';

  // Valid VIP promotional & sharing codes (Master VIP Code: gkyz2453)
  static const List<String> _validVipCodes = [
    'GKYZ2453',
  ];

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_chartKey);
  }

  static Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveChartJson(Map<String, dynamic> chart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chartKey, jsonEncode(chart));
  }

  static Future<Map<String, dynamic>?> getChartJson() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_chartKey);
    if (data == null) return null;
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  // VIP Code Activation
  static Future<bool> activateVipCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (_validVipCodes.contains(clean) || clean.startsWith('VIP-')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vipKey, true);
      await prefs.setString(_vipTierKey, 'platinum'); // Master kod Platinum açar!
      final currentProfile = await getProfile();
      if (currentProfile != null) {
        final updated = UserProfile(
          name: currentProfile.name,
          birthDate: currentProfile.birthDate,
          birthTime: currentProfile.birthTime,
          birthCountry: currentProfile.birthCountry,
          birthCity: currentProfile.birthCity,
          sunSign: currentProfile.sunSign,
          moonSign: currentProfile.moonSign,
          risingSign: currentProfile.risingSign,
          gender: currentProfile.gender,
          language: currentProfile.language,
          isVip: true,
          rawChart: currentProfile.rawChart,
        );
        await saveProfile(updated);
      }
      return true;
    }
    return false;
  }

  static Future<bool> isVip() async {
    final prefs = await SharedPreferences.getInstance();
    final localVip = prefs.getBool(_vipKey);
    if (localVip == true) return true;
    final profile = await getProfile();
    return profile?.isVip ?? false;
  }

  static Future<bool> isVipUnlocked() => isVip();

  static Future<VipTier> getVipTier() async {
    final isVipActive = await isVip();
    if (!isVipActive) return VipTier.free;

    final prefs = await SharedPreferences.getInstance();
    final tierStr = prefs.getString(_vipTierKey);
    switch (tierStr) {
      case 'silver':
        return VipTier.silver;
      case 'gold':
        return VipTier.gold;
      case 'platinum':
      default:
        return VipTier.platinum;
    }
  }

  static Future<void> setVipTier(VipTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    if (tier == VipTier.free) {
      await deactivateVip();
    } else {
      await prefs.setBool(_vipKey, true);
      await prefs.setString(_vipTierKey, tier.name);
      final currentProfile = await getProfile();
      if (currentProfile != null && !currentProfile.isVip) {
        await saveProfile(UserProfile(
          name: currentProfile.name,
          birthDate: currentProfile.birthDate,
          birthTime: currentProfile.birthTime,
          birthCountry: currentProfile.birthCountry,
          birthCity: currentProfile.birthCity,
          sunSign: currentProfile.sunSign,
          moonSign: currentProfile.moonSign,
          risingSign: currentProfile.risingSign,
          gender: currentProfile.gender,
          language: currentProfile.language,
          isVip: true,
          rawChart: currentProfile.rawChart,
        ));
      }
    }
  }

  static Future<int> getMonthlyPdfAllowance() async {
    final tier = await getVipTier();
    switch (tier) {
      case VipTier.silver:
        return 1;
      case VipTier.gold:
        return 2;
      case VipTier.platinum:
        return 999;
      case VipTier.free:
        return 0;
    }
  }

  static Future<bool> canAccessSynastry() async {
    final tier = await getVipTier();
    return tier == VipTier.gold || tier == VipTier.platinum;
  }

  static Future<bool> canAccessLunarAndLifeCycles() async {
    final tier = await getVipTier();
    return tier == VipTier.gold || tier == VipTier.platinum;
  }

  static Future<bool> canAccessAdvancedModules() async {
    final tier = await getVipTier();
    return tier == VipTier.platinum;
  }

  static Future<void> deactivateVip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vipKey, false);
    await prefs.remove(_vipTierKey);
    final currentProfile = await getProfile();
    if (currentProfile != null) {
      final updated = UserProfile(
        name: currentProfile.name,
        birthDate: currentProfile.birthDate,
        birthTime: currentProfile.birthTime,
        birthCountry: currentProfile.birthCountry,
        birthCity: currentProfile.birthCity,
        sunSign: currentProfile.sunSign,
        moonSign: currentProfile.moonSign,
        risingSign: currentProfile.risingSign,
        gender: currentProfile.gender,
        language: currentProfile.language,
        isVip: false,
        rawChart: currentProfile.rawChart,
      );
      await saveProfile(updated);
    }
  }

  static String getShareableVipCode() {
    return 'gkyz2453';
  }

  // Language support
  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  static const _userAccountKey = 'gokyuzu_user_account';

  static Future<void> saveUserAccount({
    required String name,
    required String surname,
    required String email,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userAccountKey,
      jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
        'gender': gender,
      }),
    );
  }

  static Future<Map<String, dynamic>?> getUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userAccountKey);
    if (data == null) return null;
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  static const _feedbackKey = 'gokyuzu_user_feedback';

  static Future<void> saveFeedback({
    required String category,
    required String message,
    required String senderName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFeedbackList();
    list.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': category,
      'message': message,
      'senderName': senderName,
      'date': DateTime.now().toIso8601String(),
      'status': 'İnceleniyor',
    });
    await prefs.setString(_feedbackKey, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getFeedbackList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedbackKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
