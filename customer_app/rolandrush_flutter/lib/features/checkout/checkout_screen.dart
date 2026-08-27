import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_screen.dart';
import '../cart/providers/cart_provider.dart';
import '../restaurants/providers/restaurants_provider.dart';
import '../profile/providers/addresses_provider.dart';
import '../profile/providers/customer_profile_provider.dart';
import '../../core/providers/platform_settings_provider.dart';
import '../../widgets/error_view.dart';
import 'providers/checkout_provider.dart';

const _paymentOptions = ['Cash on delivery', 'Card on file', 'Bank transfer'];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String payment = _paymentOptions[0];
  bool placing = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final grouped = ref.read(cartProvider.notifier).groupedByVendor;
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final settingsAsync = ref.watch(platformSettingsProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final feeByCity = ref.watch(deliveryFeeByCityProvider).maybeWhen(data: (m) => m, orElse: () => <String, double>{});
    final blocked = profileAsync.maybeWhen(data: (p) => p != null && !p.canOrder, orElse: () => false);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppScreenHeader(title: 'Checkout', onBack: () => context.pop()),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Text('Your cart is empty — add a dish from the feed to check out.',
              textAlign: TextAlign.center, style: AppTheme.sans(size: 14, color: AppColors.ink50)),
        ),
      );
    }

    final subtotal = items.fold<double>(0, (s, c) => s + c.lineTotal);

    return restaurantsAsync.when(
      data: (restaurants) {
        double delivery = 0;
        for (final vendorId in grouped.keys) {
          final r = restaurants.where((r) => r.id == vendorId);
          if (r.isEmpty) continue;
          final ruleFee = feeByCity[r.first.city];
          delivery += ruleFee ?? r.first.deliveryFee;
        }
        final serviceFeeRate = settingsAsync.maybeWhen(
          data: (s) => platformSettingDouble(s, 'service_fee_rate', 0.10),
          orElse: () => 0.10,
        );
        final serviceFee = (subtotal * serviceFeeRate).roundToDouble();
        final total = subtotal + delivery + serviceFee;

        return addressesAsync.when(
          data: (addresses) {
            final address = addresses.isNotEmpty ? addresses.first : null;

            return Scaffold(
              appBar: AppScreenHeader(
                title: 'Checkout',
                subtitle: '${grouped.length} vendor group${grouped.length == 1 ? '' : 's'}',
                onBack: () => context.pop(),
              ),
              body: AppScreenBody(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                footer: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total to pay', style: AppTheme.sans(size: 13, color: AppColors.ink50)),
                        Text(naira(total), style: AppTheme.display(size: 22, weight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (blocked)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Your account is ${profileAsync.value?.status ?? 'restricted'} and can\'t place orders right now. Contact support for help.',
                          textAlign: TextAlign.center,
                          style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.coral),
                        ),
                      ),
                    AppButton(
                      full: true,
                      size: AppButtonSize.lg,
                      onPressed: placing || blocked
                          ? null
                          : () async {
                              setState(() => placing = true);
                              final ids = await ref.read(checkoutProvider.notifier).placeOrder(
                                    deliveryAddress: address?.addressLine ?? 'Oke Baale, Osogbo',
                                    paymentMethod: payment,
                                  );
                              if (!mounted) return;
                              setState(() => placing = false);
                              if (ids.isNotEmpty) {
                                context.go('/tracking/${ids.first}');
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Could not place order — try again')));
                              }
                            },
                      child: placing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Place order'),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _row(
                      icon: Icons.location_on_outlined,
                      label: 'DELIVER TO',
                      tag: address?.label ?? 'Home',
                      title: address?.addressLine ?? 'Oke Baale, Osogbo',
                      hint: addresses.isEmpty ? 'No saved addresses yet' : null,
                      onTap: () => context.push('/profile/addresses'),
                    ),
                    const SizedBox(height: 12),
                    _row(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'PAYMENT',
                      tag: null,
                      title: payment,
                      onTap: () => _pickPayment(context),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _summaryRow('Subtotal', naira(subtotal)),
                          const SizedBox(height: 8),
                          _summaryRow('Delivery', naira(delivery)),
                          const SizedBox(height: 8),
                          _summaryRow('Service fee', naira(serviceFee)),
                          Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 1, color: AppColors.line),
                          _summaryRow('Total', naira(total), bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: AppErrorView(error: e, onRetry: () => ref.invalidate(addressesProvider))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: AppErrorView(error: e, onRetry: () => ref.invalidate(restaurantsProvider))),
    );
  }

  void _pickPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _paymentOptions
                .map((p) => ListTile(
                      title: Text(p, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                      trailing: payment == p ? const Icon(Icons.check_rounded, color: AppColors.coral) : null,
                      onTap: () {
                        setState(() => payment = p);
                        Navigator.of(ctx).pop();
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    String? tag,
    required String title,
    String? hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.coralSoft, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.coral),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.ink35).copyWith(letterSpacing: 1)),
                      if (tag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(6)),
                          child: Text(tag, style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.ink50)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  if (hint != null)
                    Padding(padding: const EdgeInsets.only(top: 2), child: Text(hint, style: AppTheme.sans(size: 12, color: AppColors.ink35))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.ink35),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color, bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTheme.display(size: 14, weight: FontWeight.w700) : AppTheme.sans(size: 13, color: AppColors.ink50)),
          Text(value, style: bold ? AppTheme.display(size: 15, weight: FontWeight.w800) : AppTheme.sans(size: 13, weight: FontWeight.w600, color: color ?? AppColors.ink)),
        ],
      );
}
