import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/app_button.dart';

class _Slide {
  final String image;
  final String kicker;
  final String title;
  final String body;
  const _Slide({required this.image, required this.kicker, required this.title, required this.body});
}

const _slides = [
  _Slide(
    image: 'assets/onboarding/jollof.jpg',
    kicker: "SWIPE, DON'T SCROLL LISTS",
    title: 'Every dish is a video',
    body: 'Your feed is full-screen food. Swipe up for the next dish from kitchens around you in Osun.',
  ),
  _Slide(
    image: 'assets/onboarding/shawarma.jpg',
    kicker: 'SEE IT BEFORE YOU ORDER IT',
    title: 'Order in two taps',
    body: 'Price, vendor and add-ons live right on the video. Tap the bag and it lands in your cart.',
  ),
  _Slide(
    image: 'assets/onboarding/suya.jpg',
    kicker: 'ONE CART, MANY KITCHENS',
    title: 'Mix vendors freely',
    body: 'Suya from one spot, zobo from another. We group them by vendor and deliver together.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final slide = _slides[index];
    final last = index == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Image.asset(slide.image, key: ValueKey(slide.image), fit: BoxFit.cover),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Color(0xBF000000), Color(0x40000000)],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: TextButton(
                  onPressed: () => context.go('/phone'),
                  child: Text('Skip', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slide.kicker,
                    style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.coral).copyWith(letterSpacing: 1.4)),
                const SizedBox(height: 12),
                Text(slide.title, style: AppTheme.display(size: 34, weight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Text(slide.body, style: AppTheme.sans(size: 15, color: Colors.white.withOpacity(0.7)), maxLines: 3),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(_slides.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == index ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == index ? AppColors.coral : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    AppButton(
                      size: AppButtonSize.lg,
                      onPressed: () {
                        if (last) {
                          context.go('/phone');
                        } else {
                          setState(() => index++);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(last ? 'Get started' : 'Next'),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
