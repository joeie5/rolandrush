import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class AppField extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  const AppField({super.key, required this.label, this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.inkMuted)),
        const SizedBox(height: 6),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: AppTheme.sans(size: 11, color: AppColors.inkSubtle)),
        ],
      ],
    );
  }
}

InputDecoration _fieldDecoration({String? placeholder}) => InputDecoration(
      hintText: placeholder,
      hintStyle: AppTheme.sans(size: 15, color: AppColors.inkSubtle),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.ink, width: 1.5)),
    );

class AppTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.keyboardType,
    this.onChanged,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: AppTheme.sans(size: 15),
      decoration: _fieldDecoration(placeholder: placeholder).copyWith(counterText: ''),
    );
  }
}

class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final int rows;
  final ValueChanged<String>? onChanged;

  const AppTextArea({super.key, this.controller, this.initialValue, this.placeholder, this.rows = 3, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: rows,
      onChanged: onChanged,
      style: AppTheme.sans(size: 15),
      decoration: _fieldDecoration(placeholder: placeholder),
    );
  }
}

class AppMoneyInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const AppMoneyInput({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: AppTheme.num(size: 24, weight: FontWeight.w800),
      decoration: InputDecoration(
        prefixText: '₦ ',
        prefixStyle: AppTheme.num(size: 20, weight: FontWeight.w700, color: AppColors.inkSubtle),
        hintText: '0',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.lineStrong)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.ink, width: 1.5)),
      ),
    );
  }
}
