class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final String? note;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.targetDate,
    this.note,
    required this.createdAt,
  });

  // Progress percentage 0.0 to 1.0
  double get progress =>
      targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  // Progress as percentage string e.g. "75%"
  String get progressPercent => '${(progress * 100).toStringAsFixed(0)}%';

  // Remaining amount to reach goal
  double get remainingAmount =>
      (targetAmount - savedAmount).clamp(0.0, targetAmount);

  // Check if goal is completed
  bool get isCompleted => savedAmount >= targetAmount;

  // Days remaining until target date
  int get daysRemaining =>
      targetDate.difference(DateTime.now()).inDays.clamp(0, 99999);

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0.0).toDouble(),
      targetDate: DateTime.parse(
        map['targetDate'] ?? DateTime.now().toIso8601String(),
      ),
      note: map['note'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Copy with updated fields
  SavingsGoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? note,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
