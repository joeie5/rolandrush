import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onBack;

  const AppScreenHeader({super.key, required this.title, this.subtitle, this.action, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.lineStrong)),
            child: const Icon(Icons.chevron_left, size: 20),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTheme.sans(size: 17, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
          if (subtitle != null) Text(subtitle!, style: AppTheme.sans(size: 12, color: AppColors.inkMuted), overflow: TextOverflow.ellipsis),
        ],
      ),
      actions: action != null ? [action!, const SizedBox(width: 16)] : null,
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.line)),
    );
  }
}
