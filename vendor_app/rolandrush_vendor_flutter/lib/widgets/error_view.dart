import 'package:flutter/material.dart';
import '../core/theme.dart';

String friendlyErrorMessage(Object error) {
  final text = error.toString();
  if (text.contains('Failed host lookup') || text.contains('SocketException')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (text.contains('PostgrestException') && text.contains('401')) {
    return 'Session expired — please sign in again.';
  }
  if (text.contains('TimeoutException')) {
    return 'That took too long. Try again.';
  }
  return 'Something went wrong. Please try again.';
}

class AppErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  const AppErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.inkSubtle),
            const SizedBox(height: 14),
            Text(friendlyErrorMessage(error), textAlign: TextAlign.center, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: Text('Retry', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral))),
            ],
          ],
        ),
      ),
    );
  }
}
