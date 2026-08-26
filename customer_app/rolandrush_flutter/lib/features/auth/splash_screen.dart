import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/wordmark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/onboarding'),
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.4,
              child: Image.asset('assets/onboarding/suya.jpg', fit: BoxFit.cover),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Color(0xB3000000), Color(0x66000000)],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 68),
                  const SizedBox(height: 20),
                  const AppWordmark(white: true, size: 30),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Osun's food scene, one swipe at a time.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sans(size: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 3,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Container(decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(2))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('OSOGBO, OSUN STATE',
                      style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: Colors.white.withOpacity(0.4))
                          .copyWith(letterSpacing: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
