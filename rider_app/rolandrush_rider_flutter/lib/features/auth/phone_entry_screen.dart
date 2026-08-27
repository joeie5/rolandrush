import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/keypad.dart';
import 'providers/rider_auth_provider.dart';

/// Ports PhoneEntry.tsx.
class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  String digits = '';
  bool sending = false;

  String get formatted {
    if (digits.isEmpty) return '';
    final a = digits.length > 3 ? digits.substring(0, 3) : digits;
    final b = digits.length > 3 ? digits.substring(3, digits.length > 6 ? 6 : digits.length) : '';
    final c = digits.length > 6 ? digits.substring(6) : '';
    return [a, b, c].where((s) => s.isNotEmpty).join(' ');
  }

  bool get valid => digits.length == 10;

  Future<void> _continue() async {
    if (!valid || sending) return;
    setState(() => sending = true);
    final e164 = '+234${digits.startsWith('0') ? digits.substring(1) : digits}';
    final ok = await ref.read(riderAuthProvider.notifier).sendOtp(e164);
    if (!mounted) return;
    setState(() => sending = false);
    if (ok) {
      context.push(Uri(path: '/auth/otp', queryParameters: {'phone': e164}).toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send code. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What's your\nphone number?",
                style: AppTheme.sans(size: 34, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -1.2)),
            const SizedBox(height: 8),
            Text("We'll text you a code to sign in.", style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Row(
                children: [
                  Text('+234', style: AppTheme.sans(size: 26, weight: FontWeight.w800, color: AppColors.inkMuted)),
                  const SizedBox(width: 12),
                  Container(height: 32, width: 1, color: AppColors.line),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatted.isEmpty ? '803 000 0000' : formatted,
                      style: AppTheme.sans(size: 28, weight: FontWeight.w800, color: formatted.isEmpty ? AppColors.inkFaint : AppColors.ink, letterSpacing: -0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppKeypad(
              onPress: (d) => setState(() => digits = digits.length < 10 ? digits + d : digits),
              onDelete: () => setState(() => digits = digits.isEmpty ? digits : digits.substring(0, digits.length - 1)),
            ),
            const SizedBox(height: 16),
            AppButton(
              size: AppButtonSize.xl,
              onPressed: valid && !sending ? _continue : null,
              child: sending
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
            ),
          ],
        ),
      ),
    );
  }
}
