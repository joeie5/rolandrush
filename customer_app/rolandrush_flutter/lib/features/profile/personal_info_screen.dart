import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_view.dart';
import 'providers/customer_profile_provider.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(customerProfileProvider);

    return Scaffold(
      appBar: const AppScreenHeader(title: 'Personal information'),
      body: profileAsync.when(
        data: (profile) {
          if (!_loaded) {
            _name.text = profile?.displayName ?? '';
            _email.text = profile?.email ?? '';
            _loaded = true;
          }
          return AppScreenBody(
            padding: const EdgeInsets.all(20),
            footer: AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      final userId = SupabaseService.currentUserId;
                      if (userId != null) {
                        await SupabaseService.client.from('customer_profiles').upsert({
                          'user_id': userId,
                          'full_name': _name.text.trim(),
                          'email': _email.text.trim(),
                        }, onConflict: 'user_id');
                        ref.invalidate(customerProfileProvider);
                      }
                      if (mounted) setState(() => _saving = false);
                    },
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save changes'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('Full name', _name),
                const SizedBox(height: 16),
                _field('Email', _email),
                const SizedBox(height: 16),
                Text('Phone', style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.ink35)),
                const SizedBox(height: 6),
                Text(profile?.phone ?? SupabaseService.client.auth.currentUser?.phone ?? '—',
                    style: AppTheme.sans(size: 15, weight: FontWeight.w600)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(customerProfileProvider)),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.ink35)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTheme.sans(size: 15, weight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.line)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
