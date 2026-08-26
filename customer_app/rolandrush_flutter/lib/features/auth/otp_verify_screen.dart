import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/keypad.dart';
import 'providers/auth_provider.dart';

const _length = 5;

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String code = '';
  int seconds = 42;
  Timer? timer;
  bool verifying = false;
  String? error;

  bool get complete => code.length == _length;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onKey(String k) {
    setState(() {
      if (k == 'del') {
        if (code.isNotEmpty) code = code.substring(0, code.length - 1);
      } else if (code.length < _length) {
        code += k;
      }
    });
  }

  Future<void> _verify() async {
    setState(() {
      verifying = true;
      error = null;
    });
    final ok = await ref.read(authProvider.notifier).verifyOtp(widget.phone, code);
    if (!mounted) return;
    setState(() => verifying = false);
    if (ok) {
      context.go('/home');
    } else {
      final authState = ref.read(authProvider);
      setState(() => error = authState.hasError ? authState.error.toString() : 'Incorrect or expired code.');
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
              child: IconButton(icon: const Icon(Icons.chevron_left, size: 22), onPressed: () => context.pop()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter your code', style: AppTheme.display(size: 28, weight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: AppTheme.sans(size: 14, color: AppColors.ink50),
                        children: [
                          const TextSpan(text: 'Sent to '),
                          TextSpan(text: widget.phone, style: AppTheme.sans(size: 14, weight: FontWeight.w700, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: List.generate(_length, (i) {
                        final filled = i < code.length;
                        final active = i == code.length;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == _length - 1 ? 0 : 10),
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: filled ? AppColors.canvas : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.btn),
                              border: Border.all(
                                  color: filled ? AppColors.ink : (active ? AppColors.coral : AppColors.line), width: 2),
                            ),
                            child: Text(i < code.length ? code[i] : '', style: AppTheme.display(size: 24, weight: FontWeight.w800)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    seconds > 0
                        ? Text.rich(
                            TextSpan(
                              style: AppTheme.sans(size: 13, color: AppColors.ink50),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                    text: '0:${seconds.toString().padLeft(2, '0')}',
                                    style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.ink)),
                              ],
                            ),
                          )
                        : TextButton(
                            onPressed: () => setState(() {
                              seconds = 42;
                              _startTimer();
                            }),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                            child: Text('Resend code', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.coral)),
                          ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: AppTheme.sans(size: 12, color: AppColors.coral)),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      full: true,
                      size: AppButtonSize.lg,
                      onPressed: complete && !verifying ? _verify : null,
                      child: verifying
                          ? const SizedBox(
                              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Verify & continue'),
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
