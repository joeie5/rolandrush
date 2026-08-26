import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/vendor_menu_item.dart';

class MenuManagerState {
  final List<VendorMenuItem> items;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const MenuManagerState({this.items = const [], this.isLoading = false, this.isSaving = false, this.error});

  MenuManagerState copyWith({List<VendorMenuItem>? items, bool? isLoading, bool? isSaving, String? error}) {
    return MenuManagerState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class MenuManagerNotifier extends StateNotifier<MenuManagerState> {
  final String vendorId;
  MenuManagerNotifier(this.vendorId) : super(const MenuManagerState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await SupabaseService.client
          .from('menu_items')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);
      final items = (res as List).map((r) => VendorMenuItem.fromSupabase(r as Map<String, dynamic>)).toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createItem(VendorMenuItem item) async {
    state = state.copyWith(isSaving: true);
    try {
      await SupabaseService.client.from('menu_items').insert(item.toInsertJson());
      await load();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<bool> updateItem(VendorMenuItem item) async {
    state = state.copyWith(isSaving: true);
    try {
      await SupabaseService.client.from('menu_items').update(item.toInsertJson()).eq('id', item.id);
      await load();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> toggleAvailability(VendorMenuItem item) async {
    await SupabaseService.client
        .from('menu_items')
        .update({'is_available': !item.isAvailable}).eq('id', item.id);
    await load();
  }

  Future<void> deleteItem(String itemId) async {
    await SupabaseService.client.from('menu_items').delete().eq('id', itemId);
    await load();
  }
}

final menuManagerProvider =
    StateNotifierProvider.family<MenuManagerNotifier, MenuManagerState, String>(
  (ref, vendorId) => MenuManagerNotifier(vendorId),
);
