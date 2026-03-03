class Weather {
  final String city;
  final double temperature; // in Kelvin by default from API
  final String description;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
  });

  /// The API returns temperature in Kelvin. Convert to Celsius when needed.
  double get temperatureCelsius => temperature - 273.15;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final cityName = json['name'] ?? '';
    final temp = (json['main']?['temp'] as num?)?.toDouble() ?? 0.0;
    final weatherList = json['weather'] as List?;
    final descr = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList[0]['description'] ?? ''
        : '';
    return Weather(city: cityName, temperature: temp, description: descr);
  }
}
