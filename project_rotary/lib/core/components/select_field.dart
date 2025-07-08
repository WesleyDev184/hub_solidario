import 'package:flutter/material.dart';

class SelectField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const SelectField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      items:
          items.map((item) {
            // Wrap the child in a flexible container to handle overflow
            return DropdownMenuItem<T>(
              value: item.value,
              child: SizedBox(
                width: double.infinity,
                child: _wrapWithOverflowHandling(item.child),
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _wrapWithOverflowHandling(Widget child) {
    if (child is Text) {
      return Text(
        child.data ?? '',
        style: child.style,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return child;
  }
}
