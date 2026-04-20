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
import '../../screens/auth/login_screen.dart';

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
      appBar: AppBar(
        title: const Text('Campus Eats'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
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
                    backgroundColor: Colors.red,
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
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search menu...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: menuVm.setSearch,
            ),
          ),
          // Category filter
          SizedBox(
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
                    onSelected: (_) => menuVm.setCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Menu list
          Expanded(
            child: StreamBuilder(
              stream: menuVm.menuStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = menuVm.filter(snapshot.data ?? []);
                if (items.isEmpty) {
                  return const Center(child: Text('No items found'));
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'GHS ${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              item.stock > 0 ? 'In stock: ${item.stock}' : 'Out of stock',
              style: TextStyle(
                color: item.stock > 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.orange),
          onPressed: item.stock > 0
              ? () {
                  cartVm.addItem(
                    CartItem(
                      itemId: item.id,
                      name: item.name,
                      price: item.price,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} added to cart')),
                  );
                }
              : null,
        ),
        isThreeLine: true,
      ),
    );
  }
}
