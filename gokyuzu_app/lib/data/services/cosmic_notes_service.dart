import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cosmic_note_model.dart';
import 'storage_service.dart';

class CosmicNotesResult {
  final bool success;
  final String? message;
  final bool requiresVip;

  const CosmicNotesResult({
    required this.success,
    this.message,
    this.requiresVip = false,
  });
}

class CosmicNotesService {
  static const String _keyNotes = 'gokyuzu_cosmic_notes_v1';

  /// Tüm notları getirir (en yeni tarihli en başta)
  static Future<List<CosmicNote>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyNotes);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = json.decode(jsonStr);
      final notes = list.map((e) => CosmicNote.fromMap(e)).toList();
      notes.sort((a, b) => b.date.compareTo(a.date));
      return notes;
    } catch (_) {
      return [];
    }
  }

  /// Yeni not kaydetme (VIP Kontrolü ile)
  static Future<CosmicNotesResult> saveNote(CosmicNote note) async {
    final isVip = await StorageService.isVipUnlocked();
    if (!isVip) {
      return const CosmicNotesResult(
        success: false,
        message: 'Kozmik Günlük & Hatırlatıcı modülü VIP üyelere özeldir.',
        requiresVip: true,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    if (existingIndex == -1) {
      notes.insert(0, note);
    } else {
      notes[existingIndex] = note;
    }

    final rawList = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_keyNotes, json.encode(rawList));

    return const CosmicNotesResult(success: true);
  }

  /// Not silme
  static Future<bool> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    final rawList = notes.map((n) => n.toMap()).toList();
    return await prefs.setString(_keyNotes, json.encode(rawList));
  }
}
