import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  final String _apiUrl = 'https://api.quotable.io/random';

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      rethrow;
    }
  }
}
