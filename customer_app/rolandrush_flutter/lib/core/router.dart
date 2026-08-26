import 'package:go_router/go_router.dart';
import 'supabase_service.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/phone_entry_screen.dart';
import '../features/auth/otp_verify_screen.dart';
import '../features/home/home_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/restaurants/restaurant_detail_screen.dart';
import '../features/restaurants/vendor_profile_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/personal_info_screen.dart';
import '../features/profile/saved_addresses_screen.dart';
import '../features/profile/payment_methods_screen.dart';
import '../features/profile/favourites_screen.dart';
import '../features/profile/notification_prefs_screen.dart';
import '../features/profile/notifications_inbox_screen.dart';
import '../features/profile/help_support_screen.dart';
import '../features/profile/roland_points_screen.dart';
import '../features/profile/membership_screen.dart';

final appRouter = GoRouter(
  initialLocation: SupabaseService.isSignedIn ? '/home' : '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/phone', builder: (_, __) => const PhoneEntryScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) => OtpVerifyScreen(phone: state.extra as String? ?? ''),
    ),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/feed',
      builder: (context, __) => FeedScreen(
        onVendorTap: (vendorId) => context.push('/vendor/$vendorId'),
      ),
    ),
    GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
    GoRoute(
      path: '/restaurant/:id',
      builder: (_, state) => RestaurantDetailScreen(vendorId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/vendor/:id',
      builder: (_, state) => VendorProfileScreen(vendorId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
    GoRoute(
      path: '/tracking/:id',
      builder: (_, state) => OrderTrackingScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/profile/personal', builder: (_, __) => const PersonalInfoScreen()),
    GoRoute(path: '/profile/addresses', builder: (_, __) => const SavedAddressesScreen()),
    GoRoute(path: '/profile/payments', builder: (_, __) => const PaymentMethodsScreen()),
    GoRoute(path: '/profile/favourites', builder: (_, __) => const FavouritesScreen()),
    GoRoute(path: '/profile/notifications', builder: (_, __) => const NotificationPrefsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsInboxScreen()),
    GoRoute(path: '/help', builder: (_, __) => const HelpSupportScreen()),
    GoRoute(path: '/points', builder: (_, __) => const RolandPointsScreen()),
    GoRoute(path: '/membership', builder: (_, __) => const MembershipScreen()),
  ],
);
