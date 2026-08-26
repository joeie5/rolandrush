import 'package:flutter/material.dart';
import '../core/theme.dart';

enum AppButtonVariant { primary, success, alert, secondary, ghost }
enum AppButtonSize { md, lg, xl }

/// Ports components/ui/Button.tsx.
class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) { AppButtonSize.md => 56.0, AppButtonSize.lg => 64.0, AppButtonSize.xl => 72.0 };
    final disabled = onPressed == null;

    Color bg;
    Color fg;
    Border? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.coral;
        fg = Colors.white;
      case AppButtonVariant.success:
        bg = AppColors.online;
        fg = Colors.white;
      case AppButtonVariant.alert:
        bg = AppColors.alert;
        fg = Colors.white;
      case AppButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.ink;
        border = Border.all(color: AppColors.line, width: 2);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.inkMuted;
    }

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn), side: border?.top ?? BorderSide.none),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.btn),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Center(
                child: DefaultTextStyle(
                  style: AppTheme.sans(size: 17, weight: FontWeight.w800, color: fg, letterSpacing: -0.2),
                  child: IconTheme(data: IconThemeData(color: fg, size: 22), child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
