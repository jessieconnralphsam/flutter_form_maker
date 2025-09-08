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
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.black),
          errorStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
  }
}
