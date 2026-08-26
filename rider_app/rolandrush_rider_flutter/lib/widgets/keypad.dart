import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Ports components/Keypad.tsx.
class AppKeypad extends StatelessWidget {
  final ValueChanged<String> onPress;
  final VoidCallback onDelete;
  const AppKeypad({super.key, required this.onPress, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return AspectRatio(
        aspectRatio: 1.4,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.btn),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.btn),
            onTap: onTap ?? () => onPress(label),
            child: Center(
              child: child ?? Text(label, style: AppTheme.sans(size: 28, weight: FontWeight.w800)),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9']) key(d),
        const SizedBox(),
        key('0'),
        key('delete', onTap: onDelete, child: const Icon(Icons.backspace_outlined, size: 26)),
      ],
    );
  }
}
