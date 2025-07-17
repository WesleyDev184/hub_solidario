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
        border:
            underlineVariant
                ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                )
                : const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
        enabledBorder:
            underlineVariant
                ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                )
                : const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
        focusedBorder:
            underlineVariant
                ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                )
                : const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
        contentPadding:
            underlineVariant
                ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0)
                : const EdgeInsets.all(16.0),
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
