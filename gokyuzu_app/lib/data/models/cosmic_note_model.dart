import 'dart:convert';

class CosmicNote {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String category; // 'Günlük', 'Rüya', 'Transit Hissi', 'Doğum Günü & Kutlama'
  final String? linkedPlanet; // 'Ay', 'Güneş', 'Venüs', 'Satürn' vb.
  final bool isFavorite;
  final DateTime createdAt;

  CosmicNote({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.category = 'Günlük',
    this.linkedPlanet,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CosmicNote copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? category,
    String? linkedPlanet,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return CosmicNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      category: category ?? this.category,
      linkedPlanet: linkedPlanet ?? this.linkedPlanet,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'category': category,
      'linkedPlanet': linkedPlanet,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CosmicNote.fromMap(Map<String, dynamic> map) {
    return CosmicNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      category: map['category'] ?? 'Günlük',
      linkedPlanet: map['linkedPlanet'],
      isFavorite: map['isFavorite'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CosmicNote.fromJson(String source) =>
      CosmicNote.fromMap(json.decode(source));
}
