import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool coralBg;
  const AppLogo({super.key, this.size = 40, this.coralBg = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: coralBg ? AppColors.coral : Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text('RR',
          style: AppTheme.display(
              size: size * 0.42, weight: FontWeight.w800, color: coralBg ? Colors.white : AppColors.coral)),
    );
  }
}

class AppWordmark extends StatelessWidget {
  final bool white;
  final double size;
  const AppWordmark({super.key, this.white = false, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final base = white ? Colors.white : AppColors.ink;
    return RichText(
      text: TextSpan(
        style: AppTheme.display(size: size, weight: FontWeight.w800, color: base),
        children: [
          const TextSpan(text: 'Roland'),
          TextSpan(text: 'Rush', style: AppTheme.display(size: size, weight: FontWeight.w800, color: AppColors.coral)),
        ],
      ),
    );
  }
}
