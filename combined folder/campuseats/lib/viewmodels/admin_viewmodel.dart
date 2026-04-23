import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final _service = FirestoreService();

  bool isLoading = false;
  String? errorMessage;

  Future<void> updateOrderStatus(
    String orderId,
    String uid,
    String newStatus,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.updateOrderStatus(orderId, uid, newStatus);
    } catch (e) {
      errorMessage = 'Failed to update status. Try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
