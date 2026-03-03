import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/weather.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';

/// Categories the home screen can display.
enum Category { news, weather, crypto }

class ArticleViewModel extends ChangeNotifier {
  // Dependencies
  final ApiService _apiService = ApiService();

  // Current selected category
  Category _selectedCategory = Category.news;
  Category get selectedCategory => _selectedCategory;

  // Data for each category
  List<Article> _articles = [];
  Weather? _weather;
  CryptoPrice? _cryptoPrice;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI to access state
  List<Article> get articles => _articles;
  Weather? get weather => _weather;
  CryptoPrice? get cryptoPrice => _cryptoPrice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Change the current category and trigger a data load.
  void setCategory(Category category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    loadData();
  }

  /// Load data appropriate for the selected category.
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedCategory == Category.news) {
        _articles = await _apiService.fetchNewsArticles();
      } else if (_selectedCategory == Category.weather) {
        // default city, could be made dynamic later
        _weather = await _apiService.fetchWeather('New York');
      } else if (_selectedCategory == Category.crypto) {
        _cryptoPrice = await _apiService.fetchCryptoPrice([
          'bitcoin',
          'ethereum',
        ]);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Refresh current category's data.
  Future<void> refresh() async {
    await loadData();
  }
}
