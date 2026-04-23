import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/firestore_service.dart';

class MenuViewModel extends ChangeNotifier {
  final _service = FirestoreService();

  String searchQuery = '';
  String selectedCategory = 'All';

  Stream<List<MenuItemModel>> get menuStream => _service.menuStream();

  List<MenuItemModel> filter(List<MenuItemModel> items) {
    return items.where((item) {
      final matchesSearch =
          searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedCategory == 'All' || item.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void reset() {
    searchQuery = '';
    selectedCategory = 'All';
    notifyListeners();
  }
}
