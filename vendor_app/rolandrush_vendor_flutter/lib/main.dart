import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase_service.dart';
import 'core/theme.dart';
import 'core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(
    supabaseUrl: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://wjtyasspkowlibvigtrt.supabase.co',
    ),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const ProviderScope(child: RolandRushVendorApp()));
}

class RolandRushVendorApp extends StatelessWidget {
  const RolandRushVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RolandRush Vendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: vendorRouter,
    );
  }
}
