import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/loans/loans.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/date_picker_field.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class EditLoanPage extends StatefulWidget {
  final String loanId;
  final LoanListItem loan;

  const EditLoanPage({super.key, required this.loanId, required this.loan});

  @override
  State<EditLoanPage> createState() => _EditLoanPageState();
}

class _EditLoanPageState extends State<EditLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  bool _isLoading = false;

  LoanListItem get _loan => widget.loan;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os valores atuais do empréstimo
    _reasonController.text = _loan.reason ?? '';
    _returnDateController.text = CoreUtils.DateUtils.formatDateBR(
      _loan.returnDate ?? DateTime.now(),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  String? _validateReason(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Motivo deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Validação básica do formato dd/mm/yyyy
      final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
      if (!dateRegex.hasMatch(value.trim())) {
        return 'Formato de data inválido (dd/mm/aaaa)';
      }

      try {
        final parts = value.trim().split('/');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);

        if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          return 'Data não pode ser anterior a hoje';
        }
      } catch (e) {
        return 'Data inválida';
      }
    }
    return null;
  }

  bool _hasChanges() {
    return _reasonController.text.trim() != widget.loan.reason ||
        _returnDateController.text.trim() !=
            CoreUtils.DateUtils.formatDateBR(
              widget.loan.returnDate ?? DateTime.now(),
            );
  }

  Future<void> _updateLoan() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração foi feita'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final data = UpdateLoanRequest(
      reason: _reasonController.text.trim(),
      returnDate: _returnDateController.text.trim(),
    );

    final res = await LoansService.updateLoan(widget.loanId, data);

    res.fold(
      (success) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, success);
      },
      (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar empréstimo: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Editar Empréstimo"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Editar Empréstimo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modifique apenas os campos que deseja alterar',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 32),

              const Text(
                'Motivo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _reasonController,
                hint: 'Digite o motivo do empréstimo',
                icon: LucideIcons.fileText,
                validator: _validateReason,
              ),

              const SizedBox(height: 24),

              const Text(
                'Data de Devolução',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                controller: _returnDateController,
                hint: 'Selecione a data de devolução',
                validator: _validateDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateLoan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Atualizar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
