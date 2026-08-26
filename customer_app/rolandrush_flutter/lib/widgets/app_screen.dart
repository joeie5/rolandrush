import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Sticky-header + back-chevron header, matching the React ScreenHeader.
class AppScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool back;
  final VoidCallback? onBack;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.back = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: back ? 48 : 0,
      leading: back
          ? IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTheme.display(size: 18, weight: FontWeight.w800), overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(subtitle!, style: AppTheme.sans(size: 12, color: AppColors.ink35), overflow: TextOverflow.ellipsis),
        ],
      ),
      actions: trailing != null ? [trailing!, const SizedBox(width: 8)] : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.line),
      ),
    );
  }
}

/// Simple screen body wrapper: canvas background + optional bottom-anchored footer.
class AppScreenBody extends StatelessWidget {
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  const AppScreenBody({
    super.key,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.only(bottom: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: SingleChildScrollView(padding: padding, child: child)),
        if (footer != null)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: footer,
          ),
      ],
    );
  }
}
