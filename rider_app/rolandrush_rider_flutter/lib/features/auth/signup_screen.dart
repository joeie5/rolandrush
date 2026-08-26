import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../core/supabase_service.dart';
import 'providers/rider_auth_provider.dart';

/// Ports Signup.tsx. Document "upload" here is a picker-only preview (no
/// storage backend for rider documents exists — see Documents screen for
/// the full explanation) — this step just records which doc types the
/// rider says they'll provide; the actual files aren't persisted.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController(text: '');
  final emailController = TextEditingController();
  final cityController = TextEditingController(text: 'Osogbo, Osun State');
  final bankController = TextEditingController();
  final accountController = TextEditingController();
  String vehicle = 'Motorcycle';
  bool submitting = false;

  static const _vehicles = [
    ('Motorcycle', Icons.two_wheeler_rounded),
    ('Car', Icons.directions_car_rounded),
    ('On foot', Icons.directions_walk_rounded),
  ];

  Future<void> _submit() async {
    if (nameController.text.trim().isEmpty || submitting) return;
    setState(() => submitting = true);
    final ok = await ref.read(riderAuthProvider.notifier).registerRiderProfile(
          fullName: nameController.text.trim(),
          email: emailController.text.trim(),
          address: cityController.text.trim(),
          phoneNumber: SupabaseService.client.auth.currentUser?.phone ?? '',
          vehicleType: vehicle,
          bankName: bankController.text.trim(),
          accountNumber: accountController.text.trim(),
        );
    if (!mounted) return;
    setState(() => submitting = false);
    if (ok) {
      context.go('/auth/verification');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit. Try again.')));
    }
  }

  Widget _field(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.line, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: 0.4)),
          TextField(
            controller: controller,
            style: AppTheme.sans(size: 19, weight: FontWeight.w800),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t.toUpperCase(), style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
      );

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Set up your account',
      subtitle: 'Step 2 of 2',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionTitle('Your details'),
          Column(children: [_field('Full name', nameController), const SizedBox(height: 10), _field('Email', emailController), const SizedBox(height: 10), _field('City', cityController)]),
          const SizedBox(height: 24),
          _sectionTitle('Vehicle type'),
          Row(
            children: _vehicles.map((v) {
              final active = vehicle == v.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () => setState(() => vehicle = v.$1),
                    child: Container(
                      height: 104,
                      decoration: BoxDecoration(
                        color: active ? AppColors.coralSoft : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: active ? AppColors.coral : AppColors.line, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(v.$2, size: 32, color: active ? AppColors.coral : AppColors.inkMuted),
                          const SizedBox(height: 6),
                          Text(v.$1, style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: active ? AppColors.coral : AppColors.inkMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Documents'),
          const _DocumentPreviewPicker(label: "Driver's licence"),
          const SizedBox(height: 10),
          const _DocumentPreviewPicker(label: 'NIN slip'),
          const SizedBox(height: 10),
          const _DocumentPreviewPicker(label: 'Vehicle registration'),
          const SizedBox(height: 24),
          _sectionTitle('Payout account'),
          Column(children: [_field('Bank', bankController), const SizedBox(height: 10), _field('Account number', accountController)]),
          const SizedBox(height: 24),
          AppButton(
            size: AppButtonSize.xl,
            onPressed: submitting ? null : _submit,
            child: submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit for review'),
          ),
        ],
      ),
    );
  }
}

/// Picker-only preview — no upload backend for rider documents exists
/// (the only presigned-upload Edge Function, `generate-upload-url`, is
/// gated to vendor_profiles/menu media). Selecting a file here just shows
/// a local filename; nothing is sent anywhere. Real document storage is a
/// backend follow-up.
class _DocumentPreviewPicker extends StatefulWidget {
  final String label;
  const _DocumentPreviewPicker({required this.label});

  @override
  State<_DocumentPreviewPicker> createState() => _DocumentPreviewPickerState();
}

class _DocumentPreviewPickerState extends State<_DocumentPreviewPicker> {
  String? fileName;

  @override
  Widget build(BuildContext context) {
    final done = fileName != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: done ? AppColors.onlineSoft : AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.btn)),
            child: Icon(done ? Icons.check_rounded : Icons.upload_rounded, color: done ? AppColors.online : AppColors.inkFaint),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.label, style: AppTheme.sans(size: 17, weight: FontWeight.w700))),
          InkWell(
            onTap: () => setState(() => fileName = '${widget.label.toLowerCase().replaceAll(' ', '_')}.jpg'),
            child: Text(done ? 'Selected' : 'Upload', style: AppTheme.sans(size: 15, weight: FontWeight.w800, color: done ? AppColors.online : AppColors.coral)),
          ),
        ],
      ),
    );
  }
}
