import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_screen.dart';
import 'providers/vendor_auth_provider.dart';

const _steps = ['Business', 'Documents', 'Payout'];
const _banks = ['Moniepoint MFB', 'Access Bank', 'GTBank', 'Opay', 'Zenith Bank'];

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  int step = 0;
  bool idUploaded = false;
  bool cacUploaded = false;
  bool submitting = false;

  final restaurantName = TextEditingController(text: '');
  final ownerName = TextEditingController(text: '');
  final phone = TextEditingController(text: '');
  final address = TextEditingController(text: '');
  final cacNumber = TextEditingController(text: '');
  final accountNumber = TextEditingController(text: '');
  String bank = _banks.first;

  void _back() {
    if (step == 0) {
      context.pop();
    } else {
      setState(() => step--);
    }
  }

  Future<void> _next() async {
    if (step < _steps.length - 1) {
      setState(() => step++);
      return;
    }
    setState(() => submitting = true);
    final ok = await ref.read(vendorAuthProvider.notifier).registerVendorProfile(
          restaurantName: restaurantName.text.trim(),
          ownerName: ownerName.text.trim(),
          phoneNumber: phone.text.trim(),
          address: address.text.trim(),
          cacNumber: cacNumber.text.trim(),
          bankName: bank,
          accountNumber: accountNumber.text.trim(),
        );
    if (!mounted) return;
    setState(() => submitting = false);
    if (ok) {
      context.push('/verification');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit — check you\'re signed in.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppScreenHeader(title: 'Register your restaurant', subtitle: 'Step ${step + 1} of ${_steps.length} · ${_steps[step]}', onBack: _back),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_steps.length, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 6),
                    decoration: BoxDecoration(color: i <= step ? AppColors.coral : AppColors.lineStrong, borderRadius: BorderRadius.circular(2)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step == 0) _businessStep(),
                  if (step == 1) _documentsStep(),
                  if (step == 2) _payoutStep(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: submitting ? null : _next,
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(step == _steps.length - 1 ? 'Submit for review' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell us about the business', style: AppTheme.num(size: 22, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('This is what customers see in the RolandRush feed.', style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
        const SizedBox(height: 20),
        AppField(label: 'Restaurant name', child: AppTextInput(controller: restaurantName, placeholder: 'e.g. Iya Basira Kitchen')),
        const SizedBox(height: 16),
        AppField(label: "Owner's full name", child: AppTextInput(controller: ownerName, placeholder: 'As written on your ID')),
        const SizedBox(height: 16),
        AppField(label: 'Phone number', child: AppTextInput(controller: phone, keyboardType: TextInputType.phone)),
        const SizedBox(height: 16),
        AppField(label: 'Street address', hint: 'Riders use this to find your kitchen.', child: AppTextArea(controller: address, rows: 2)),
      ],
    );
  }

  Widget _documentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your business', style: AppTheme.num(size: 22, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Required once. Reviews are usually done within 24 hours.', style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
        const SizedBox(height: 20),
        AppField(label: 'CAC registration number', hint: 'Format: RC 1234567. Not registered yet? Add this later.', child: AppTextInput(controller: cacNumber, placeholder: 'RC 1234567')),
        const SizedBox(height: 16),
        _uploadRow(icon: Icons.description_outlined, title: 'CAC certificate', detail: cacUploaded ? 'cac-certificate.pdf · 1.2 MB' : 'PDF or photo, max 5 MB', done: cacUploaded, onTap: () => setState(() => cacUploaded = true)),
        const SizedBox(height: 12),
        _uploadRow(icon: Icons.badge_outlined, title: "Owner's ID", detail: idUploaded ? 'nin-slip.jpg · 840 KB' : 'NIN slip, driver\'s licence or passport', done: idUploaded, onTap: () => setState(() => idUploaded = true)),
      ],
    );
  }

  Widget _payoutStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where should we pay you?', style: AppTheme.num(size: 22, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Order earnings land in your RolandRush wallet, then you withdraw to this account.', style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
        const SizedBox(height: 20),
        AppField(
          label: 'Bank',
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.btn), border: Border.all(color: AppColors.lineStrong)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: bank,
                isExpanded: true,
                items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: AppTheme.sans(size: 15)))).toList(),
                onChanged: (v) => setState(() => bank = v!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppField(label: 'Account number', child: AppTextInput(controller: accountNumber, keyboardType: TextInputType.number, maxLength: 10)),
      ],
    );
  }

  Widget _uploadRow({required IconData icon, required String title, required String detail, required bool done, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done ? AppColors.goodSoft : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: done ? AppColors.good.withOpacity(0.3) : AppColors.lineStrong, style: done ? BorderStyle.solid : BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: done ? AppColors.good : AppColors.canvas, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(done ? Icons.check : icon, size: 18, color: done ? Colors.white : AppColors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  Text(detail, style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                ],
              ),
            ),
            if (!done) const Icon(Icons.upload_rounded, size: 16, color: AppColors.inkSubtle),
          ],
        ),
      ),
    );
  }
}
