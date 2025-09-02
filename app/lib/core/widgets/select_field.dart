import 'package:flutter/material.dart';

class SelectField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool underlineVariant;

  const SelectField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.underlineVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      isExpanded: true, // This allows the dropdown to expand to full width
      decoration: InputDecoration(
        labelText: hint,
        suffixIcon: Icon(icon),
        border: underlineVariant
            ? const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              )
            : const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item.value, child: item.child);
      }).toList(),
      onChanged: onChanged,
    );
  }
}
