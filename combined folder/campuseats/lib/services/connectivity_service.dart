import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firestore_service.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  StreamSubscription? _subscription;
  final _service = FirestoreService();

  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        _syncPendingOrders();
      }
    });
  }

  Future<void> _syncPendingOrders() async {
    final box = Hive.box('pendingOrders');
    if (box.isEmpty) return;

    final keys = box.keys.toList();
    for (final key in keys) {
      final data = Map<String, dynamic>.from(box.get(key));
      final retryCount = data['retryCount'] as int;

      // Stop retrying after 3 attempts
      if (retryCount >= 3) {
        await box.delete(key);
        continue;
      }

      try {
        await _service.placeOrder(
          uid: data['uid'],
          userEmail: data['userEmail'],
          items: List<Map<String, dynamic>>.from(data['items']),
          total: (data['total'] as num).toDouble(),
          syncedFromQueue: true,
        );
        // Success — remove from queue
        await box.delete(key);
      } catch (e) {
        // Failed — increment retry count and keep in queue
        data['retryCount'] = retryCount + 1;
        await box.put(key, data);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
