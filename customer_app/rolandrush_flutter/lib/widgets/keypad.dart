import 'package:flutter/material.dart';
import '../core/theme.dart';

class Keypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  const Keypad({super.key, required this.onKey});

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line))),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 24,
        childAspectRatio: 1.8,
        children: _keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onKey(k),
            child: Center(
              child: k == 'del'
                  ? const Icon(Icons.backspace_outlined, size: 20, color: AppColors.ink50)
                  : Text(k, style: AppTheme.display(size: 24, weight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
