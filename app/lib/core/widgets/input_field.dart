import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum InputMask { none, cpf, phone, cep, serialCode }

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final InputMask mask;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.mask = InputMask.none,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    MaskTextInputFormatter? maskFormatter;
    TextInputType inputType = keyboardType ?? TextInputType.text;

    switch (mask) {
      case InputMask.cpf:
        maskFormatter = MaskTextInputFormatter(
          mask: '###.###.###-##',
          filter: {"#": RegExp(r'[0-9]')},
        );
        inputType = TextInputType.number;
        break;
      case InputMask.phone:
        maskFormatter = MaskTextInputFormatter(
          mask: '(##) #####-####',
          filter: {"#": RegExp(r'[0-9]')},
        );
        inputType = TextInputType.phone;
        break;
      case InputMask.cep:
        maskFormatter = MaskTextInputFormatter(
          mask: '#####-###',
          filter: {"#": RegExp(r'[0-9]')},
        );
        inputType = TextInputType.number;
        break;
      case InputMask.serialCode:
        maskFormatter = MaskTextInputFormatter(
          mask: '####-####',
          filter: {"#": RegExp(r'[0-9]')},
        );
        inputType = TextInputType.text;
        break;
      case InputMask.none:
        maskFormatter = null;
        break;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: inputType,
      inputFormatters: maskFormatter != null ? [maskFormatter] : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hint,
        suffixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
