import 'package:intl/intl.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

String naira(num amount) => _naira.format(amount);

String compact(num n) {
  if (n >= 1000000) {
    final v = (n / 1000000).toStringAsFixed(1);
    return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}M';
  }
  if (n >= 1000) {
    final v = (n / 1000).toStringAsFixed(1);
    return '${v.endsWith('.0') ? v.substring(0, v.length - 2) : v}K';
  }
  return '$n';
}
