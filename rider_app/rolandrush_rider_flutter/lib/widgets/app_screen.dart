import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import 'bottom_nav.dart';

/// Ports components/ui/Screen.tsx — the shared page shell with an optional
/// title/back-button header and an optional bottom nav.
class AppScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;
  final bool nav;
  final String? navPath;
  final bool padded;
  final Widget child;

  const AppScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
    this.action,
    this.nav = false,
    this.navPath,
    this.padded = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final showHeader = title != null || onBack != null || action != null;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onBack != null)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onBack ?? () => context.pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.chevron_left_rounded, size: 28, color: AppColors.ink),
                        ),
                      ),
                    if (onBack != null) const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            Text(title!,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.sans(size: 26, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.6)),
                          if (subtitle != null)
                            Text(subtitle!, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: padded ? const EdgeInsets.fromLTRB(20, 0, 20, 24) : EdgeInsets.zero,
                child: child,
              ),
            ),
            if (nav) AppBottomNav(currentPath: navPath ?? GoRouterState.of(context).matchedLocation),
          ],
        ),
      ),
    );
  }
}
