import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/app_button.dart';
import '../../widgets/primitives.dart';
import '../../widgets/error_view.dart';
import 'providers/addresses_provider.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  void _addAddress(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController();
    final lineCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add address', style: AppTheme.display(size: 18, weight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. Home)')),
              const SizedBox(height: 12),
              TextField(controller: lineCtrl, decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 20),
              AppButton(
                full: true,
                size: AppButtonSize.lg,
                onPressed: () async {
                  if (lineCtrl.text.trim().isEmpty) return;
                  await AddressesNotifier.add(labelCtrl.text.trim().isEmpty ? 'Address' : labelCtrl.text.trim(), lineCtrl.text.trim());
                  ref.invalidate(addressesProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save address'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppScreenHeader(
        title: 'Saved addresses',
        trailing: IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _addAddress(context, ref)),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No saved addresses yet. Tap + to add one.', textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.ink50)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final a = addresses[i];
              return AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(11)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.coral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(a.label ?? 'Address', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                            if (a.isDefault) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(6)),
                                child: Text('DEFAULT', style: AppTheme.sans(size: 9, weight: FontWeight.w700, color: AppColors.ink50)),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 3),
                          Text(a.addressLine, style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.ink35),
                      onPressed: () async {
                        await AddressesNotifier.remove(a.id);
                        ref.invalidate(addressesProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(error: e, onRetry: () => ref.invalidate(addressesProvider)),
      ),
    );
  }
}
