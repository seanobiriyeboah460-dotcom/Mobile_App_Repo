import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── MENU ──────────────────────────────────────────────────────────────────

  Stream<List<MenuItemModel>> menuStream() {
    return _db
        .collection('menu')
        .orderBy('category')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MenuItemModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> addMenuItem(MenuItemModel item) {
    return _db.collection('menu').add(item.toMap());
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) {
    return _db.collection('menu').doc(id).update(data);
  }

  Future<void> deleteMenuItem(String id) {
    return _db.collection('menu').doc(id).delete();
  }

  // ── ORDERS ────────────────────────────────────────────────────────────────

  // Student: their own order history, newest first
  Stream<List<OrderModel>> orderHistoryStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList(),
        );
  }

  // Admin: all orders from top-level mirror, pending first then by time
  Stream<List<Map<String, dynamic>>> allOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('status')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ── ORDER PLACEMENT TRANSACTION ───────────────────────────────────────────

  Future<void> placeOrder({
    required String uid,
    required String userEmail,
    required List<Map<String, dynamic>> items,
    required double total,
    bool syncedFromQueue = false,
  }) async {
    final db = FirebaseFirestore.instance;

    // Generate one ID used in both collections
    final orderId = db.collection('orders').doc().id;

    await db.runTransaction((transaction) async {
      // ── STEP 1: Read all menu docs FIRST (all reads before any writes) ──
      final menuRefs = items
          .map((i) => db.collection('menu').doc(i['itemId'] as String))
          .toList();

      final menuDocs = await Future.wait(
        menuRefs.map((ref) => transaction.get(ref)),
      );

      // ── STEP 2: Check stock for every item ──
      for (int i = 0; i < items.length; i++) {
        final stock = (menuDocs[i].data()?['stock'] ?? 0) as int;
        final requested = items[i]['quantity'] as int;
        if (stock < requested) {
          // Throwing here causes full rollback — nothing is written
          throw Exception(
            '${items[i]['name']} is out of stock. Only $stock left.',
          );
        }
      }

      // ── STEP 3: Decrement stock for each item ──
      for (int i = 0; i < items.length; i++) {
        final currentStock = (menuDocs[i].data()?['stock'] ?? 0) as int;
        final requested = items[i]['quantity'] as int;
        transaction.update(menuRefs[i], {'stock': currentStock - requested});
      }

      final orderData = {
        'items': items,
        'total': total,
        'status': 'pending',
        'rated': false,
        'timestamp': FieldValue.serverTimestamp(),
        'syncedFromQueue': syncedFromQueue,
      };

      // ── STEP 4: Write to user subcollection ──
      transaction.set(
        db.collection('users').doc(uid).collection('orders').doc(orderId),
        orderData,
      );

      // ── STEP 5: Write to admin mirror ──
      transaction.set(db.collection('orders').doc(orderId), {
        'uid': uid,
        'userEmail': userEmail,
        ...orderData,
      });
    });

    // ── STEP 6: Increment totalOrders (outside transaction, non-critical) ──
    await db.collection('users').doc(uid).update({
      'totalOrders': FieldValue.increment(1),
    });
  }

  // ── ADMIN: UPDATE ORDER STATUS ────────────────────────────────────────────

  // Updates BOTH the admin mirror and the user subcollection atomically
  Future<void> updateOrderStatus(
    String orderId,
    String uid,
    String status,
  ) async {
    final batch = _db.batch();

    batch.update(_db.collection('orders').doc(orderId), {'status': status});

    batch.update(
      _db.collection('users').doc(uid).collection('orders').doc(orderId),
      {'status': status},
    );

    await batch.commit();
  }

  // ── USER PROFILE ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateFcmToken(String uid, String token) {
    return _db.collection('users').doc(uid).update({'fcmToken': token});
  }
}
