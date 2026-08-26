import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class AppBottomNav extends StatelessWidget {
  final String currentPath;
  final bool dark;
  const AppBottomNav({super.key, required this.currentPath, this.dark = false});

  static const _tabs = [
    (path: '/home', label: 'Home', icon: Icons.home_rounded),
    (path: '/discover', label: 'Discover', icon: Icons.explore_rounded),
    (path: '/orders', label: 'Orders', icon: Icons.receipt_long_rounded),
    (path: '/profile', label: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Color(0xD9000000), Colors.transparent],
              )
            : null,
        color: dark ? null : Colors.white.withOpacity(0.97),
        border: dark ? null : const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _tab(context, _tabs[0]),
          _tab(context, _tabs[1]),
          Transform.translate(
            offset: const Offset(0, -16),
            child: GestureDetector(
            onTap: () => context.go('/feed'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.float,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
            ),
          ),
          _tab(context, _tabs[2]),
          _tab(context, _tabs[3]),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, ({String path, String label, IconData icon}) t) {
    final active = currentPath == t.path;
    final color = active ? AppColors.coral : (dark ? Colors.white.withOpacity(0.6) : AppColors.ink35);
    return GestureDetector(
      onTap: () => context.go(t.path),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(t.label, style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
