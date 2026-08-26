import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

/// Ports components/ui/BottomNav.tsx.
class AppBottomNav extends StatelessWidget {
  final String currentPath;
  const AppBottomNav({super.key, required this.currentPath});

  static const _tabs = [
    (path: '/home', label: 'Home', icon: Icons.home_rounded),
    (path: '/jobs', label: 'Jobs', icon: Icons.layers_rounded),
    (path: '/earnings', label: 'Earnings', icon: Icons.account_balance_wallet_rounded),
    (path: '/profile', label: 'Account', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: _tabs.map((t) {
            final active = currentPath == t.path;
            final color = active ? AppColors.coral : AppColors.inkFaint;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.btn),
                onTap: () => context.go(t.path),
                child: SizedBox(
                  height: 62,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.icon, size: 26, color: color),
                      const SizedBox(height: 2),
                      Text(t.label, style: AppTheme.sans(size: 12, weight: FontWeight.w700, color: color)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
