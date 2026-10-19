import 'package:intl/intl.dart';

final NumberFormat _inr =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// Formats a number as Indian rupees, e.g. 1234 -> "₹1,234".
String inr(num value) => _inr.format(value.round());
