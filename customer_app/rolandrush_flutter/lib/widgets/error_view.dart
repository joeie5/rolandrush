import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Turns a raw exception into a short, human line instead of dumping the
/// full ClientException/PostgrestException text (URL, stack, etc.) at users.
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
  return "Something went wrong. Please try again.";
}

/// Standard full-bleed error state — icon, friendly message, Retry button.
/// Use across screens instead of printing raw exceptions.
class AppErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool dark;

  const AppErrorView({super.key, required this.error, this.onRetry, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    final fgMuted = dark ? Colors.white54 : AppColors.ink35;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 36, color: fgMuted),
            const SizedBox(height: 14),
            Text(
              friendlyErrorMessage(error),
              textAlign: TextAlign.center,
              style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: fg),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text('Retry', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Non-blocking variant for transient failures (e.g. a background refresh
/// that failed) — a snackbar instead of replacing the whole screen.
void showErrorSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(friendlyErrorMessage(error))),
  );
}
