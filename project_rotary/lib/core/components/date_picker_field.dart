import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: hint,
        suffixIcon: const Icon(LucideIcons.calendar),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        helpText: 'Selecionar data',
        cancelText: 'Cancelar',
        confirmText: 'OK',
        locale: const Locale('pt', 'BR'),
      );

      if (picked != null) {
        controller.text = _formatDate(picked);
      }
    } catch (e) {
      // Em caso de erro, exibe uma mensagem no console
      debugPrint('Erro ao abrir DatePicker: $e');

      // Como fallback, podemos mostrar um SnackBar ou não fazer nada
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir seletor de data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    // Força o formato brasileiro dd/mm/yyyy independente da localização
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
