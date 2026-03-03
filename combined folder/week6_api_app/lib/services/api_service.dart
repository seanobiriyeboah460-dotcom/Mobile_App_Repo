import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/weather.dart';
import '../models/crypto.dart';

/// Exception thrown when the server responds with a non-200 status code.
class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => 'HttpException: $message';
}

/// Exception thrown for network-level errors (timeouts, no connection, etc.).
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  // Base URL for the News API
  final String baseUrl = 'newsapi.org';
  final String apiKey =
      '7482d19c4bd346e08338bcc7750e7408'; // You'll get this from registration

  // OpenWeather configuration
  final String weatherBaseUrl = 'api.openweathermap.org';
  final String weatherApiKey =
      '2c8679005464c579b5dc51a34340fa7d'; // provided by user

  // CoinGecko (does not strictly require a key, but provided anyway)
  final String coinGeckoApiKey = 'CG-o4mTEQtg8LEDZaeVXFyePKGY';

  // Method to fetch news articles with comprehensive error handling
  Future<List<Article>> fetchNewsArticles() async {
    final uri = Uri.https(baseUrl, '/v2/top-headlines', {
      'country': 'us',
      'apiKey': apiKey,
    });

    try {
      final response = await http.get(uri);

      // HTTP error
      if (response.statusCode != 200) {
        throw HttpException('Server returned ${response.statusCode}');
      }

      // parse JSON, catch format errors separately
      try {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> articlesJson = jsonData['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } catch (e) {
        throw FormatException('Invalid JSON format');
      }
    } catch (e) {
      if (e is HttpException || e is FormatException) rethrow;
      throw NetworkException('Failed to connect: $e');
    }
  }

  /// Fetch current weather for [city]. Returns a [Weather] object.
  Future<Weather> fetchWeather(String city) async {
    final uri = Uri.https(weatherBaseUrl, '/data/2.5/weather', {
      'q': city,
      'appid': weatherApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw HttpException('Server returned ${response.statusCode}');
      }
      try {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Weather.fromJson(jsonData);
      } catch (e) {
        throw FormatException('Invalid JSON format');
      }
    } catch (e) {
      if (e is HttpException || e is FormatException) rethrow;
      throw NetworkException('Failed to connect: $e');
    }
  }

  /// Fetch simple price data for given coin IDs (e.g. ['bitcoin','ethereum']).
  Future<CryptoPrice> fetchCryptoPrice(List<String> coinIds) async {
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': coinIds.join(','),
      'vs_currencies': 'usd',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw HttpException('Server returned ${response.statusCode}');
      }
      try {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return CryptoPrice.fromJson(jsonData);
      } catch (e) {
        throw FormatException('Invalid JSON format');
      }
    } catch (e) {
      if (e is HttpException || e is FormatException) rethrow;
      throw NetworkException('Failed to connect: $e');
    }
  }
}
