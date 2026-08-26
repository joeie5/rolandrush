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
  runApp(const ProviderScope(child: RolandRushApp()));
}

class RolandRushApp extends StatelessWidget {
  const RolandRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RolandRush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
