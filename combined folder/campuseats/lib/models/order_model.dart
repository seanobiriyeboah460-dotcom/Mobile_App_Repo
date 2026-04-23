import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  String status;
  final bool rated;
  final DateTime timestamp;
  final bool syncedFromQueue;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    this.rated = false,
    required this.timestamp,
    this.syncedFromQueue = false,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    // Safely handle timestamp — may be null during transaction write
    DateTime ts;
    try {
      ts = (map['timestamp'] as Timestamp).toDate();
    } catch (_) {
      ts = DateTime.now();
    }

    return OrderModel(
      id: id,
      items: List<Map<String, dynamic>>.from(
        (map['items'] as List).map((i) => Map<String, dynamic>.from(i)),
      ),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      rated: map['rated'] ?? false,
      timestamp: ts,
      syncedFromQueue: map['syncedFromQueue'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'items': items,
    'total': total,
    'status': status,
    'rated': rated,
    'timestamp': FieldValue.serverTimestamp(),
    'syncedFromQueue': syncedFromQueue,
  };
}
