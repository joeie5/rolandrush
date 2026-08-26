import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/delivery_order.dart';
import '../../widgets/app_button.dart';
import '../../widgets/step_progress.dart';
import 'providers/active_delivery_provider.dart';

/// Ports ActiveDelivery.tsx. No Google Maps API key is configured in this
/// environment (checked pubspec — google_maps_flutter/geolocator are
/// present as deps, ready to wire up once a key exists), so this shows
/// real pickup/dropoff addresses instead of a fake static map image. Swap
/// the placeholder panel below for a real GoogleMap widget plotting
/// order.deliveryLat/Lng once GOOGLE_MAPS_API_KEY is available.
class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  bool expanded = true;

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final activeOrderAsync = ref.watch(riderActiveOrderProvider);

    return activeOrderAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Could not load delivery: $e'))),
      data: (order) {
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 56, color: AppColors.inkFaint),
                    const SizedBox(height: 16),
                    Text('No active delivery', style: AppTheme.sans(size: 24, weight: FontWeight.w800, letterSpacing: -0.6)),
                    const SizedBox(height: 20),
                    AppButton(fullWidth: false, onPressed: () => context.go('/jobs'), child: const Text('Find an order')),
                  ],
                ),
              ),
            ),
          );
        }
        return _DeliveryBody(orderId: order.id, call: _call, expanded: expanded, onToggleExpanded: () => setState(() => expanded = !expanded));
      },
    );
  }
}

class _DeliveryBody extends ConsumerWidget {
  final String orderId;
  final Future<void> Function(String?) call;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  const _DeliveryBody({required this.orderId, required this.call, required this.expanded, required this.onToggleExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeDeliveryProvider(orderId));
    final order = state.order;
    if (order == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isPickupPhase = order.currentStep.value <= 2;
    final heading = isPickupPhase ? 'Pick up from' : 'Deliver to';
    final placeName = isPickupPhase ? order.restaurantName : order.customerName;
    final placeArea = isPickupPhase ? (order.pickupAddress ?? '') : (order.deliveryAddress ?? '');
    final phone = isPickupPhase ? null : order.customerPhone;
    final actionLabel = switch (order.currentStep) {
      DeliveryStep.enRoute => "I've arrived at pickup",
      DeliveryStep.pickup => 'Order picked up',
      DeliveryStep.delivering => 'Enter delivery code',
      DeliveryStep.delivered => 'Delivered',
    };
    final actionVariant = switch (order.currentStep) {
      DeliveryStep.enRoute => AppButtonVariant.alert,
      DeliveryStep.pickup => AppButtonVariant.primary,
      _ => AppButtonVariant.success,
    };

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    onTap: () => context.go('/home'),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.btn)),
                      child: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: StepProgress(step: order.currentStep)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.canvas,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined, size: 56, color: AppColors.inkFaint),
                      const SizedBox(height: 12),
                      Text('Live map requires a Google Maps API key', textAlign: TextAlign.center, style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.inkMuted)),
                      const SizedBox(height: 4),
                      Text('${order.currentStep.label} · showing real order addresses below', textAlign: TextAlign.center, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkFaint)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: AppShadows.sheet),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onToggleExpanded,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${stepLabels[order.currentStep.value - 1].toUpperCase()}', style: AppTheme.sans(size: 13, weight: FontWeight.w800, color: AppColors.alert, letterSpacing: 0.4)),
                            Text('$heading $placeName', style: AppTheme.sans(size: 24, weight: FontWeight.w800, letterSpacing: -0.6)),
                          ],
                        ),
                      ),
                      Icon(expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, size: 28),
                    ],
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: AppColors.inkMuted),
                    const SizedBox(width: 6),
                    Expanded(child: Text(placeArea, style: AppTheme.sans(size: 16, weight: FontWeight.w600, color: AppColors.inkMuted))),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('YOU EARN', style: AppTheme.sans(size: 14, weight: FontWeight.w800, color: AppColors.inkMuted, letterSpacing: 0.4)),
                        Text(naira(order.deliveryFee), style: AppTheme.sans(size: 26, weight: FontWeight.w800, color: AppColors.online, letterSpacing: -0.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => call(phone),
                        icon: const Icon(Icons.phone_outlined),
                        label: Text(isPickupPhase ? 'Call store' : 'Call customer'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64), side: const BorderSide(color: AppColors.line, width: 2), foregroundColor: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.btn)),
                      child: const Icon(Icons.navigation_outlined, color: Colors.white),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ],
                AppButton(
                  size: AppButtonSize.xl,
                  variant: actionVariant,
                  onPressed: state.isUpdatingStep
                      ? null
                      : () {
                          if (order.currentStep.value >= 3) {
                            context.push('/delivery/confirm');
                          } else {
                            ref.read(activeDeliveryProvider(orderId).notifier).advanceStep();
                          }
                        },
                  child: state.isUpdatingStep
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
