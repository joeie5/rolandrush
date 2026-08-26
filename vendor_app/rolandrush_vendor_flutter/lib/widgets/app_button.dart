import 'package:flutter/material.dart';
import '../core/theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, dark }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool full;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) { AppButtonSize.sm => 36.0, AppButtonSize.md => 44.0, AppButtonSize.lg => 54.0 };
    final disabled = onPressed == null;

    Color bg;
    Color fg;
    Border? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.coral;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = Colors.white;
        fg = AppColors.ink;
        border = Border.all(color: AppColors.lineStrong);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.inkMuted;
        break;
      case AppButtonVariant.danger:
        bg = Colors.white;
        fg = AppColors.coral;
        border = Border.all(color: AppColors.coral.withOpacity(0.3));
        break;
      case AppButtonVariant.dark:
        bg = AppColors.ink;
        fg = Colors.white;
        break;
    }

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: SizedBox(
        width: full ? double.infinity : null,
        height: height,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn), side: border?.top ?? BorderSide.none),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.btn),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: DefaultTextStyle(
                  style: AppTheme.sans(size: 14, weight: FontWeight.w600, color: fg),
                  child: IconTheme(data: IconThemeData(color: fg, size: 16), child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
