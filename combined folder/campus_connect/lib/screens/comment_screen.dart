import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class CommentScreen extends StatefulWidget {
  final Event event;
  CommentScreen({required this.event});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final user = Provider.of<AuthViewModel>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.event.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.event.comments[index];
                return ListTile(
                  title: Text(comment.userName),
                  subtitle: Text(comment.text),
                  trailing: Text(_formatTime(comment.timestamp)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final comment = Comment(
                      userId: user!.uid,
                      userName: user.email ?? 'User',
                      text: _commentController.text,
                      timestamp: DateTime.now(),
                    );
                    await eventVm.addComment(widget.event.id, comment);
                    _commentController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'just now';
  }
}
