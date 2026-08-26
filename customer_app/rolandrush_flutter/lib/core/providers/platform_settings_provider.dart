import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_service.dart';

/// Key/value platform config (RLS: readable by any authenticated user).
/// Values are stored as text in the DB — callers parse to the type they need.
final platformSettingsProvider = FutureProvider<Map<String, String>>((ref) async {
  final res = await SupabaseService.client.from('platform_settings').select('key, value');
  return {for (final row in (res as List)) row['key'] as String: row['value'].toString()};
});

double platformSettingDouble(Map<String, String> settings, String key, double fallback) {
  return double.tryParse(settings[key] ?? '') ?? fallback;
}
