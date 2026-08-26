import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/keypad.dart';
import '../../widgets/wordmark.dart';
import 'providers/auth_provider.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  String digits = '';
  bool sending = false;
  String? error;

  bool get valid => digits.length == 10;

  String get _formatted {
    final a = digits.substring(0, digits.length.clamp(0, 3));
    final b = digits.length > 3 ? digits.substring(3, digits.length.clamp(3, 6)) : '';
    final c = digits.length > 6 ? digits.substring(6, digits.length.clamp(6, 10)) : '';
    return [a, b, c].where((s) => s.isNotEmpty).join(' ');
  }

  void _onKey(String k) {
    setState(() {
      if (k == 'del') {
        if (digits.isNotEmpty) digits = digits.substring(0, digits.length - 1);
      } else if (digits.length < 10) {
        digits += k;
      }
    });
  }

  Future<void> _sendCode() async {
    setState(() {
      sending = true;
      error = null;
    });
    final e164 = '+234$digits';
    final ok = await ref.read(authProvider.notifier).sendOtp(e164);
    if (!mounted) return;
    setState(() => sending = false);
    if (ok) {
      context.push('/otp', extra: e164);
    } else {
      setState(() => error = 'Could not send code. Check the SMS provider is configured.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                onPressed: () => context.go('/onboarding'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(size: 44),
                    const SizedBox(height: 20),
                    Text("What's your number?", style: AppTheme.display(size: 28, weight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text("We'll text you a code. No password to remember.",
                        style: AppTheme.sans(size: 14, color: AppColors.ink50)),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.ink, width: 2))),
                      child: Row(
                        children: [
                          Text('🇳🇬 +234', style: AppTheme.display(size: 20, weight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Text(
                            digits.isEmpty ? '803 000 0000' : _formatted,
                            style: AppTheme.display(
                                size: 22, weight: FontWeight.w700, color: digits.isEmpty ? AppColors.ink35 : AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text("By continuing you agree to RolandRush's Terms and Privacy Policy.",
                        style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: AppTheme.sans(size: 12, color: AppColors.coral)),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      full: true,
                      size: AppButtonSize.lg,
                      onPressed: valid && !sending ? _sendCode : null,
                      child: sending
                          ? const SizedBox(
                              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Send code'),
                    ),
                  ],
                ),
              ),
            ),
            Keypad(onKey: _onKey),
          ],
        ),
      ),
    );
  }
}
