import 'package:flutter/material.dart';

/// Configuration for a text field in the form
class TextFieldConfig {
  /// Unique key to identify this field
  final String key;
  
  /// Label text displayed above the field
  final String label;
  
  /// Hint text displayed inside the field
  final String? hintText;
  
  /// Whether this field is required
  final bool isRequired;
  
  /// Initial value for the field
  final String? initialValue;
  
  /// Type of keyboard to show
  final TextInputType keyboardType;
  
  /// Whether to obscure text (for passwords)
  final bool obscureText;
  
  /// Maximum number of lines
  final int maxLines;
  
  /// Custom validator function
  final String? Function(String? value)? validator;
  
  /// Input decoration for customization
  final InputDecoration? decoration;
  
  /// Text style for the input text
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

  /// Built-in validator that checks for required fields
  String? defaultValidator(String? value) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return '$label is required';
    }
    
    // Call custom validator if provided
    if (validator != null) {
      return validator!(value);
    }
    
    return null;
  }

  /// Get the input decoration with simple, clean design
  InputDecoration getDecoration() {
    return decoration ?? InputDecoration(
      labelText: label,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}