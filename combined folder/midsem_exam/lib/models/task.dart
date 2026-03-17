class Task {
  final String title;
  final String courseCode;
  final DateTime dueDate;
  final bool isComplete;

  Task({
    required this.title,
    required this.courseCode,
    required this.dueDate,
    this.isComplete = false,
  });
}
