class ApiConstants {
  // Production Backend running on GCP VM with Let's Encrypt SSL & Nginx
  static const String baseUrl = 'https://34-90-141-245.nip.io/api';

  // Anti-reverse engineering gate secret header
  static const String appSecret = 'gokyuzudoktoru_app_secret_772189';
  static const String appSecretHeader = 'X-App-Secret';

  // Endpoints
  static const String healthEndpoint = '$baseUrl/health';
  static const String chartEndpoint = '$baseUrl/chart/calculate';
  static const String brutalTruthsEndpoint = '$baseUrl/onboarding/brutal-truths';
  static const String dailyHoroscopeEndpoint = '$baseUrl/horoscope/daily';
}
