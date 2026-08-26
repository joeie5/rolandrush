import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_service.dart';

/// Key/value platform config (RLS: readable by any authenticated user).
/// Same pattern as the vendor app's platform_settings_provider.dart.
final platformSettingsProvider = FutureProvider<Map<String, String>>((ref) async {
  final res = await SupabaseService.client.from('platform_settings').select('key, value');
  return {for (final row in (res as List)) row['key'] as String: row['value'].toString()};
});

double platformSettingDouble(Map<String, String> settings, String key, double fallback) {
  return double.tryParse(settings[key] ?? '') ?? fallback;
}
