import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../features/cart/providers/cart_provider.dart';

class FloatingCartButton extends ConsumerWidget {
  final double bottom;
  const FloatingCartButton({super.key, this.bottom = 96});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    if (count == 0) return const SizedBox.shrink();

    return Positioned(
      right: 16,
      bottom: bottom,
      child: GestureDetector(
        onTap: () => context.push('/cart'),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x52000000), blurRadius: 28, offset: Offset(0, 10))],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  height: 20,
                  constraints: const BoxConstraints(minWidth: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text('$count',
                      style: AppTheme.display(size: 11, weight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
