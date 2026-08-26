import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/wallet_provider.dart';
import '../../models/rider_profile.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
const _brandRed = Color(0xFFE53935);

class WithdrawFundsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const WithdrawFundsScreen({super.key, required this.onBack});

  @override
  ConsumerState<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends ConsumerState<WithdrawFundsScreen> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final balance = state.wallet?.balance ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Withdraw Funds'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBalanceCard(balance),
                const SizedBox(height: 20),
                _buildAmountField(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _brandRed, minimumSize: const Size.fromHeight(52)),
                    onPressed: state.isSubmitting ? null : () => _handleWithdraw(context, balance),
                    child: state.isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Withdraw'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...state.history.map(_buildHistoryTile),
                if (state.history.isEmpty) Text('No withdrawals yet', style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_brandRed, Color(0xFFD32F2F)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(_naira.format(balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Minimum withdrawal: ${_naira.format(minimumWithdrawal)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount to withdraw',
        prefixText: '₦ ',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildHistoryTile(WithdrawalRequest w) {
    Color statusColor;
    switch (w.status) {
      case 'completed':
        statusColor = Colors.green;
      case 'failed':
        statusColor = Colors.red;
      default:
        statusColor = Colors.orange;
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(Icons.account_balance, color: statusColor, size: 18)),
      title: Text(_naira.format(w.amount)),
      subtitle: Text(DateFormat('MMM d, y').format(w.createdAt)),
      trailing: Text(w.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _handleWithdraw(BuildContext context, double balance) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    // NOTE: bank details should come from a saved BankAccount record
    // (public.vendor_profiles has bank fields for vendors; riders don't
    // yet have an equivalent — worth adding rider bank fields to
    // rider_profiles, or a dedicated rider_bank_accounts table, before
    // this screen is real). Hardcoded placeholder for now.
    final ok = await ref.read(walletProvider.notifier).requestWithdrawal(amount, {
      'bank_name': 'TODO: pull from saved bank account',
      'account_number': 'TODO',
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Withdrawal request submitted' : 'Could not submit — check the amount')),
    );
    if (ok) _amountController.clear();
  }
}
