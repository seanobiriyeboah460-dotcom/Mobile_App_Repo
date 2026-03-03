class CryptoPrice {
  /// Map from coin id (e.g. "bitcoin") to USD price.
  final Map<String, double> prices;

  CryptoPrice({required this.prices});

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    final Map<String, double> parsed = {};
    json.forEach((key, value) {
      if (value is Map && value['usd'] != null) {
        parsed[key] = (value['usd'] as num).toDouble();
      }
    });
    return CryptoPrice(prices: parsed);
  }
}
