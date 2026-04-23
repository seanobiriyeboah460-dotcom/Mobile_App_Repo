import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class RatingScreen extends StatefulWidget {
  final OrderModel order;
  final String uid;
  const RatingScreen({super.key, required this.order, required this.uid});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentController = TextEditingController();
  int _selectedStars = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedStars == 0) {
      setState(() => _error = 'Please select a star rating');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final db = FirebaseFirestore.instance;

    try {
      // Each order has multiple items — rate each item in the order
      for (final item in widget.order.items) {
        final itemId = item['itemId'] as String;
        final menuRef = db.collection('menu').doc(itemId);
        final reviewRef = db
            .collection('ratings')
            .doc(itemId)
            .collection('reviews')
            .doc(widget.uid);

        // Transaction: update avgRating atomically
        await db.runTransaction((transaction) async {
          final menuDoc = await transaction.get(menuRef);
          final oldAvg = (menuDoc.data()?['avgRating'] ?? 0).toDouble();
          final oldCount = (menuDoc.data()?['ratingCount'] ?? 0) as int;

          // Formula: newAvg = (oldAvg * oldCount + newStars) / (oldCount + 1)
          final newCount = oldCount + 1;
          final newAvg = ((oldAvg * oldCount) + _selectedStars) / newCount;

          transaction.update(menuRef, {
            'avgRating': newAvg,
            'ratingCount': newCount,
          });

          transaction.set(reviewRef, {
            'stars': _selectedStars,
            'comment': _commentController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });
        });
      }

      // Mark order as rated — batch write to both order locations
      final batch = db.batch();
      batch.update(
        db
            .collection('users')
            .doc(widget.uid)
            .collection('orders')
            .doc(widget.order.id),
        {'rated': true},
      );
      batch.update(db.collection('orders').doc(widget.order.id), {
        'rated': true,
      });
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted, thank you!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to submit rating. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Order')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How was your order?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Star selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  icon: Icon(
                    star <= _selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _selectedStars = star),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Leave a comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Rating', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
