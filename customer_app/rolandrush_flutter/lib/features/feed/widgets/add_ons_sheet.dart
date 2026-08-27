import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/add_on.dart';
import '../../../models/menu_item.dart';

const _maxAddOnsTotal = 5; // mirrors the 5-item cap in the Figma prototype
final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

/// Bottom sheet for selecting add-ons + quantity before adding a feed
/// item to cart. Call via showModalBottomSheet and await the result.
class AddOnsSheet extends StatefulWidget {
  final MenuItem item;
  final int initialQuantity;
  final List<AddOn> initialSelection;

  const AddOnsSheet({
    super.key,
    required this.item,
    this.initialQuantity = 1,
    this.initialSelection = const [],
  });

  @override
  State<AddOnsSheet> createState() => _AddOnsSheetState();
}

class _AddOnsSheetState extends State<AddOnsSheet> {
  late int _quantity;
  late Map<String, int> _selected; // addOnId -> qty

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _selected = {
      for (final a in widget.initialSelection) a.id: a.quantity,
    };
  }

  int get _totalAddOnCount => _selected.values.fold(0, (a, b) => a + b);

  double get _addOnsTotal {
    double sum = 0;
    for (final addOn in widget.item.addOns) {
      final qty = _selected[addOn.id] ?? 0;
      sum += addOn.price * qty;
    }
    return sum;
  }

  // Add-ons are already priced per the quantity chosen for that add-on
  // specifically (_addOnsTotal), not per unit of the base item — they
  // must not be multiplied by _quantity again here, or picking e.g. 1
  // egg sauce on a 4x item overcharges as if 4 egg sauces were added.
  double get _totalPrice => widget.item.price * _quantity + _addOnsTotal;

  void _changeAddOn(String addOnId, int delta) {
    setState(() {
      final current = _selected[addOnId] ?? 0;
      final next = (current + delta).clamp(0, 99);
      final othersTotal = _totalAddOnCount - current;
      if (othersTotal + next > _maxAddOnsTotal) return; // enforce cap
      if (next == 0) {
        _selected.remove(addOnId);
      } else {
        _selected[addOnId] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(item),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildQuantityStepper(),
                  const SizedBox(height: 16),
                  if (item.addOns.isNotEmpty) ...[
                    Text('Add-ons', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...item.addOns.map(_buildAddOnRow),
                  ],
                ],
              ),
            ),
            _buildFooter(context),
          ],
        );
      },
    );
  }

  Widget _buildHeader(MenuItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.imageUrl!, width: 56, height: 56, fit: BoxFit.cover),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(_naira.format(item.price), style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton.filled(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove, size: 16),
              style: IconButton.styleFrom(minimumSize: const Size(32, 32)),
            ),
            SizedBox(width: 32, child: Text('$_quantity', textAlign: TextAlign.center)),
            IconButton.filled(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add, size: 16),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(32, 32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddOnRow(AddOn addOn) {
    final qty = _selected[addOn.id] ?? 0;
    final isSelected = qty > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? Colors.red.shade400 : Colors.grey.shade200, width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? Colors.red.shade50 : Colors.white,
      ),
      child: Row(
        children: [
          if (addOn.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(addOn.imageUrl!, width: 56, height: 56, fit: BoxFit.cover),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addOn.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('+${_naira.format(addOn.price)} each',
                    style: TextStyle(fontSize: 12, color: isSelected ? Colors.red.shade600 : Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            onPressed: qty > 0 ? () => _changeAddOn(addOn.id, -1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: _totalAddOnCount < _maxAddOnsTotal ? () => _changeAddOn(addOn.id, 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.grey)),
                Text(_naira.format(_totalPrice),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600, minimumSize: const Size.fromHeight(52)),
              onPressed: () {
                final selectedAddOns = widget.item.addOns
                    .where((a) => (_selected[a.id] ?? 0) > 0)
                    .map((a) => AddOn(id: a.id, name: a.name, price: a.price, imageUrl: a.imageUrl, quantity: _selected[a.id]!))
                    .toList();
                Navigator.pop(context, (quantity: _quantity, addOns: selectedAddOns));
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
