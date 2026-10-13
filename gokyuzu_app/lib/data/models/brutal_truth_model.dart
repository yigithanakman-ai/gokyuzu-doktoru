class BrutalTruthModel {
  final int id;
  final String title;
  final String text;

  BrutalTruthModel({
    required this.id,
    required this.title,
    required this.text,
  });

  factory BrutalTruthModel.fromJson(Map<String, dynamic> json) {
    return BrutalTruthModel(
      id: json['number'] ?? json['id'] ?? 1,
      title: json['title'] ?? json['tag'] ?? 'TOKAT GİBİ GERÇEK',
      text: json['text'] ?? json['description'] ?? json['punchline'] ?? '',
    );
  }
}
