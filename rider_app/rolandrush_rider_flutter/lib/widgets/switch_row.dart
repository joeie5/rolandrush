import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Ports components/ui/SwitchRow.tsx. NOTE: these preference toggles
/// (notification/privacy settings) have no backing schema column anywhere
/// in the shared database — same as the React mock, which only kept local
/// component state. Kept local-state-only here too; wiring these up for
/// real needs a rider_settings/notification_prefs table added first.
class SwitchRow extends StatefulWidget {
  final String label;
  final String? description;
  final bool defaultOn;

  const SwitchRow({super.key, required this.label, this.description, this.defaultOn = true});

  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  late bool on = widget.defaultOn;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => setState(() => on = !on),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.label, style: AppTheme.sans(size: 17, weight: FontWeight.w700)),
                    if (widget.description != null)
                      Text(widget.description!, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: on,
                activeColor: AppColors.online,
                onChanged: (v) => setState(() => on = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
