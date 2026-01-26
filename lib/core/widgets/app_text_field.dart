import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hint;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool isCurrency;
  final int maxLines;
  final int minLines;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.hint,
    this.validator,
    this.onTap,
    this.isCurrency = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType,
  });

  TextInputType _effectiveKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    if (isCurrency) return const TextInputType.numberWithOptions(decimal: true);
    if (maxLines > 1) return TextInputType.multiline;
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: _effectiveKeyboardType(),
        minLines: maxLines > 1 ? minLines : null,
        maxLines: maxLines > 1 ? maxLines : 1,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'Enter $label',
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: theme.colorScheme.primary, size: 22)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), size: 22)
              : null,
        ),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        validator: validator,
      ),
    );
  }
}
