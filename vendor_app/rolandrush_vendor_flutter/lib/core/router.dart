import 'package:go_router/go_router.dart';
import 'supabase_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/verification_screen.dart';
import '../features/dashboard/vendor_dashboard_screen.dart';
import '../features/orders/vendor_orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/menu/menu_manager_screen.dart';
import '../features/menu/menu_item_editor_screen.dart';
import '../features/wallet/vendor_wallet_screen.dart';
import '../features/wallet/withdraw_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/promote/promote_screen.dart';
import '../features/account/account_screen.dart';
import '../features/notifications/notifications_screen.dart';

final vendorRouter = GoRouter(
  initialLocation: SupabaseService.isSignedIn ? '/dashboard' : '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, state) => VendorOtpScreen(phone: state.extra as String? ?? '')),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/verification', builder: (_, __) => const VerificationScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const VendorDashboardScreen()),
    GoRoute(path: '/orders', builder: (_, __) => const VendorOrdersScreen()),
    GoRoute(path: '/orders/:id', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
    GoRoute(path: '/menu', builder: (_, __) => const MenuManagerScreen()),
    GoRoute(path: '/menu/new', builder: (_, __) => const MenuItemEditorScreen()),
    GoRoute(path: '/menu/:id', builder: (_, state) => MenuItemEditorScreen(itemId: state.pathParameters['id'])),
    GoRoute(path: '/wallet', builder: (_, __) => const VendorWalletScreen()),
    GoRoute(path: '/withdraw', builder: (_, __) => const WithdrawScreen()),
    GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
    GoRoute(path: '/promote', builder: (_, __) => const PromoteScreen()),
    GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
  ],
);
