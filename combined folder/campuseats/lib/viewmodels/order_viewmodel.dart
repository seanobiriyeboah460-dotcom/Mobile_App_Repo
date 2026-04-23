import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class OrderViewModel extends ChangeNotifier {
  final _service = FirestoreService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> placeOrder({
    required String uid,
    required String userEmail,
    required List<CartItem> cartItems,
    required double total,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final items = cartItems.map((i) => i.toMap()).toList();

    try {
      await _service.placeOrder(
        uid: uid,
        userEmail: userEmail,
        items: items,
        total: total,
      );
      return true;
    } catch (e) {
      final errStr = e.toString();

      // Detect offline error — save to Hive queue instead
      if (errStr.contains('network') ||
          errStr.contains('unavailable') ||
          errStr.contains('Failed to get document')) {
        await _saveToOfflineQueue(uid, userEmail, items, total);
        errorMessage =
            'You are offline. Order saved and will sync when connected.';
      } else {
        // Real error e.g. out of stock — show exact message to user
        errorMessage = errStr.replaceAll('Exception: ', '');
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToOfflineQueue(
    String uid,
    String userEmail,
    List<Map<String, dynamic>> items,
    double total,
  ) async {
    final box = Hive.box('pendingOrders');
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(localId, {
      'localId': localId,
      'uid': uid,
      'userEmail': userEmail,
      'items': items,
      'total': total,
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
  }
}
