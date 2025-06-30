import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
