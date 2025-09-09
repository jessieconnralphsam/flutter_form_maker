import 'package:flutter/material.dart';
import 'models/text_field_config.dart';

class FormMaker extends StatefulWidget {
  /// List of field configurations
  final List<FieldConfig> fields;
  
  /// Callback when form values change
  final void Function(Map<String, String> values)? onChanged;
  
  /// Callback when submit button is pressed (if form is valid)
  final void Function(Map<String, String> values)? onSubmit;
  
  /// Custom submit button widget
  final Widget? submitButton;
  
  /// Whether to show a default submit button
  final bool showSubmitButton;
  
  /// Submit button text
  final String submitButtonText;
  
  /// Spacing between fields
  final double fieldSpacing;
  
  /// Submit button style
  final ButtonStyle? submitButtonStyle;
  
  /// Enable auto-validation
  final AutovalidateMode autovalidateMode;

  const FormMaker({
    super.key,
    required this.fields,
    this.onChanged,
    this.onSubmit,
    this.submitButton,
    this.showSubmitButton = true,
    this.submitButtonText = 'Submit',
    this.fieldSpacing = 16.0,
    this.submitButtonStyle,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  State<FormMaker> createState() => _FormMakerState();
}

class _FormMakerState extends State<FormMaker> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Map<String, String> _values;
  late Map<String, bool> _obscureTextStates; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    _values = {};
    _obscureTextStates = {};
    
    for (final field in widget.fields) {
      // Create controllers for all non-dropdown fields (including date/time fields for display)
      if (field.fieldType != FieldType.dropdown) {
        final controller = TextEditingController(text: field.initialValue ?? '');
        _controllers[field.key] = controller;
        
        // Only add listeners for editable text fields, not date/time fields
        if (!_isDateTimeField(field.fieldType)) {
          controller.addListener(() {
            _values[field.key] = controller.text;
            if (widget.onChanged != null) {
              widget.onChanged!(_values);
            }
          });
        }
      }
      
      _values[field.key] = field.initialValue ?? '';
      _obscureTextStates[field.key] = field.shouldObscureText;
    }
  }

  bool _isDateTimeField(FieldType fieldType) {
    return fieldType == FieldType.date || 
           fieldType == FieldType.dateTime || 
           fieldType == FieldType.time;
  }

  @override
  void dispose() {
    // Automatically dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(_values);
      }
    }
  }

  void _toggleObscureText(String fieldKey) {
    setState(() {
      _obscureTextStates[fieldKey] = !(_obscureTextStates[fieldKey] ?? false);
    });
  }

  void _handleFieldChange(String fieldKey, String? value) {
    setState(() {
      _values[fieldKey] = value ?? '';
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_values);
    }
  }

  Widget _buildField(FieldConfig config) {
    switch (config.fieldType) {
      case FieldType.dropdown:
        return _buildDropdownField(config);
      case FieldType.date:
        return _buildDateField(config);
      case FieldType.dateTime:
        return _buildDateTimeField(config);
      case FieldType.time:
        return _buildTimeField(config);
      default:
        return _buildTextField(config);
    }
  }

  Widget _buildDropdownField(FieldConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: _values[config.key]?.isEmpty == true ? null : _values[config.key],
        items: config.dropdownOptions?.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: config.dropdownStyle ?? const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (value) => _handleFieldChange(config.key, value),
        validator: config.defaultValidator,
        decoration: config.getDecoration(),
        dropdownColor: config.dropdownColor ?? Colors.white,
        style: config.dropdownStyle ?? const TextStyle(color: Colors.black),
        isExpanded: true,
        autovalidateMode: widget.autovalidateMode,
      ),
    );
  }

  Widget _buildDateField(FieldConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _controllers[config.key],
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: config.initialDate ?? DateTime.now(),
            firstDate: config.firstDate ?? DateTime(1900),
            lastDate: config.lastDate ?? DateTime(2100),
          );
          if (picked != null) {
            final formattedDate = config.formatDate(picked);
            _controllers[config.key]?.text = formattedDate;
            _handleFieldChange(config.key, formattedDate);
            if (config.onDateSelected != null) {
              config.onDateSelected!(picked);
            }
          }
        },
        validator: config.defaultValidator,
        decoration: config.getDecoration(),
        style: config.textStyle,
        readOnly: true,
        autovalidateMode: widget.autovalidateMode,
      ),
    );
  }

  Widget _buildDateTimeField(FieldConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _controllers[config.key],
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: config.initialDate ?? DateTime.now(),
            firstDate: config.firstDate ?? DateTime(1900),
            lastDate: config.lastDate ?? DateTime(2100),
          );
          if (pickedDate != null) {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: config.initialTime ?? TimeOfDay.now(),
              builder: config.use24HourFormat
                  ? (context, child) => MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      )
                  : null,
            );
            if (pickedTime != null) {
              final formattedDateTime = config.formatDateTime(pickedDate, pickedTime);
              _controllers[config.key]?.text = formattedDateTime;
              _handleFieldChange(config.key, formattedDateTime);
              if (config.onDateSelected != null) {
                config.onDateSelected!(pickedDate);
              }
              if (config.onTimeSelected != null) {
                config.onTimeSelected!(pickedTime);
              }
            }
          }
        },
        validator: config.defaultValidator,
        decoration: config.getDecoration(),
        style: config.textStyle,
        readOnly: true,
        autovalidateMode: widget.autovalidateMode,
      ),
    );
  }

  Widget _buildTimeField(FieldConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _controllers[config.key],
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: config.initialTime ?? TimeOfDay.now(),
            builder: config.use24HourFormat
                ? (context, child) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: child!,
                    )
                : null,
          );
          if (picked != null) {
            final formattedTime = config.formatTime(picked);
            _controllers[config.key]?.text = formattedTime;
            _handleFieldChange(config.key, formattedTime);
            if (config.onTimeSelected != null) {
              config.onTimeSelected!(picked);
            }
          }
        },
        validator: config.defaultValidator,
        decoration: config.getDecoration(),
        style: config.textStyle,
        readOnly: true,
        autovalidateMode: widget.autovalidateMode,
      ),
    );
  }

  Widget _buildTextField(FieldConfig config) {
    final isPasswordField = config.fieldType == FieldType.password && !config.obscureText;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _controllers[config.key],
        decoration: _buildDecoration(config, isPasswordField),
        style: config.textStyle,
        keyboardType: config.keyboardType,
        obscureText: _obscureTextStates[config.key] ?? false,
        maxLines: config.actualMaxLines,
        maxLength: config.maxLength,
        inputFormatters: config.inputFormatters,
        validator: config.defaultValidator,
        autovalidateMode: widget.autovalidateMode,
        textCapitalization: _getTextCapitalization(config.fieldType),
      ),
    );
  }

  InputDecoration _buildDecoration(FieldConfig config, bool isPasswordField) {
    final baseDecoration = config.getDecoration();
    
    // Add password visibility toggle if it's a password field
    if (isPasswordField) {
      return baseDecoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            (_obscureTextStates[config.key] ?? false) 
                ? Icons.visibility_outlined 
                : Icons.visibility_off_outlined,
            color: config.suffixIconColor ?? Colors.grey.shade600,
          ),
          onPressed: () => _toggleObscureText(config.key),
        ),
      );
    }
    
    return baseDecoration;
  }

  TextCapitalization _getTextCapitalization(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.name:
        return TextCapitalization.words;
      case FieldType.multiline:
        return TextCapitalization.sentences;
      default:
        return TextCapitalization.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == widget.fields.length - 1 ? 0 : widget.fieldSpacing,
              ),
              child: _buildField(field),
            );
          }),
          
          if (widget.showSubmitButton) ...[
            SizedBox(height: widget.fieldSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: widget.submitButton ?? 
              ElevatedButton(
                onPressed: _handleSubmit,
                style: widget.submitButtonStyle ?? ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD630),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(widget.submitButtonText),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get current form values
  Map<String, String> get values => Map.unmodifiable(_values);
  
  /// Validate the form programmatically
  bool validate() => _formKey.currentState?.validate() ?? false;
  
  /// Clear all field values
  void clear() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      for (final field in widget.fields) {
        _values[field.key] = '';
      }
    });
  }

  /// Reset form to initial values
  void reset() {
    for (final field in widget.fields) {
      if (field.fieldType != FieldType.dropdown) {
        _controllers[field.key]?.text = field.initialValue ?? '';
      }
      _values[field.key] = field.initialValue ?? '';
    }
    _formKey.currentState?.reset();
    setState(() {});
  }

  /// Set value for a specific field
  void setValue(String fieldKey, String value) {
    if (widget.fields.any((f) => f.key == fieldKey)) {
      final field = widget.fields.firstWhere((f) => f.key == fieldKey);
      if (field.fieldType != FieldType.dropdown) {
        _controllers[fieldKey]?.text = value;
      }
      setState(() {
        _values[fieldKey] = value;
      });
    }
  }

  /// Get value for a specific field
  String? getValue(String fieldKey) {
    return _values[fieldKey];
  }
}