import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum for different field types
enum FieldType {
  text,
  email,
  password,
  number,
  phone,
  url,
  multiline,
  decimal,
  creditCard,
  name,
}

/// Configuration for a text field in the form
class TextFieldConfig {
  final String key;
  final String label;
  final String? hintText;
  final bool isRequired;
  final String? initialValue;
  final FieldType fieldType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final String? Function(String? value)? customValidator;
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
    this.fieldType = FieldType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.customValidator,
    this.decoration,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
  });

  /// Get keyboard type based on field type
  TextInputType get keyboardType {
    switch (fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.multiline:
        return TextInputType.multiline;
      case FieldType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case FieldType.creditCard:
        return TextInputType.number;
      case FieldType.name:
        return TextInputType.name;
      case FieldType.text:
      case FieldType.password:
      default:
        return TextInputType.text;
    }
  }

  /// Get input formatters based on field type
  List<TextInputFormatter> get inputFormatters {
    switch (fieldType) {
      case FieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case FieldType.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
      case FieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case FieldType.creditCard:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
        ];
      case FieldType.name:
        return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
      default:
        return [];
    }
  }

  /// Get obscure text setting
  bool get shouldObscureText {
    return obscureText || fieldType == FieldType.password;
  }

  /// Get max lines based on field type
  int get actualMaxLines {
    if (fieldType == FieldType.multiline) {
      return maxLines > 1 ? maxLines : 3;
    }
    return maxLines;
  }

  /// Built-in validators for different field types
  String? _validateByType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? '$label is required' : null;
    }

    switch (fieldType) {
      case FieldType.email:
        return _validateEmail(value);
      case FieldType.phone:
        return _validatePhone(value);
      case FieldType.url:
        return _validateUrl(value);
      case FieldType.number:
        return _validateNumber(value);
      case FieldType.decimal:
        return _validateDecimal(value);
      case FieldType.creditCard:
        return _validateCreditCard(value);
      case FieldType.password:
        return _validatePassword(value);
      default:
        return null;
    }
  }

  String? _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String value) {
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? _validateUrl(String value) {
    final urlRegex = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL (starting with http:// or https://)';
    }
    return null;
  }

  String? _validateNumber(String value) {
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validateDecimal(String value) {
    if (double.tryParse(value) == null) {
      return 'Please enter a valid decimal number';
    }
    return null;
  }

  String? _validateCreditCard(String value) {
    if (value.length < 13 || value.length > 19) {
      return 'Credit card number must be 13-19 digits';
    }
    // Basic Luhn algorithm check
    if (!_luhnCheck(value)) {
      return 'Please enter a valid credit card number';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return (sum % 10) == 0;
  }

  /// Combined validator that runs both built-in and custom validation
  String? defaultValidator(String? value) {
    // First run built-in validation
    final builtInError = _validateByType(value);
    if (builtInError != null) {
      return builtInError;
    }

    // Then run custom validation if provided
    if (customValidator != null) {
      return customValidator!(value);
    }
    
    return null;
  }

  /// Get default prefix icon based on field type
  IconData? get defaultPrefixIcon {
    if (prefixIcon != null) return prefixIcon;
    
    switch (fieldType) {
      case FieldType.email:
        return Icons.email_outlined;
      case FieldType.password:
        return Icons.lock_outlined;
      case FieldType.phone:
        return Icons.phone_outlined;
      case FieldType.url:
        return Icons.link_outlined;
      case FieldType.number:
      case FieldType.decimal:
        return Icons.numbers_outlined;
      case FieldType.creditCard:
        return Icons.credit_card_outlined;
      case FieldType.name:
        return Icons.person_outlined;
      case FieldType.multiline:
        return Icons.notes_outlined;
      default:
        return null;
    }
  }

  InputDecoration getDecoration() {
    return decoration ??
        InputDecoration(
          labelText: label,
          hintText: hintText ?? _getDefaultHint(),
          labelStyle: const TextStyle(color: Color(0xFFFFD630)),
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: defaultPrefixIcon != null 
              ? Icon(
                  defaultPrefixIcon,
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
            borderSide: const BorderSide(color: Color(0xFFFFD630)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFFFD630), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: maxLength != null ? null : '',
        );
  }

  String? _getDefaultHint() {
    switch (fieldType) {
      case FieldType.email:
        return 'Enter your email address';
      case FieldType.password:
        return 'Enter your password';
      case FieldType.phone:
        return 'Enter your phone number';
      case FieldType.url:
        return 'https://example.com';
      case FieldType.number:
        return 'Enter a number';
      case FieldType.decimal:
        return 'Enter a decimal number';
      case FieldType.creditCard:
        return 'Enter credit card number';
      case FieldType.name:
        return 'Enter your name';
      case FieldType.multiline:
        return 'Enter your message';
      default:
        return null;
    }
  }
}