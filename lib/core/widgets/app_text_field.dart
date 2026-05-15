import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.enableSuggestions = true,
    this.autocorrect = true,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final bool enableSuggestions;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    final resolvedPrefixIcon =
        prefixIcon ??
        (keyboardType == TextInputType.emailAddress
            ? Icons.alternate_email_rounded
            : obscureText
            ? Icons.lock_outline_rounded
            : Icons.person_outline_rounded);

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: textCapitalization,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      cursorColor: AppColors.textDark,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, end: 6),
          child: Icon(resolvedPrefixIcon, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
