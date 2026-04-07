import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/auto_lock_service.dart';
import '../services/notes_service.dart';
import '../services/theme_service.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notesService.notes;
    final query = _searchQuery.toLowerCase();
    return _notesService.notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    AutoLockService.start();
    _loadNotes();
  }

  void _onSearchChanged() {
    AutoLockService.userActivity();
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _handleUserActivity() {
    AutoLockService.userActivity();
  }

  void _toggleTheme() {
    final newMode = ThemeService.themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    ThemeService.setThemeMode(newMode);
    setState(() {});
  }

  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Notes'),
        actions: [
          IconButton(
            icon: Icon(
              ThemeService.themeModeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Toggle dark mode',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _handleUserActivity,
              onPanDown: (_) => _handleUserActivity(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search notes',
                        hintText: 'Search by title or content',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredNotes.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No notes. Tap + to add.'
                                  : 'No matching notes found.',
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              _handleUserActivity();
                              return false;
                            },
                            child: ListView.builder(
                              itemCount: _filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[index];
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
                                    trailing:
                                        Text(_formatDate(note.lastEdited)),
                                    onTap: () => _editNote(note),
                                    onLongPress: () => _deleteNote(note.id),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNote() async {
    AutoLockService.userActivity();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
    );
    if (result == true) {
      setState(() {}); // refresh list (or use provider)
    }
  }

  void _editNote(Note note) async {
    AutoLockService.userActivity();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _deleteNote(String id) async {
    AutoLockService.userActivity();
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
