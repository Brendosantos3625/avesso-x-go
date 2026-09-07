import 'package:flutter/material.dart';

class AvessoTextField extends StatelessWidget {
  const AvessoTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.multiline = false,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool multiline;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      minLines: multiline ? 4 : 1,
      maxLines: multiline ? 6 : 1,
      textAlignVertical: multiline ? TextAlignVertical.top : null,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
    );
  }
}