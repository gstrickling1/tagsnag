import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class PlateInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmit;
  final bool showValidation;
  final int maxLength;

  const PlateInput({
    super.key,
    required this.controller,
    this.hintText = 'Enter plate text',
    this.onSubmit,
    this.showValidation = true,
    this.maxLength = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 &\-+']")),
        UpperCaseTextFormatter(),
      ],
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 20,
          letterSpacing: 2,
          color: Colors.grey[400],
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onSubmitted: (_) => onSubmit?.call(),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
