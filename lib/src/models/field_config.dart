import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  dropdown,
  date,
  dateTime,
  time,
}

/// Configuration for a text field, dropdown, or date field in the form
class FieldConfig {
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
  
  // Dropdown-specific properties
  final List<String>? dropdownOptions;
  final String? Function(String?)? onDropdownChanged;
  final String? dropdownHint;
  final Color? dropdownColor;
  final TextStyle? dropdownStyle;

  // Date-specific properties
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? dateFormat; // e.g., 'yyyy-MM-dd', 'dd/MM/yyyy', 'MMM dd, yyyy'
  final TimeOfDay? initialTime;
  final bool use24HourFormat;
  final Function(DateTime)? onDateSelected;
  final Function(TimeOfDay)? onTimeSelected;

  const FieldConfig({
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
    // Dropdown properties
    this.dropdownOptions,
    this.onDropdownChanged,
    this.dropdownHint,
    this.dropdownColor,
    this.dropdownStyle,
    // Date properties
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.dateFormat,
    this.initialTime,
    this.use24HourFormat = false,
    this.onDateSelected,
    this.onTimeSelected,
  });

  /// Factory constructor for dropdown fields
  factory FieldConfig.dropdown({
    required String key,
    required String label,
    required List<String> options,
    String? initialValue,
    bool isRequired = false,
    String? hintText,
    String? Function(String? value)? customValidator,
    IconData? prefixIcon,
    Color? prefixIconColor,
    Color? dropdownColor,
    TextStyle? dropdownStyle,
    InputDecoration? decoration,
  }) {
    return FieldConfig(
      key: key,
      label: label,
      fieldType: FieldType.dropdown,
      initialValue: initialValue,
      isRequired: isRequired,
      hintText: hintText,
      customValidator: customValidator,
      prefixIcon: prefixIcon,
      prefixIconColor: prefixIconColor,
      dropdownOptions: options,
      dropdownColor: dropdownColor,
      dropdownStyle: dropdownStyle,
      decoration: decoration,
    );
  }

  /// Factory constructor for date fields
  factory FieldConfig.date({
    required String key,
    required String label,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateFormat = 'MMM dd, yyyy',
    bool isRequired = false,
    String? hintText,
    String? Function(String? value)? customValidator,
    IconData? prefixIcon,
    Color? prefixIconColor,
    InputDecoration? decoration,
    Function(DateTime)? onDateSelected,
  }) {
    return FieldConfig(
      key: key,
      label: label,
      fieldType: FieldType.date,
      isRequired: isRequired,
      hintText: hintText,
      customValidator: customValidator,
      prefixIcon: prefixIcon,
      prefixIconColor: prefixIconColor,
      decoration: decoration,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      dateFormat: dateFormat,
      onDateSelected: onDateSelected,
    );
  }

  /// Factory constructor for date-time fields
  factory FieldConfig.dateTime({
    required String key,
    required String label,
    DateTime? initialDate,
    TimeOfDay? initialTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateFormat = 'MMM dd, yyyy HH:mm',
    bool use24HourFormat = false,
    bool isRequired = false,
    String? hintText,
    String? Function(String? value)? customValidator,
    IconData? prefixIcon,
    Color? prefixIconColor,
    InputDecoration? decoration,
    Function(DateTime)? onDateSelected,
    Function(TimeOfDay)? onTimeSelected,
  }) {
    return FieldConfig(
      key: key,
      label: label,
      fieldType: FieldType.dateTime,
      isRequired: isRequired,
      hintText: hintText,
      customValidator: customValidator,
      prefixIcon: prefixIcon,
      prefixIconColor: prefixIconColor,
      decoration: decoration,
      initialDate: initialDate,
      initialTime: initialTime,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      dateFormat: dateFormat,
      use24HourFormat: use24HourFormat,
      onDateSelected: onDateSelected,
      onTimeSelected: onTimeSelected,
    );
  }

  /// Factory constructor for time fields
  factory FieldConfig.time({
    required String key,
    required String label,
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
    bool isRequired = false,
    String? hintText,
    String? Function(String? value)? customValidator,
    IconData? prefixIcon,
    Color? prefixIconColor,
    InputDecoration? decoration,
    Function(TimeOfDay)? onTimeSelected,
  }) {
    return FieldConfig(
      key: key,
      label: label,
      fieldType: FieldType.time,
      isRequired: isRequired,
      hintText: hintText,
      customValidator: customValidator,
      prefixIcon: prefixIcon,
      prefixIconColor: prefixIconColor,
      decoration: decoration,
      initialTime: initialTime,
      use24HourFormat: use24HourFormat,
      onTimeSelected: onTimeSelected,
    );
  }

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
      case FieldType.dropdown:
      case FieldType.date:
      case FieldType.dateTime:
      case FieldType.time:
        return TextInputType.none;
      case FieldType.text:
      case FieldType.password:
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
      case FieldType.dropdown:
      case FieldType.date:
      case FieldType.dateTime:
      case FieldType.time:
        return [];
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

  /// Get date formatter
  DateFormat get _dateFormatter {
    return DateFormat(dateFormat ?? 'MMM dd, yyyy');
  }

  /// Format date to string
  String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time to string
  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (use24HourFormat) {
      return DateFormat('HH:mm').format(dt);
    } else {
      return DateFormat('h:mm a').format(dt);
    }
  }

  /// Format datetime to string
  String formatDateTime(DateTime date, TimeOfDay time) {
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat(dateFormat ?? 'MMM dd, yyyy HH:mm').format(dt);
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
      case FieldType.dropdown:
        return _validateDropdown(value);
      case FieldType.date:
      case FieldType.dateTime:
      case FieldType.time:
        return _validateDateTime(value);
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
    if (value.length > 16) {
      return 'Please provide a valid phone number';
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

  String? _validateDropdown(String? value) {
    if (value == null || value == 'Select a Status') {
      return 'Please select a status';
    }
    if (dropdownOptions != null && !dropdownOptions!.contains(value)) {
      return 'Please select a valid option';
    }
    return null;
  }

  String? _validateDateTime(String value) {
    // Basic validation - just check if value is not empty when required
    // More complex validation could parse the date string and verify format
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
      case FieldType.dropdown:
        return Icons.arrow_drop_down_outlined;
      case FieldType.date:
        return Icons.calendar_today_outlined;
      case FieldType.dateTime:
        return Icons.schedule_outlined;
      case FieldType.time:
        return Icons.access_time_outlined;
      default:
        return null;
    }
  }

  InputDecoration getDecoration() {
    return decoration ??
        InputDecoration(
          labelText: label,
          hintText: hintText ?? _getDefaultHint(),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Color(0xFFFFD630)),
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: defaultPrefixIcon != null 
              ? Icon(
                  defaultPrefixIcon,
                  color: prefixIconColor ?? const Color(0xFFFFD630),
                ) 
              : null,
          suffixIcon: suffixIcon != null 
              ? Icon(
                  suffixIcon,
                  color: suffixIconColor ?? Colors.grey.shade600,
                ) 
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFFFD630), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFFFD630), width: 1.5),
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
      case FieldType.dropdown:
        return dropdownHint ?? 'Select an option';
      case FieldType.date:
        return 'Select a date';
      case FieldType.dateTime:
        return 'Select date and time';
      case FieldType.time:
        return 'Select a time';
      default:
        return null;
    }
  }

  /// Build the appropriate widget based on field type
  Widget buildWidget({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    switch (fieldType) {
      case FieldType.dropdown:
        return buildDropdownField(
          currentValue: currentValue,
          onChanged: onChanged,
          validator: validator ?? defaultValidator,
        );
      case FieldType.date:
        return buildDateField(
          currentValue: currentValue,
          onChanged: onChanged,
          validator: validator ?? defaultValidator,
        );
      case FieldType.dateTime:
        return buildDateTimeField(
          currentValue: currentValue,
          onChanged: onChanged,
          validator: validator ?? defaultValidator,
        );
      case FieldType.time:
        return buildTimeField(
          currentValue: currentValue,
          onChanged: onChanged,
          validator: validator ?? defaultValidator,
        );
      default:
        return buildTextField(
          currentValue: currentValue,
          onChanged: onChanged,
          validator: validator ?? defaultValidator,
        );
    }
  }

  /// Build dropdown field widget
  Widget buildDropdownField({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final Set<String> placeholderValues = {
      'Select a Country',
      'Select a State',
      'Select a Status',
      'Select an Option',
    };

    final bool isPlaceholder = currentValue != null && placeholderValues.contains(currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: isPlaceholder ? null : currentValue, // don't preselect placeholder
        items: dropdownOptions?.map((option) {
          final isPlaceholder = placeholderValues.contains(option);

          return DropdownMenuItem<String>(
            value: option, // always assign the actual string
            enabled: !isPlaceholder, // disable placeholder
            child: Text(
              option,
              style: (dropdownStyle ?? const TextStyle(color: Colors.black)).copyWith(
                color: isPlaceholder
                    ? Colors.grey.shade400
                    : (dropdownStyle?.color ?? Colors.black),
                fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || placeholderValues.contains(value)) {
            return 'Please select a valid option';
          }
          return validator?.call(value);
        },
        decoration: getDecoration(),
        dropdownColor: dropdownColor ?? Colors.white,
        style: dropdownStyle ?? const TextStyle(color: Colors.black),
        isExpanded: true,
        hint: isPlaceholder
            ? Text(
                currentValue, // show placeholder text as hint
                style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              )
            : null,
      ),
    );
  }


  /// Build date field widget
  Widget buildDateField({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final String initialText = currentValue ??
        (initialDate != null ? formatDate(initialDate!) : initialValue ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        initialValue: initialText,
        onTap: () async {
          final context = _getCurrentContext();
          if (context != null) {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (picked != null) {
              final formattedDate = formatDate(picked);
              onChanged(formattedDate);
              if (onDateSelected != null) {
                onDateSelected!(picked);
              }
            }
          }
        },
        validator: validator,
        decoration: getDecoration(),
        style: textStyle,
        readOnly: true,
      ),
    );
  }


  /// Build date-time field widget
  Widget buildDateTimeField({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: TextEditingController(text: currentValue ?? initialValue),
        onTap: () async {
          final context = _getCurrentContext();
          if (context != null) {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: initialTime ?? TimeOfDay.now(),
                builder: use24HourFormat
                    ? (context, child) => MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        )
                    : null,
              );
              if (pickedTime != null) {
                final formattedDateTime = formatDateTime(pickedDate, pickedTime);
                onChanged(formattedDateTime);
                if (onDateSelected != null) {
                  onDateSelected!(pickedDate);
                }
                if (onTimeSelected != null) {
                  onTimeSelected!(pickedTime);
                }
              }
            }
          }
        },
        validator: validator,
        decoration: getDecoration(),
        style: textStyle,
        readOnly: true,
      ),
    );
  }

  /// Build time field widget
  Widget buildTimeField({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: TextEditingController(text: currentValue ?? initialValue),
        onTap: () async {
          final context = _getCurrentContext();
          if (context != null) {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: initialTime ?? TimeOfDay.now(),
              builder: use24HourFormat
                  ? (context, child) => MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      )
                  : null,
            );
            if (picked != null) {
              final formattedTime = formatTime(picked);
              onChanged(formattedTime);
              if (onTimeSelected != null) {
                onTimeSelected!(picked);
              }
            }
          }
        },
        validator: validator,
        decoration: getDecoration(),
        style: textStyle,
        readOnly: true,
      ),
    );
  }

  /// Build text field widget
  Widget buildTextField({
    String? currentValue,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        initialValue: currentValue ?? initialValue,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: shouldObscureText,
        maxLines: actualMaxLines,
        maxLength: maxLength,
        decoration: getDecoration(),
        style: textStyle,
      ),
    );
  }

  /// Helper method to get current context (this is a simplified version)
  /// In a real implementation, you'd need to pass the context from the widget
  BuildContext? _getCurrentContext() {
    // This is a placeholder. In practice, you'd need to pass the context
    // from the widget that's using this FieldConfig
    return null;
  }
}