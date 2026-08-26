import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const AppPill({super.key, required this.label, this.bg = AppColors.canvas, this.fg = AppColors.inkMuted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: fg)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final bool elevated;
  final bool flush;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.elevated = false, this.flush = false, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? (flush ? null : const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: elevated ? null : Border.all(color: AppColors.line),
        boxShadow: elevated ? AppShadows.elevated : AppShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(AppRadius.card), onTap: onTap, child: card);
  }
}

class AppToggle extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  const AppToggle({super.key, required this.checked, required this.onChanged, this.activeColor = AppColors.good});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: checked ? activeColor : AppColors.lineStrong, borderRadius: BorderRadius.circular(14)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.card)),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(size * 0.32)),
      alignment: Alignment.center,
      child: Text('RR', style: AppTheme.num(size: size * 0.4, weight: FontWeight.w800, color: Colors.white)),
    );
  }
}

class BrandLockup extends StatelessWidget {
  final String? tagline;
  const BrandLockup({super.key, this.tagline});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: AppTheme.sans(size: 17, weight: FontWeight.w700, color: AppColors.ink),
                children: [
                  const TextSpan(text: 'RolandRush '),
                  TextSpan(text: 'Business', style: AppTheme.sans(size: 17, weight: FontWeight.w700, color: AppColors.inkSubtle)),
                ],
              ),
            ),
            if (tagline != null) Text(tagline!, style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
          ],
        ),
      ],
    );
  }
}
