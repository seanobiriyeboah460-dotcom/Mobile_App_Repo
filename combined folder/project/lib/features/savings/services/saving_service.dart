import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/savings_goal_model.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _goals => _firestore.collection('savings_goals');

  // Add a new savings goal
  Future<void> addGoal(SavingsGoalModel goal) async {
    try {
      await _goals.doc(goal.id).set(goal.toMap());
    } catch (e) {
      throw 'Failed to add savings goal: $e';
    }
  }

  // Update saved amount for a goal
  Future<void> updateSavedAmount(String goalId, double newAmount) async {
    try {
      await _goals.doc(goalId).update({'savedAmount': newAmount});
    } catch (e) {
      throw 'Failed to update savings goal: $e';
    }
  }

  // Delete a savings goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goals.doc(goalId).delete();
    } catch (e) {
      throw 'Failed to delete savings goal: $e';
    }
  }

  // Get all savings goals for a user as a stream
  Stream<List<SavingsGoalModel>> getGoals(String userId) {
    return _goals
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SavingsGoalModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Get total saved amount across all goals
  Future<double> getTotalSaved(String userId) async {
    try {
      final snapshot = await _goals.where('userId', isEqualTo: userId).get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['savedAmount'] ?? 0.0).toDouble();
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get number of completed goals
  Future<int> getCompletedGoalsCount(String userId) async {
    try {
      final snapshot = await _goals.where('userId', isEqualTo: userId).get();

      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final target = (data['targetAmount'] ?? 0.0).toDouble();
        final saved = (data['savedAmount'] ?? 0.0).toDouble();
        if (saved >= target) count++;
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  // Add money to a specific goal
  Future<void> addToGoal(
    String goalId,
    double currentAmount,
    double amountToAdd,
  ) async {
    try {
      final newAmount = currentAmount + amountToAdd;
      await _goals.doc(goalId).update({'savedAmount': newAmount});
    } catch (e) {
      throw 'Failed to add to goal: $e';
    }
  }
}
