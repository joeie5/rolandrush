import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../models/vendor_menu_item.dart';
import '../../widgets/primitives.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/error_view.dart';
import '../dashboard/providers/vendor_session_provider.dart';
import 'providers/menu_manager_provider.dart';

class MenuManagerScreen extends ConsumerStatefulWidget {
  const MenuManagerScreen({super.key});

  @override
  ConsumerState<MenuManagerScreen> createState() => _MenuManagerScreenState();
}

class _MenuManagerScreenState extends ConsumerState<MenuManagerScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorSessionProvider);
    final vendorId = vendor?.id ?? '';
    final state = vendorId.isEmpty ? null : ref.watch(menuManagerProvider(vendorId));
    final items = state?.items ?? [];
    final soldOut = items.where((i) => !i.isAvailable).length;

    final categories = items.map((i) => i.category ?? 'Menu').toSet().toList();
    final grouped = categories
        .map((c) => (
              category: c,
              items: items.where((i) => (i.category ?? 'Menu') == c && (query.isEmpty || i.name.toLowerCase().contains(query.toLowerCase()))).toList(),
            ))
        .where((g) => g.items.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: state?.error != null
                ? AppErrorView(error: state!.error!, onRetry: () => ref.read(menuManagerProvider(vendorId).notifier).load())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Menu', style: AppTheme.num(size: 20, weight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text.rich(TextSpan(style: AppTheme.sans(size: 12, color: AppColors.inkMuted), children: [
                                  TextSpan(text: '${items.length}', style: AppTheme.num(size: 12, weight: FontWeight.w700, color: AppColors.ink)),
                                  const TextSpan(text: ' items · '),
                                  TextSpan(text: '$soldOut', style: AppTheme.num(size: 12, weight: FontWeight.w700, color: AppColors.warn)),
                                  const TextSpan(text: ' sold out'),
                                ])),
                              ],
                            ),
                          ),
                          AppButton(size: AppButtonSize.sm, onPressed: () => context.push('/menu/new'), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, size: 15), SizedBox(width: 4), Text('Add item')])),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: (v) => setState(() => query = v),
                        style: AppTheme.sans(size: 14),
                        decoration: InputDecoration(
                          hintText: 'Search your menu',
                          hintStyle: AppTheme.sans(size: 14, color: AppColors.inkSubtle),
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.inkSubtle),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.ink, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (grouped.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              Text('No items match "$query"', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Try a different name or add a new item.', style: AppTheme.sans(size: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        )
                      else
                        for (final group in grouped)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(group.category.toUpperCase(), style: AppTheme.sans(size: 12, weight: FontWeight.w800, color: AppColors.inkSubtle).copyWith(letterSpacing: 0.6)),
                                    Text('${group.items.length}', style: AppTheme.num(size: 11, color: AppColors.inkSubtle)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                for (final item in group.items) _menuItemRow(context, vendorId, item),
                              ],
                            ),
                          ),
                    ],
                  ),
          ),
          Align(alignment: Alignment.bottomCenter, child: VendorBottomNav(currentPath: '/menu')),
        ],
      ),
    );
  }

  Widget _menuItemRow(BuildContext context, String vendorId, VendorMenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push('/menu/${item.id}'),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null
                  ? Opacity(
                      opacity: item.isAvailable ? 1 : 0.4,
                      child: Image.network(item.imageUrl!, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.line)),
                    )
                  : Container(width: 56, height: 56, color: AppColors.line),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, overflow: TextOverflow.ellipsis, style: AppTheme.sans(size: 14, weight: FontWeight.w600)),
                  Text(naira(item.price), style: AppTheme.num(size: 15, weight: FontWeight.w800)),
                  Text(
                    item.isAvailable ? '${item.preparationTime} min prep' : 'Sold out',
                    style: AppTheme.sans(size: 11, weight: item.isAvailable ? FontWeight.w400 : FontWeight.w700, color: item.isAvailable ? AppColors.inkSubtle : AppColors.warn),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                AppToggle(checked: item.isAvailable, onChanged: (_) => ref.read(menuManagerProvider(vendorId).notifier).toggleAvailability(item)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _confirmDelete(context, vendorId, item),
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkSubtle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String vendorId, VendorMenuItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete ${item.name}?', style: AppTheme.num(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('This removes the item from your menu and the customer feed. Past orders keep their records.', style: AppTheme.sans(size: 14, color: AppColors.inkMuted)),
            const SizedBox(height: 20),
            AppButton(
              full: true,
              size: AppButtonSize.lg,
              onPressed: () {
                ref.read(menuManagerProvider(vendorId).notifier).deleteItem(item.id);
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete item'),
            ),
            const SizedBox(height: 8),
            AppButton(full: true, variant: AppButtonVariant.secondary, onPressed: () => Navigator.of(ctx).pop(), child: const Text('Keep it')),
          ],
        ),
      ),
    );
  }
}
