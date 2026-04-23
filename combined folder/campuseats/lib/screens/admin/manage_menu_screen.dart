import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../services/firestore_service.dart';

class ManageMenuScreen extends StatelessWidget {
  const ManageMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context, service),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: service.menuStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              // Stock alert badge
              final lowStock = item.stock < 5;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.fastfood, size: 40),
                        ),
                      ),
                      if (lowStock)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'GHS ${item.price.toStringAsFixed(2)} · '
                    'Stock: ${item.stock}'
                    '${lowStock ? ' ⚠️ Low' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showItemDialog(context, service, item: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, service, item),
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

  void _confirmDelete(
    BuildContext context,
    FirestoreService service,
    MenuItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteMenuItem(item.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(
    BuildContext context,
    FirestoreService service, {
    MenuItemModel? item,
  }) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final imageCtrl = TextEditingController(text: item?.imageUrl ?? '');
    final stockCtrl = TextEditingController(
      text: item != null ? item.stock.toString() : '',
    );
    String selectedCategory = item?.category ?? 'Breakfast';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price (GHS)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Breakfast', 'Lunch', 'Snacks']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newItem = MenuItemModel(
                  id: item?.id ?? '',
                  name: nameCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  description: descCtrl.text.trim(),
                  imageUrl: imageCtrl.text.trim(),
                  category: selectedCategory,
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                );
                if (item == null) {
                  await service.addMenuItem(newItem);
                } else {
                  await service.updateMenuItem(item.id, newItem.toMap());
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(item == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
