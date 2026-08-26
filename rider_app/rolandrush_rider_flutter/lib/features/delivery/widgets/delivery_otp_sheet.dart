import 'package:flutter/material.dart';

const _brandRed = Color(0xFFE53935);

/// Shown on the final delivery step instead of letting the rider tap
/// straight through to "delivered". The customer reads out the code from
/// their app/SMS; matching it against orders.delivery_otp is the
/// anti-fraud check the Figma mock skipped. Returns the entered code via
/// Navigator.pop, or null if cancelled.
Future<String?> showDeliveryOtpSheet(BuildContext context) {
  final controller = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Ask the customer for their 4-digit delivery code and enter it below to complete this order.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _brandRed, minimumSize: const Size.fromHeight(52)),
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Confirm & Complete Delivery'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
