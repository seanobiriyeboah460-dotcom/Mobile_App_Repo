import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format a number as currency e.g. 1500.0 → GH₵1,500.00
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_GH',
      symbol: 'GH₵',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format without symbol e.g. 1500.0 → 1,500.00
  static String formatPlain(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_GH');
    return formatter.format(amount);
  }

  // Format compact e.g. 1500000.0 → GH₵1.5M
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'GH₵${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'GH₵${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  // Parse a formatted string back to double e.g. "GH₵1,500.00" → 1500.0
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[GH₵,\s]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
