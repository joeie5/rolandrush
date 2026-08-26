import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../../widgets/error_view.dart';
import '../restaurants/providers/restaurants_provider.dart';
import 'providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final grouped = ref.read(cartProvider.notifier).groupedByVendor;
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final itemCount = items.fold<int>(0, (s, c) => s + c.quantity);
    final subtotal = items.fold<double>(0, (s, c) => s + c.lineTotal);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppScreenHeader(title: 'Your cart', onBack: () => context.go('/feed')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
                  child: const Icon(Icons.shopping_bag_outlined, size: 28, color: AppColors.ink35),
                ),
                const SizedBox(height: 20),
                Text('Nothing in the bag yet', style: AppTheme.display(size: 19, weight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Head back to the feed — tap the bag on any dish you like and it lands here.',
                    textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.ink50)),
                const SizedBox(height: 24),
                AppButton(
                  size: AppButtonSize.lg,
                  onPressed: () => context.go('/feed'),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_arrow_rounded, size: 16), SizedBox(width: 6), Text('Open the feed'),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return restaurantsAsync.when(
      data: (restaurants) {
        double delivery = 0;
        for (final vendorId in grouped.keys) {
          final r = restaurants.where((r) => r.id == vendorId);
          if (r.isNotEmpty) delivery += r.first.deliveryFee;
        }

        return Scaffold(
          appBar: AppScreenHeader(
            title: 'Your cart',
            subtitle: '$itemCount item${itemCount == 1 ? '' : 's'} · ${grouped.length} vendor${grouped.length == 1 ? '' : 's'}',
            onBack: () => context.go('/feed'),
            trailing: TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text('Clear', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.ink35)),
            ),
          ),
          body: AppScreenBody(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _row('Subtotal', naira(subtotal)),
                const SizedBox(height: 6),
                _row('Delivery (${grouped.length} vendor${grouped.length == 1 ? '' : 's'})', naira(delivery)),
                Container(margin: const EdgeInsets.symmetric(vertical: 12), height: 1, color: AppColors.line),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTheme.display(size: 15, weight: FontWeight.w700)),
                    Text(naira(subtotal + delivery), style: AppTheme.display(size: 20, weight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton(full: true, size: AppButtonSize.lg, onPressed: () => context.push('/checkout'), child: const Text('Go to checkout')),
              ],
            ),
            child: Column(
              children: [
                for (final entry in grouped.entries)
                  _VendorGroup(
                    vendorId: entry.key,
                    lines: entry.value,
                    vendorName: entry.value.first.vendorName,
                    deliveryFee: restaurants.where((r) => r.id == entry.key).isNotEmpty
                        ? restaurants.firstWhere((r) => r.id == entry.key).deliveryFee
                        : 0,
                  ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.go('/feed'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: const Color(0xFFD8D8D8), style: BorderStyle.solid),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 15, color: AppColors.ink50),
                        const SizedBox(width: 6),
                        Text('Add from another kitchen', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.ink50)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantsProvider))),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
          Text(value, style: AppTheme.sans(size: 13, color: AppColors.ink50)),
        ],
      );
}

class _VendorGroup extends ConsumerWidget {
  final String vendorId;
  final String vendorName;
  final double deliveryFee;
  final List lines;
  const _VendorGroup({required this.vendorId, required this.vendorName, required this.deliveryFee, required this.lines});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupSubtotal = lines.fold<double>(0, (s, l) => s + l.lineTotal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push('/restaurant/$vendorId'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                child: Row(
                  children: [
                    InitialsAvatar(name: vendorName, color: AppColors.ink, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendorName, style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                          Text('Delivery ${naira(deliveryFee)}', style: AppTheme.sans(size: 12, color: AppColors.ink35)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: lines
                    .map<Widget>((line) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: line.imageUrl != null
                                    ? Image.network(line.imageUrl!, width: 62, height: 62, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 62, height: 62, color: AppColors.line))
                                    : Container(width: 62, height: 62, color: AppColors.line),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(line.name, style: AppTheme.display(size: 14, weight: FontWeight.w800)),
                                    if (line.selectedAddOns.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          line.selectedAddOns.map((a) => '${a.quantity}× ${a.name}').join(', '),
                                          style: AppTheme.sans(size: 12, color: AppColors.ink35),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(naira(line.lineTotal), style: AppTheme.display(size: 15, weight: FontWeight.w800)),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => ref.read(cartProvider.notifier).remove(line.menuItemId),
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.ink35),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                            const SizedBox(width: 8),
                                            _Stepper(
                                              value: line.quantity,
                                              onChanged: (v) => ref.read(cartProvider.notifier).updateQuantity(line.menuItemId, v),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: AppColors.canvas),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vendor subtotal', style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                  Text(naira(groupSubtotal), style: AppTheme.display(size: 14, weight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, () => onChanged(value - 1)),
          SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center, style: AppTheme.sans(size: 13, weight: FontWeight.w700))),
          _btn(Icons.add_rounded, () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 14, color: AppColors.ink50)),
      );
}
