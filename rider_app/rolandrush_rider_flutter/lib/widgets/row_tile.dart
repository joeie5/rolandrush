import 'package:flutter/material.dart';
import '../core/theme.dart';

enum RowTone { normal, coral, online, alert }

/// Ports components/ui/Row.tsx.
class RowTile extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final RowTone tone;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RowTile({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.tone = RowTone.normal,
    this.trailing,
    this.onTap,
  });

  (Color, Color) _toneColors() {
    switch (tone) {
      case RowTone.normal:
        return (AppColors.canvas, AppColors.ink);
      case RowTone.coral:
        return (AppColors.coralSoft, AppColors.coral);
      case RowTone.online:
        return (AppColors.onlineSoft, AppColors.online);
      case RowTone.alert:
        return (AppColors.alertSoft, AppColors.alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _toneColors();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.btn)),
                  child: Icon(icon, color: fg, size: 24),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: AppTheme.sans(size: 17, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                    if (value != null)
                      Text(value!, style: AppTheme.sans(size: 13, weight: FontWeight.w500, color: AppColors.inkMuted), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
