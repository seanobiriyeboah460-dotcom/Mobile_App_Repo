import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: StreamBuilder(
        stream: service.allOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              final orderId = order['id'] as String;
              final uid = order['uid'] as String;
              final email = order['userEmail'] as String;
              final status = order['status'] as String;
              final total = (order['total'] as num).toDouble();
              final items = List<Map<String, dynamic>>.from(order['items']);
              final ts = order['timestamp'];
              final date = ts != null
                  ? DateFormat('MMM d, h:mm a').format(ts.toDate())
                  : 'Unknown';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...items.map(
                        (item) => Text(
                          '${item['quantity']}x ${item['name']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: GHS ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Status dropdown
                      Row(
                        children: [
                          const Text('Status: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: status,
                              isExpanded: true,
                              items:
                                  ['pending', 'preparing', 'ready', 'completed']
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.toUpperCase()),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (newStatus) async {
                                if (newStatus != null && newStatus != status) {
                                  await service.updateOrderStatus(
                                    orderId,
                                    uid,
                                    newStatus,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
