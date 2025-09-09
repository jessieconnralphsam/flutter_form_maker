import 'package:flutter/material.dart';
import 'models/text_field_config.dart';

class FormMaker extends StatefulWidget {
  /// List of text field configurations
  final List<TextFieldConfig> fields;
  
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
      final controller = TextEditingController(text: field.initialValue ?? '');
      _controllers[field.key] = controller;
      _values[field.key] = field.initialValue ?? '';
      _obscureTextStates[field.key] = field.shouldObscureText;
      
      // Listen to changes
      controller.addListener(() {
        _values[field.key] = controller.text;
        if (widget.onChanged != null) {
          widget.onChanged!(_values);
        }
      });
    }
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

  Widget _buildTextField(TextFieldConfig config) {
    final isPasswordField = config.fieldType == FieldType.password && !config.obscureText;
    
    return TextFormField(
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
    );
  }

  InputDecoration _buildDecoration(TextFieldConfig config, bool isPasswordField) {
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
              child: _buildTextField(field),
            );
          }),
          
          if (widget.showSubmitButton) ...[
            SizedBox(height: widget.fieldSpacing),
            widget.submitButton ?? 
            ElevatedButton(
              onPressed: _handleSubmit,
              style: widget.submitButtonStyle ?? ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD630),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(widget.submitButtonText),
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
  }

  /// Reset form to initial values
  void reset() {
    for (final field in widget.fields) {
      _controllers[field.key]?.text = field.initialValue ?? '';
      _values[field.key] = field.initialValue ?? '';
    }
    _formKey.currentState?.reset();
  }

  /// Set value for a specific field
  void setValue(String fieldKey, String value) {
    if (_controllers.containsKey(fieldKey)) {
      _controllers[fieldKey]?.text = value;
      _values[fieldKey] = value;
    }
  }

  /// Get value for a specific field
  String? getValue(String fieldKey) {
    return _values[fieldKey];
  }
}