import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/primitives.dart';
import 'providers/vendor_auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  bool sending = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLockup(tagline: 'Run your restaurant'),
              const SizedBox(height: 40),
              Text('Welcome back.', style: AppTheme.num(size: 30, weight: FontWeight.w800)),
              Text('Let\'s get cooking.', style: AppTheme.num(size: 30, weight: FontWeight.w800, color: AppColors.inkMuted)),
              const SizedBox(height: 12),
              Text(
                'Enter the phone number registered to your restaurant. We\'ll text you a 6-digit code.',
                style: AppTheme.sans(size: 14, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 28),
              AppField(
                label: 'Phone number',
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.lineStrong), borderRadius: BorderRadius.circular(AppRadius.btn)),
                      alignment: Alignment.center,
                      child: Text('+234', style: AppTheme.num(size: 15, weight: FontWeight.w700, color: AppColors.inkMuted)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextInput(
                        controller: _controller,
                        placeholder: '803 220 1194',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: AppTheme.sans(size: 12, color: AppColors.coral)),
              ],
              const SizedBox(height: 20),
              AppButton(
                full: true,
                size: AppButtonSize.lg,
                onPressed: sending ? null : _sendCode,
                child: sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send code'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.good),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your wallet and payout details are protected. RolandRush never asks for your bank password or card PIN.',
                        style: AppTheme.sans(size: 12, color: AppColors.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.sans(size: 14, color: AppColors.inkMuted),
                    children: [
                      const TextSpan(text: 'New to RolandRush? '),
                      TextSpan(
                        text: 'Register your restaurant',
                        style: AppTheme.sans(size: 14, weight: FontWeight.w700, color: AppColors.coral),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/signup'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    final digits = _controller.text;
    if (digits.length != 10) {
      setState(() => error = 'Enter a valid 10-digit phone number.');
      return;
    }
    setState(() {
      sending = true;
      error = null;
    });
    final e164 = '+234$digits';
    final ok = await ref.read(vendorAuthProvider.notifier).sendOtp(e164);
    if (!mounted) return;
    setState(() => sending = false);
    if (ok) {
      context.push('/otp', extra: e164);
    } else {
      setState(() => error = 'Could not send code. Check the SMS provider is configured.');
    }
  }
}
