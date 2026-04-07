import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/auto_lock_service.dart';
import '../services/notes_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  final NotesService notesService;

  const AddEditNoteScreen({super.key, required this.notesService, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
    _titleController.addListener(_handleUserActivity);
    _contentController.addListener(_handleUserActivity);
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleUserActivity);
    _contentController.removeListener(_handleUserActivity);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    _handleUserActivity();
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
      await widget.notesService.updateNote(updatedNote);
    } else {
      final newNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        lastEdited: now,
      );
      await widget.notesService.addNote(newNote);
    }

    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _handleUserActivity() {
    AutoLockService.userActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleUserActivity,
        onPanDown: (_) => _handleUserActivity(),
        child: Padding(
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
      ),
    );
  }
}
