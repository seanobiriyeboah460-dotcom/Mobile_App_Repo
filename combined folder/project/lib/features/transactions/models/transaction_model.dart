enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String? note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.date,
  });

  // Check if transaction is income
  bool get isIncome => type == TransactionType.income;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: map['category'] ?? 'Other',
      note: map['note'],
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    String? note,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  // Income categories
  static List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  // Expense categories
  static List<String> expenseCategories = [
    'Food & Drinks',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Health',
    'Education',
    'Entertainment',
    'Savings',
    'Other',
  ];
}
