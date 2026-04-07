import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NotesService _notesService = NotesService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and content.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    if (widget.note != null) {
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        lastEdited: now,
      );
      await _notesService.updateNote(updatedNote);
    } else {
      final newNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        lastEdited: now,
      );
      await _notesService.addNote(newNote);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveNote,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
