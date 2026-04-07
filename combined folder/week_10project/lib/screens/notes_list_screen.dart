import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Notes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notesService.notes.isEmpty
          ? const Center(child: Text('No notes. Tap + to add.'))
          : ListView.builder(
              // Optimized: builder not children
              itemCount: _notesService.notes.length,
              itemBuilder: (context, index) {
                final note = _notesService.notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      '${note.content.substring(0, note.content.length > 50 ? 50 : note.content.length)}...',
                    ),
                    trailing: Text(_formatDate(note.lastEdited)),
                    onTap: () => _editNote(note),
                    onLongPress: () => _deleteNote(note.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
    );
    if (result == true) {
      setState(() {}); // refresh list (or use provider)
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _notesService.deleteNote(id);
      setState(() {});
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
}
