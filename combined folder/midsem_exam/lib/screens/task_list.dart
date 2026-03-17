import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;

  const TaskListScreen({super.key, required this.tasks});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  void _toggleTaskCompletion(int index) {
    setState(() {
      widget.tasks[index] = Task(
        title: widget.tasks[index].title,
        courseCode: widget.tasks[index].courseCode,
        dueDate: widget.tasks[index].dueDate,
        isComplete: !widget.tasks[index].isComplete,
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: widget.tasks.isEmpty
          ? const Center(
              child: Text('No tasks available'),
            )
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isComplete ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Course: ${task.courseCode}'),
                        Text('Due: ${_formatDate(task.dueDate)}'),
                      ],
                    ),
                    trailing: Checkbox(
                      value: task.isComplete,
                      onChanged: (value) => _toggleTaskCompletion(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
