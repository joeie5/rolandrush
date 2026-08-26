import 'package:flutter/material.dart';
import '../core/theme.dart';

enum CodeBoxTone { coral, ink }

/// Ports components/CodeBoxes.tsx.
class CodeBoxes extends StatelessWidget {
  final String value;
  final int length;
  final CodeBoxTone tone;

  const CodeBoxes({super.key, required this.value, this.length = 4, this.tone = CodeBoxTone.coral});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final digit = i < value.length ? value[i] : null;
        final active = i == value.length;
        final borderColor = digit != null
            ? (tone == CodeBoxTone.coral ? AppColors.coral : AppColors.ink)
            : (active ? AppColors.ink.withOpacity(0.4) : AppColors.line);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            height: 84,
            width: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(digit ?? '', style: AppTheme.sans(size: 40, weight: FontWeight.w800, letterSpacing: -1.2)),
          ),
        );
      }),
    );
  }
}
