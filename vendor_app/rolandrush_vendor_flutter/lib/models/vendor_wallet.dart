/// Maps to `wallets` — note this schema has `total_withdrawn` alongside
/// `total_earned`/`balance`, one field richer than RolandRushApp's
/// customer/rider wallets table (which only has balance + total_earned).
class VendorWallet {
  final String id;
  final String userId;
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;

  const VendorWallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
  });

  factory VendorWallet.fromSupabase(Map<String, dynamic> row) {
    return VendorWallet(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      balance: (row['balance'] as num?)?.toDouble() ?? 0,
      totalEarned: (row['total_earned'] as num?)?.toDouble() ?? 0,
      totalWithdrawn: (row['total_withdrawn'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Maps to `transactions` — generic credit/debit ledger shared across
/// vendors and agents in this schema (RolandRushApp's transactions table
/// is simpler: no status, no metadata jsonb).
class VendorTransaction {
  final String id;
  final String type; // 'credit' | 'debit'
  final double amount;
  final String? description;
  final String status; // pending/completed/failed/reversed
  final DateTime createdAt;

  const VendorTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory VendorTransaction.fromSupabase(Map<String, dynamic> row) {
    return VendorTransaction(
      id: row['id'] as String,
      type: row['type'] as String,
      amount: (row['amount'] as num).toDouble(),
      description: row['description'] as String?,
      status: row['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
