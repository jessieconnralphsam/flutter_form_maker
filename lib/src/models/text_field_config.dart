import 'package:flutter/material.dart';

/// Configuration for a text field in the form
class TextFieldConfig {
  final String key;
  final String label;
  final String? hintText;
  final bool isRequired;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String? value)? validator;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? prefixIconColor;
  final Color? suffixIconColor;

  const TextFieldConfig({
    required this.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.decoration,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
  });

  String? defaultValidator(String? value) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return '$label is required';
    }
    if (validator != null) {
      return validator!(value);
    }
    return null;
  }

  InputDecoration getDecoration() {
    return decoration ??
        InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(color:  Color(0xFFFFD630)),
          hintStyle: const TextStyle(color: Colors.black),
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon,
                  color: prefixIconColor ?? Colors.grey.shade600,
                ) 
              : null,
          suffixIcon: suffixIcon != null 
              ? Icon(
                  suffixIcon,
                  color: suffixIconColor ?? Colors.grey.shade600,
                ) 
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color:  Color(0xFFFFD630)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color:  Color(0xFFFFD630), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
  }
}