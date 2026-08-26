import 'package:intl/intl.dart';

final _nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

/// Ports utils/format.ts's naira().
String naira(num amount) => _nairaFormat.format(amount);

/// Ports utils/format.ts's nairaCompact().
String nairaCompact(num amount) {
  if (amount >= 1000) {
    final k = amount / 1000;
    final kStr = k % 1 == 0 ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
    return '₦${kStr}k';
  }
  return '₦${amount.toStringAsFixed(0)}';
}
