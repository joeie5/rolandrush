import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_service.dart';
import '../../../models/delivery_order.dart';
import '../../../models/rider_profile.dart';

enum EarningsRange { today, week, month }

class EarningsTotals {
  final double amount;
  final int trips;
  const EarningsTotals({required this.amount, required this.trips});
}

class EarningsState {
  final List<RiderTransaction> transactions;
  final List<DeliveryOrder> recentDeliveries;
  final bool isLoading;
  final String? error;

  const EarningsState({this.transactions = const [], this.recentDeliveries = const [], this.isLoading = false, this.error});

  EarningsState copyWith({List<RiderTransaction>? transactions, List<DeliveryOrder>? recentDeliveries, bool? isLoading, String? error}) {
    return EarningsState(
      transactions: transactions ?? this.transactions,
      recentDeliveries: recentDeliveries ?? this.recentDeliveries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  EarningsTotals totalsFor(EarningsRange range) {
    final now = DateTime.now();
    DateTime since;
    switch (range) {
      case EarningsRange.today:
        since = DateTime(now.year, now.month, now.day);
      case EarningsRange.week:
        since = now.subtract(const Duration(days: 7));
      case EarningsRange.month:
        since = now.subtract(const Duration(days: 30));
    }
    final matching = transactions.where((t) => t.createdAt.isAfter(since));
    double amount = 0;
    for (final t in matching) {
      amount += t.amount;
    }
    return EarningsTotals(amount: amount, trips: matching.length);
  }

  /// Real bars from the last 7 days of transactions, oldest first — used
  /// instead of the mock's hardcoded weekBars.
  List<double> get last7DaysBars {
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    return days.map((day) {
      final next = day.add(const Duration(days: 1));
      return transactions.where((t) => !t.createdAt.isBefore(day) && t.createdAt.isBefore(next)).fold(0.0, (sum, t) => sum + t.amount);
    }).toList();
  }
}

/// Real earnings breakdown from `public.transactions` (type
/// `delivery_earning`, credited by ActiveDeliveryNotifier on completion)
/// — ports Earnings.tsx off the live wallet ledger instead of mock rows.
/// "Distance" and "Online hours" stats from the React mock have no
/// backing columns (no odometer/session-length tracking exists), so
/// those are intentionally left off rather than fabricated.
class EarningsNotifier extends StateNotifier<EarningsState> {
  EarningsNotifier() : super(const EarningsState()) {
    load();
  }

  Future<void> load() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final txRows = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(200);

      final profileRow = await SupabaseService.client.from('rider_profiles').select('id').eq('user_id', userId).maybeSingle();
      List<DeliveryOrder> recent = const [];
      if (profileRow != null) {
        final orderRows = await SupabaseService.client
            .from('orders')
            .select()
            .eq('rider_id', profileRow['id'])
            .eq('status', 'delivered')
            .order('delivered_at', ascending: false)
            .limit(10);
        recent = (orderRows as List).map((r) => DeliveryOrder.fromSupabase(r as Map<String, dynamic>)).toList();
      }

      state = state.copyWith(
        transactions: (txRows as List).map((r) => RiderTransaction.fromSupabase(r as Map<String, dynamic>)).toList(),
        recentDeliveries: recent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final earningsProvider = StateNotifierProvider<EarningsNotifier, EarningsState>((ref) => EarningsNotifier());
