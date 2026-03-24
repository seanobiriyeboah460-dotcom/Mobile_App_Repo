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

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'courseCode': courseCode,
      'dueDate': dueDate.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      courseCode: json['courseCode'],
      dueDate: DateTime.parse(json['dueDate']),
      isComplete: json['isComplete'] ?? false,
    );
  }
}
