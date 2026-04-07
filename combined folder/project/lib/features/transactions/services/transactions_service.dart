import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../../auth/services/auth_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _transactions =>
      _firestore.collection('transactions');

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      // Save transaction to Firestore
      await _transactions.doc(transaction.id).set(transaction.toMap());

      // Update user account balance
      final user = await _authService.getUserData(transaction.userId);
      if (user != null) {
        double newBalance = user.accountBalance;
        if (transaction.isIncome) {
          newBalance += transaction.amount;
        } else {
          newBalance -= transaction.amount;
        }
        await _authService.updateBalance(transaction.userId, newBalance);
      }
    } catch (e) {
      throw 'Failed to add transaction: $e';
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      // Delete from Firestore
      await _transactions.doc(transaction.id).delete();

      // Reverse the effect on account balance
      final user = await _authService.getUserData(transaction.userId);
      if (user != null) {
        double newBalance = user.accountBalance;
        if (transaction.isIncome) {
          newBalance -= transaction.amount;
        } else {
          newBalance += transaction.amount;
        }
        await _authService.updateBalance(transaction.userId, newBalance);
      }
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  // Get all transactions for a user as a stream
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _transactions
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransactionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Get transactions filtered by type
  Stream<List<TransactionModel>> getTransactionsByType(
    String userId,
    TransactionType type,
  ) {
    return _transactions
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransactionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Get transactions for a specific month
  Stream<List<TransactionModel>> getTransactionsByMonth(
    String userId,
    int month,
    int year,
  ) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return _transactions
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransactionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Get total income for a user
  Future<double> getTotalIncome(String userId) async {
    final snapshot = await _transactions
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'income')
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] ?? 0.0).toDouble();
    }
    return total;
  }

  // Get total expenses for a user
  Future<double> getTotalExpenses(String userId) async {
    final snapshot = await _transactions
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'expense')
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] ?? 0.0).toDouble();
    }
    return total;
  }

  // Get monthly summary (income vs expenses per month)
  Future<Map<String, double>> getMonthlySummary(
    String userId,
    int month,
    int year,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final snapshot = await _transactions
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .get();

    double income = 0.0;
    double expenses = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0.0).toDouble();
      if (data['type'] == 'income') {
        income += amount;
      } else {
        expenses += amount;
      }
    }

    return {'income': income, 'expenses': expenses};
  }
}
