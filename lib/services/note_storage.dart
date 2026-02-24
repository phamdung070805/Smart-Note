import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const String _key = 'smart_note_data';

  /// Load all notes from SharedPreferences.
  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return Note.listFromJson(jsonStr);
    } catch (_) {
      return [];
    }
  }

  /// Persist all notes to SharedPreferences as JSON.
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Note.listToJson(notes));
  }
}
