import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? suffixText;
  final String? errorText;

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
    this.inputFormatters,
    this.enabled = true,
    this.suffixText,
    this.errorText,
  });

  TextInputType _effectiveKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    if (isCurrency) return const TextInputType.numberWithOptions(decimal: true);
    if (maxLines > 1) return TextInputType.multiline;
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: _effectiveKeyboardType(),
        inputFormatters: inputFormatters,
        minLines: maxLines > 1 ? minLines : null,
        maxLines: maxLines > 1 ? maxLines : 1,
        readOnly: onTap != null,
        enabled: enabled,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'Enter $label',
          errorText: errorText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          suffixText: suffixText,
        ),
        validator: validator,
      ),
    );
  }
}
