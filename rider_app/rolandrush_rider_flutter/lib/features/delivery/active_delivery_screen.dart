import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/delivery_order.dart';
import 'providers/active_delivery_provider.dart';
import 'widgets/delivery_otp_sheet.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
const _brandRed = Color(0xFFE53935);
const _brandBlue = Color(0xFF1E88E5);

class ActiveDeliveryScreen extends ConsumerWidget {
  final String orderId;
  final VoidCallback onComplete;

  const ActiveDeliveryScreen({super.key, required this.orderId, required this.onComplete});

  Future<void> _call(String? phone) async {
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _handleNextStep(BuildContext context, WidgetRef ref, DeliveryOrder order) async {
    final notifier = ref.read(activeDeliveryProvider(orderId).notifier);

    // Final step requires OTP confirmation instead of a plain tap-through —
    // see delivery_otp_sheet.dart for why this was added vs. the Figma mock.
    final isLastStep = order.currentStep == DeliveryStep.delivering;
    if (isLastStep) {
      final entered = await showDeliveryOtpSheet(context);
      if (entered == null || entered.isEmpty) return;
      final ok = await notifier.confirmDeliveryWithOtp(entered);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect code. Ask the customer to double-check it.')),
        );
        return;
      }
      if (ok) onComplete();
      return;
    }

    await notifier.advanceStep();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeDeliveryProvider(orderId));
    final order = state.order;

    if (state.isLoading || order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildTopBar(order),
          Expanded(child: _buildMapPlaceholder(order)),
          _buildBottomSheet(context, ref, order, state.isUpdatingStep),
        ],
      ),
    );
  }

  Widget _buildTopBar(DeliveryOrder order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_brandRed, Color(0xFFD32F2F)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.orderNumber}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('Active Delivery', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(DeliveryOrder order) {
    // Swap for a real google_maps_flutter GoogleMap widget once API keys
    // are wired up — plotting order.deliveryLat/deliveryLng and the
    // rider's live position from rider_profiles.last_lat/last_lng.
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Map view — ${order.currentStep.label}', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, WidgetRef ref, DeliveryOrder order, bool isUpdating) {
    final isPickupPhase = order.currentStep.value <= 2;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: 40,
                  child: Divider(thickness: 4),
                ),
              ),
              _buildStepProgress(order.currentStep),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildContactCard(order, isPickupPhase),
                    const SizedBox(height: 12),
                    _buildItemsCard(order),
                    const SizedBox(height: 12),
                    _buildEarningsCard(order),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _brandRed, minimumSize: const Size.fromHeight(52)),
                    onPressed: isUpdating ? null : () => _handleNextStep(context, ref, order),
                    child: isUpdating
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_buttonLabel(order.currentStep)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buttonLabel(DeliveryStep step) {
    switch (step) {
      case DeliveryStep.enRoute:
        return "I've Arrived at Restaurant";
      case DeliveryStep.pickup:
        return 'Confirm Pickup';
      case DeliveryStep.delivering:
        return "I've Arrived — Enter Delivery Code";
      case DeliveryStep.delivered:
        return 'Delivered';
    }
  }

  Widget _buildStepProgress(DeliveryStep current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: DeliveryStep.values.map((step) {
          final isDone = current.value > step.value;
          final isCurrent = current.value == step.value;
          final color = isDone || isCurrent ? _brandRed : Colors.grey.shade300;
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(radius: 14, backgroundColor: color, child: Text('${step.value}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                const SizedBox(height: 4),
                Text(step.label, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(DeliveryOrder order, bool isPickupPhase) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPickupPhase ? Colors.orange.shade100 : _brandBlue.withOpacity(0.1),
              child: Icon(isPickupPhase ? Icons.store : Icons.person, color: isPickupPhase ? Colors.orange : _brandBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPickupPhase ? order.restaurantName : order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    isPickupPhase ? (order.pickupAddress ?? '') : (order.deliveryAddress ?? ''),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _call(order.customerPhone),
              icon: const Icon(Icons.phone, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(DeliveryOrder order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}'),
                      Text(_naira.format(item.price)),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_naira.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(DeliveryOrder order) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Earnings', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(_naira.format(order.deliveryFee), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
