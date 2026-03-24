import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/task.dart';
import 'task_list.dart';

class ProfileScreen extends StatelessWidget {
  final Student student;

  const ProfileScreen({super.key, required this.student});

  // Sample tasks for demonstration
  List<Task> get _sampleTasks => [
    Task(
      title: 'Complete Flutter Assignment',
      courseCode: 'CS101',
      dueDate: DateTime(2024, 3, 25),
    ),
    Task(
      title: 'Review Database Design',
      courseCode: 'DB201',
      dueDate: DateTime(2024, 3, 28),
      isComplete: true,
    ),
    Task(
      title: 'Prepare Presentation',
      courseCode: 'COMM301',
      dueDate: DateTime(2024, 4, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              student.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile tapped')),
                );
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskListScreen(tasks: _sampleTasks),
                  ),
                );
              },
              child: const Text('View tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
