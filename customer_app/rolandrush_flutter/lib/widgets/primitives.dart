import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppChip extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback? onTap;
  const AppChip({super.key, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: active ? null : Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          style: AppTheme.sans(
            size: 13,
            weight: FontWeight.w600,
            color: active ? Colors.white : AppColors.ink50,
          ),
        ),
      ),
    );
  }
}

class SponsoredTag extends StatelessWidget {
  final bool dark;
  const SponsoredTag({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.15) : AppColors.coralSoft,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(
            'SPONSORED',
            style: AppTheme.sans(
              size: 10,
              weight: FontWeight.w700,
              color: dark ? Colors.white.withOpacity(0.9) : AppColors.coral700,
            ).copyWith(letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final String? imageUrl;
  const InitialsAvatar({super.key, required this.name, required this.color, this.size = 40, this.imageUrl});

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(_initials, style: AppTheme.display(size: size * 0.36, weight: FontWeight.w800, color: Colors.white)),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double value;
  final int? reviews;
  final bool dark;
  const RatingBadge({super.key, required this.value, this.reviews, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
        const SizedBox(width: 3),
        Text(value.toStringAsFixed(1),
            style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: dark ? Colors.white : AppColors.ink)),
        if (reviews != null) ...[
          const SizedBox(width: 3),
          Text('($reviews)',
              style: AppTheme.sans(size: 13, color: dark ? Colors.white.withOpacity(0.6) : AppColors.ink35)),
        ],
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionLabel({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: AppTheme.display(size: 17, weight: FontWeight.w800)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class AppListRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? hint;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const AppListRow({
    super.key,
    this.icon,
    required this.title,
    this.hint,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: AppColors.ink50),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                          size: 15, weight: FontWeight.w600, color: danger ? AppColors.coral : AppColors.ink)),
                  if (hint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(hint!, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 13, color: AppColors.ink35)),
                    ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.ink35),
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: child,
    );
  }
}

class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.coral : const Color(0xFFDCDCDC),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
          ),
        ),
      ),
    );
  }
}
