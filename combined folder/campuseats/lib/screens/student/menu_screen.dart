import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../models/cart_item_model.dart';
import '../../screens/student/cart_screen.dart';
import '../../screens/student/order_history_screen.dart';
import '../../screens/student/profile_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const categories = ['All', 'Breakfast', 'Lunch', 'Snacks'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuViewModel(),
      child: const _MenuBody(),
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody();

  @override
  Widget build(BuildContext context) {
    final menuVm = context.watch<MenuViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: const Text(
          'Campus Eats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cartVm.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.orange,
                    child: Text(
                      '${cartVm.itemCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OrderHistoryScreen(uid: authVm.currentUser!.uid),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Green header band with search
          Container(
            color: Colors.green.shade700,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: menuVm.setSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search menu...',
                hintStyle: TextStyle(color: Colors.green.shade200),
                prefixIcon: Icon(Icons.search, color: Colors.green.shade200),
                filled: true,
                fillColor: Colors.green.shade600,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Category chips
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: MenuScreen.categories.map((cat) {
                  final selected = menuVm.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Colors.green.shade700,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => menuVm.setCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Menu list
          Expanded(
            child: StreamBuilder(
              stream: menuVm.menuStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.green.shade700,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = menuVm.filter(snapshot.data ?? []);
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 64,
                          color: Colors.green.shade200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No items found',
                          style: TextStyle(color: Colors.green.shade400),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _MenuItemCard(item: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.read<CartViewModel>();
    final inStock = item.stock > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 75,
                  height: 75,
                  color: Colors.green.shade50,
                  child: Icon(
                    Icons.fastfood,
                    size: 36,
                    color: Colors.green.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'GHS ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: inStock
                                ? Colors.green.shade300
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          inStock ? 'Stock: ${item.stock}' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: inStock
                                ? Colors.green.shade700
                                : Colors.red.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.ratingCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          ' (${item.ratingCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Add button
            const SizedBox(width: 8),
            GestureDetector(
              onTap: inStock
                  ? () {
                      cartVm.addItem(
                        CartItem(
                          itemId: item.id,
                          name: item.name,
                          price: item.price,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart'),
                          backgroundColor: Colors.green.shade700,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: inStock ? Colors.green.shade700 : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
