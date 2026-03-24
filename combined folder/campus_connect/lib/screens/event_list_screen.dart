import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
import 'add_event_screen.dart';
import 'comment_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventViewModel>(context, listen: false).listenToEvents();
  }

  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final userId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.uid ??
        '';

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: eventVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventVm.errorMessage != null
          ? Center(child: Text(eventVm.errorMessage!))
          : ListView.builder(
              itemCount: eventVm.events.length,
              itemBuilder: (context, index) {
                final event = eventVm.events[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.description}\n${_formatDate(event.date)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            event.likes.contains(userId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => eventVm.toggleLike(event.id, userId),
                        ),
                        Text('${event.likes.length}'),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentScreen(event: event),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEventScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
