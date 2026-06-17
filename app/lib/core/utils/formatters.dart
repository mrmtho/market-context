import 'package:intl/intl.dart';

/// Centralised, consistent financial formatting (Design Guidelines §15).
class Fmt {
  Fmt._();

  static final _date = DateFormat('MMM d, yyyy');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _shortDate = DateFormat('MMM d');

  static String date(DateTime d) => _date.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String shortDate(DateTime d) => _shortDate.format(d);

  /// Currency value with sensible precision and a symbol.
  static String price(num value, {String currency = 'USD'}) {
    final symbol = _symbolFor(currency);
    final fractionDigits = value.abs() >= 1000 ? 0 : 2;
    final f = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: fractionDigits,
    );
    return f.format(value);
  }

  /// Precise price (always 2 dp) for the hero readout.
  static String priceExact(num value, {String currency = 'USD'}) {
    final symbol = _symbolFor(currency);
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(value);
  }

  /// Signed percentage, e.g. "+2.41%".
  static String percent(num value, {int digits = 2}) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(digits)}%';
  }

  /// Signed absolute change with currency.
  static String signedPrice(num value, {String currency = 'USD'}) {
    final sign = value > 0 ? '+' : '';
    return '$sign${price(value, currency: currency)}';
  }

  /// Large numbers as compact magnitudes: 1.2T, 845.0B, 12.4M.
  static String compact(num value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1e12) return '$sign${(abs / 1e12).toStringAsFixed(2)}T';
    if (abs >= 1e9) return '$sign${(abs / 1e9).toStringAsFixed(2)}B';
    if (abs >= 1e6) return '$sign${(abs / 1e6).toStringAsFixed(2)}M';
    if (abs >= 1e3) return '$sign${(abs / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  /// Compact currency, e.g. "$1.24T".
  static String compactCurrency(num value, {String currency = 'USD'}) =>
      '${_symbolFor(currency)}${compact(value)}';

  /// A plain decimal with fixed precision.
  static String number(num value, {int digits = 2}) =>
      value.toStringAsFixed(digits);

  static String _symbolFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'ZAR':
        return 'R';
      default:
        return '';
    }
  }
}
