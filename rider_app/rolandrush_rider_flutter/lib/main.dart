import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase_service.dart';
import 'features/dashboard/home_dashboard_screen.dart';
import 'features/orders/available_orders_screen.dart';
import 'features/delivery/active_delivery_screen.dart';
import 'features/wallet/withdraw_funds_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(
    supabaseUrl: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://wjtyasspkowlibvigtrt.supabase.co',
    ),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const ProviderScope(child: RolandRushRiderApp()));
}

class RolandRushRiderApp extends StatelessWidget {
  const RolandRushRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RolandRush Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFFE53935)),
      home: const _RiderHome(),
    );
  }
}

class _RiderHome extends StatefulWidget {
  const _RiderHome();

  @override
  State<_RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<_RiderHome> {
  @override
  Widget build(BuildContext context) {
    return HomeDashboardScreen(
      onViewAvailableOrders: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AvailableOrdersScreen(
            onAcceptOrder: (orderId) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActiveDeliveryScreen(
                  orderId: orderId,
                  onComplete: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                ),
              ),
            ),
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      onViewHistory: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order history coming soon'))),
      onViewEarnings: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WithdrawFundsScreen(onBack: () => Navigator.of(context).pop()),
        ),
      ),
      onViewProfile: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile coming soon'))),
    );
  }
}
