import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'rider_status_provider.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
const _brandRed = Color(0xFFE53935);

class HomeDashboardScreen extends ConsumerWidget {
  final VoidCallback onViewAvailableOrders;
  final VoidCallback onViewHistory;
  final VoidCallback onViewEarnings;
  final VoidCallback onViewProfile;

  const HomeDashboardScreen({
    super.key,
    required this.onViewAvailableOrders,
    required this.onViewHistory,
    required this.onViewEarnings,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rider = ref.watch(riderStatusProvider);
    final isOnline = rider?.isOnline ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${rider?.firstName ?? 'Rider'}!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _brandRed),
                    ),
                    if (rider?.vehicleType != null)
                      Text(rider!.vehicleType!, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                IconButton(onPressed: onViewProfile, icon: const Icon(Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 20),
            _buildOnlineToggle(context, ref, isOnline),
            const SizedBox(height: 20),
            if (isOnline) _buildAvailableOrdersCta(),
            const SizedBox(height: 20),
            _buildQuickNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineToggle(BuildContext context, WidgetRef ref, bool isOnline) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isOnline ? Colors.green.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.power_settings_new, color: isOnline ? Colors.green : Colors.grey),
                const SizedBox(width: 12),
                Text(isOnline ? 'You\'re Online' : 'You\'re Offline', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Switch(
              value: isOnline,
              activeColor: Colors.green,
              onChanged: (v) => ref.read(riderStatusProvider.notifier).setOnline(v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableOrdersCta() {
    return GestureDetector(
      onTap: onViewAvailableOrders,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_brandRed, Color(0xFFD32F2F)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('View Available Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNav() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _navCard(Icons.history, 'Order History', onViewHistory),
        _navCard(Icons.account_balance_wallet_outlined, 'Earnings', onViewEarnings),
      ],
    );
  }

  Widget _navCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: _brandRed),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
