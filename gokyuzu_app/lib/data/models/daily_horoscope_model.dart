class DailyHoroscopeModel {
  final String date;
  final String text;

  DailyHoroscopeModel({
    required this.date,
    required this.text,
  });

  factory DailyHoroscopeModel.fromJson(Map<String, dynamic> json) {
    return DailyHoroscopeModel(
      date: json['date'] ?? '',
      text: json['horoscope'] ?? json['text'] ?? '',
    );
  }
}
