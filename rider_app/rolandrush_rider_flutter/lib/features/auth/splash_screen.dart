import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

/// Ports Splash.tsx. Also decides where to land: an already-signed-in
/// rider (dev bypass or a real returning session) skips straight to Home
/// instead of the phone entry screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _go);
  }

  void _go() {
    if (!mounted) return;
    context.go(SupabaseService.isSignedIn ? '/home' : '/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coral,
      body: GestureDetector(
        onTap: _go,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 96,
                      width: 96,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                      child: const Icon(Icons.pedal_bike_rounded, size: 56, color: AppColors.coral),
                    ),
                    const SizedBox(height: 24),
                    Text('RolandRush', style: AppTheme.sans(size: 40, weight: FontWeight.w800, color: Colors.white, letterSpacing: -1.6)),
                    const SizedBox(height: 6),
                    Text('Rider', style: AppTheme.sans(size: 20, weight: FontWeight.w700, color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Center(
                  child: Text('Osun State · Ride. Deliver. Earn.',
                      style: AppTheme.sans(size: 15, weight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
