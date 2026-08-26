import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/delivery_order.dart';
import 'providers/available_orders_provider.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
const _brandRed = Color(0xFFE53935);

class AvailableOrdersScreen extends ConsumerWidget {
  final void Function(String orderId) onAcceptOrder;
  final VoidCallback onBack;

  const AvailableOrdersScreen({super.key, required this.onAcceptOrder, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availableOrdersProvider);
    final notifier = ref.read(availableOrdersProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: onBack),
        title: const Text('Available Orders', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black54), onPressed: notifier.load),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(state, notifier),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text('Could not load orders: ${state.error}'))
                    : state.filtered.isEmpty
                        ? const Center(child: Text('No available orders right now'))
                        : RefreshIndicator(
                            onRefresh: notifier.load,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.filtered.length,
                              itemBuilder: (context, i) => _OrderCard(
                                order: state.filtered[i],
                                onAccept: () => onAcceptOrder(state.filtered[i].id),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AvailableOrdersState state, AvailableOrdersNotifier notifier) {
    Widget chip(String label, OrderFilter value, IconData icon) {
      final selected = state.filter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          avatar: Icon(icon, size: 16, color: selected ? Colors.white : Colors.black54),
          selected: selected,
          selectedColor: _brandRed,
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
          onSelected: (_) => notifier.setFilter(value),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          chip('All', OrderFilter.all, Icons.list),
          chip('Nearby', OrderFilter.nearby, Icons.near_me),
          chip('High Pay', OrderFilter.highPay, Icons.trending_up),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onAccept;

  const _OrderCard({required this.order, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (order.pickupAddress != null)
                        Text(order.pickupAddress!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Text(_naira.format(order.deliveryFee),
                    style: const TextStyle(color: _brandRed, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(Icons.receipt_long, '${order.items.length} items'),
                _infoChip(Icons.payments_outlined, _naira.format(order.totalAmount)),
                if (order.deliveryAddress != null)
                  Expanded(
                    child: _infoChip(Icons.location_on_outlined, order.deliveryAddress!, truncate: true),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _brandRed, minimumSize: const Size.fromHeight(46)),
                onPressed: onAccept,
                child: const Text('Accept Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {bool truncate = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: truncate ? TextOverflow.ellipsis : TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
