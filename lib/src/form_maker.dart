import 'package:flutter/material.dart';
import 'models/text_field_config.dart';

/// Main FormMaker widget that handles multiple text fields automatically
/// No need to create controllers or manage dispose - everything is handled internally
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

  const FormMaker({
    super.key,
    required this.fields,
    this.onChanged,
    this.onSubmit,
    this.submitButton,
    this.showSubmitButton = true,
    this.submitButtonText = 'Submit',
    this.fieldSpacing = 16.0,
  });

  @override
  State<FormMaker> createState() => _FormMakerState();
}

class _FormMakerState extends State<FormMaker> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Map<String, String> _values;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    _values = {};
    
    for (final field in widget.fields) {
      final controller = TextEditingController(text: field.initialValue ?? '');
      _controllers[field.key] = controller;
      _values[field.key] = field.initialValue ?? '';
      
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

  Widget _buildTextField(TextFieldConfig config) {
    return TextFormField(
      controller: _controllers[config.key],
      decoration: config.getDecoration(),
      style: config.textStyle,
      keyboardType: config.keyboardType,
      obscureText: config.obscureText,
      maxLines: config.maxLines,
      validator: config.defaultValidator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
}