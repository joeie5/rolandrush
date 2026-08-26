import 'package:go_router/go_router.dart';
import 'supabase_service.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/phone_entry_screen.dart';
import '../features/auth/otp_verify_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/verification_status_screen.dart';
import '../features/dashboard/home_screen.dart';
import '../features/orders/jobs_screen.dart';
import '../features/delivery/active_delivery_screen.dart';
import '../features/delivery/delivery_confirm_screen.dart';
import '../features/delivery/delivery_success_screen.dart';
import '../features/earnings/earnings_screen.dart';
import '../features/wallet/withdraw_funds_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/vehicle_details_screen.dart';
import '../features/profile/documents_screen.dart';
import '../features/profile/bank_account_screen.dart';
import '../features/profile/notification_settings_screen.dart';
import '../features/profile/help_support_screen.dart';
import '../features/profile/privacy_security_screen.dart';

/// Ports App.tsx's route table 1:1. Auth flow decides where to land after
/// Splash (phone entry vs. straight to Home for an already-signed-in
/// rider) rather than go_router redirect logic, matching how Splash.tsx
/// itself just does a timed navigate().
final riderRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneEntryScreen()),
    GoRoute(path: '/auth/otp', builder: (_, state) => OtpVerifyScreen(phone: state.extra as String? ?? '')),
    GoRoute(path: '/auth/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/auth/verification', builder: (_, __) => const VerificationStatusScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/jobs', builder: (_, __) => const JobsScreen()),
    GoRoute(path: '/delivery/active', builder: (_, __) => const ActiveDeliveryScreen()),
    GoRoute(path: '/delivery/confirm', builder: (_, __) => const DeliveryConfirmScreen()),
    GoRoute(path: '/delivery/success', builder: (_, state) => DeliverySuccessScreen(amount: state.extra as double? ?? 0)),
    GoRoute(path: '/earnings', builder: (_, __) => const EarningsScreen()),
    GoRoute(path: '/withdraw', builder: (_, __) => const WithdrawFundsScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/profile/vehicle', builder: (_, __) => const VehicleDetailsScreen()),
    GoRoute(path: '/profile/documents', builder: (_, __) => const DocumentsScreen()),
    GoRoute(path: '/profile/bank', builder: (_, __) => const BankAccountScreen()),
    GoRoute(path: '/profile/notifications', builder: (_, __) => const NotificationSettingsScreen()),
    GoRoute(path: '/profile/support', builder: (_, __) => const HelpSupportScreen()),
    GoRoute(path: '/profile/privacy', builder: (_, __) => const PrivacySecurityScreen()),
  ],
);

bool get riderIsSignedIn => SupabaseService.isSignedIn;
