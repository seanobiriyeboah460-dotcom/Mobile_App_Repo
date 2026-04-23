import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  final Box _box = Hive.box('cart');
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0.0, (sum, i) => sum + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  CartViewModel() {
    _loadFromHive();
  }

  void _loadFromHive() {
    _items.clear();
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final data = Map<String, dynamic>.from(raw as Map);
      _items.add(
        CartItem(
          itemId: data['itemId'] as String,
          name: data['name'] as String,
          price: (data['price'] as num).toDouble(),
          quantity: data['quantity'] as int,
        ),
      );
    }
    notifyListeners();
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.itemId == item.itemId);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    _saveToHive();
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.itemId == itemId);
    _box.delete(itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    final index = _items.indexWhere((i) => i.itemId == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _saveToHive();
    }
  }

  void clearCart() {
    _items.clear();
    _box.clear();
    notifyListeners();
  }

  void _saveToHive() {
    _box.clear();
    for (final item in _items) {
      _box.put(item.itemId, {
        'itemId': item.itemId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      });
    }
    notifyListeners();
  }
}
