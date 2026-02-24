import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_storage.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  final List<Note> allNotes;

  const EditScreen({super.key, this.note, required this.allNotes});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late List<Note> _notes;
  late bool _isNew;
  late String _noteId;

  @override
  void initState() {
    super.initState();
    _notes = List.from(widget.allNotes);
    _isNew = widget.note == null;
    _noteId = _isNew
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.note!.id;
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<bool> _autoSave() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    // Don't save if both are empty
    if (title.isEmpty && content.isEmpty) return true;

    final now = DateTime.now();
    if (_isNew) {
      final newNote = Note(
        id: _noteId,
        title: title,
        content: content,
        updatedAt: now,
      );
      _notes.insert(0, newNote);
    } else {
      final idx = _notes.indexWhere((n) => n.id == _noteId);
      if (idx >= 0) {
        _notes[idx]
          ..title = title
          ..content = content
          ..updatedAt = now;
      }
    }
    await NoteStorage.saveNotes(_notes);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _autoSave();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.grey[200],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
            onPressed: () async {
              await _autoSave();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          title: Text(
            _isNew ? 'Ghi chú mới' : 'Chỉnh sửa',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          // No Save button — auto-save on back
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB0BEC5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 12),
              // Content field
              TextField(
                controller: _contentCtrl,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF37474F),
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  hintText: 'Bắt đầu viết ghi chú của bạn...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB0BEC5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null, // multiline, expands as needed
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
