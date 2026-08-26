import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class VendorBottomNav extends StatelessWidget {
  final String currentPath;
  final int newOrderCount;
  const VendorBottomNav({super.key, required this.currentPath, this.newOrderCount = 0});

  static const _tabs = [
    (path: '/dashboard', label: 'Home', icon: Icons.home_rounded),
    (path: '/orders', label: 'Orders', icon: Icons.receipt_long_rounded),
    (path: '/menu', label: 'Menu', icon: Icons.restaurant_menu_rounded),
    (path: '/wallet', label: 'Wallet', icon: Icons.account_balance_wallet_rounded),
    (path: '/account', label: 'Account', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: _tabs.map((t) {
            final active = currentPath == t.path;
            final color = active ? AppColors.coral : AppColors.inkSubtle;
            return Expanded(
              child: GestureDetector(
                onTap: () => context.go(t.path),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(t.icon, size: 21, color: color),
                        if (t.path == '/orders' && newOrderCount > 0)
                          Positioned(
                            right: -8,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text('$newOrderCount', style: AppTheme.num(size: 10, weight: FontWeight.w800, color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.label, style: AppTheme.sans(size: 11, weight: FontWeight.w600, color: color)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
