import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import 'providers/vendor_auth_provider.dart';

const _length = 6;

class VendorOtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const VendorOtpScreen({super.key, required this.phone});

  @override
  ConsumerState<VendorOtpScreen> createState() => _VendorOtpScreenState();
}

class _VendorOtpScreenState extends ConsumerState<VendorOtpScreen> {
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());
  int seconds = 24;
  Timer? timer;
  bool verifying = false;
  String? error;

  String get code => _controllers.map((c) => c.text).join();
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      verifying = true;
      error = null;
    });
    final ok = await ref.read(vendorAuthProvider.notifier).verifyOtp(widget.phone, code);
    if (!mounted) return;
    setState(() => verifying = false);
    if (ok) {
      context.go('/dashboard');
    } else {
      final authState = ref.read(vendorAuthProvider);
      setState(() => error = authState.hasError ? authState.error.toString() : 'Incorrect or expired code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Verify your number', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the 6-digit code', style: AppTheme.num(size: 24, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTheme.sans(size: 14, color: AppColors.inkMuted),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(text: widget.phone, style: AppTheme.num(size: 14, weight: FontWeight.w700, color: AppColors.ink)),
                  const TextSpan(text: ' by SMS.'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: List.generate(_length, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == _length - 1 ? 0 : 8),
                    height: 58,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTheme.num(size: 24, weight: FontWeight.w800),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.ink, width: 1.5)),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < _length - 1) _focusNodes[i + 1].requestFocus();
                        if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            seconds > 0
                ? Text.rich(TextSpan(style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted), children: [
                    const TextSpan(text: 'Resend code in '),
                    TextSpan(text: '0:${seconds.toString().padLeft(2, '0')}', style: AppTheme.num(size: 13, color: AppColors.ink)),
                  ]))
                : TextButton(
                    onPressed: () => setState(() {
                      seconds = 24;
                      _startTimer();
                    }),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                    child: Text('Resend code', style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.ink)),
                  ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: AppTheme.sans(size: 12, color: AppColors.coral)),
            ],
            const Spacer(),
            AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: complete && !verifying ? _verify : null,
              child: verifying
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Continue'),
            ),
            const SizedBox(height: 12),
            Center(child: Text('Having trouble? Call vendor support on 0700 ROLAND.', style: AppTheme.sans(size: 12, color: AppColors.inkSubtle))),
          ],
        ),
      ),
    );
  }
}
