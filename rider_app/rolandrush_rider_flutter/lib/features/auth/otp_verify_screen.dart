import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/keypad.dart';
import '../../widgets/code_boxes.dart';
import '../../core/supabase_service.dart';
import 'providers/rider_auth_provider.dart';

/// Ports OtpVerify.tsx.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String code = '';
  bool verifying = false;

  Future<void> _verify() async {
    if (code.length < 4 || verifying) return;
    setState(() => verifying = true);
    final ok = await ref.read(riderAuthProvider.notifier).verifyOtp(widget.phone, code);
    if (!mounted) return;
    setState(() => verifying = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect code. Try again.')));
      return;
    }
    if (!mounted) return;
    // A returning rider (dev bypass, or a real phone number that already
    // has a rider_profiles row) skips Signup entirely — route by
    // verification_status instead. A brand-new phone number goes to
    // Signup to create that row.
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      context.go('/auth/signup');
      return;
    }
    final existing = await SupabaseService.client.from('rider_profiles').select('verification_status').eq('user_id', userId).maybeSingle();
    if (!mounted) return;
    if (existing == null) {
      context.go('/auth/signup');
    } else if (existing['verification_status'] == 'verified') {
      context.go('/home');
    } else {
      context.go('/auth/verification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      onBack: () => context.pop(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your code', style: AppTheme.sans(size: 32, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -1.2)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(text: widget.phone, style: AppTheme.sans(size: 16, weight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CodeBoxes(value: code),
            const SizedBox(height: 20),
            Center(
              child: Text('Resend code in 0:24', style: AppTheme.sans(size: 16, weight: FontWeight.w800, color: AppColors.coral)),
            ),
            const SizedBox(height: 24),
            AppKeypad(
              onPress: (d) => setState(() => code = code.length < 4 ? code + d : code),
              onDelete: () => setState(() => code = code.isEmpty ? code : code.substring(0, code.length - 1)),
            ),
            const SizedBox(height: 16),
            AppButton(
              size: AppButtonSize.xl,
              onPressed: code.length >= 4 && !verifying ? _verify : null,
              child: verifying
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
