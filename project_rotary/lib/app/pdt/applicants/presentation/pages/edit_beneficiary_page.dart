import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/data/impl_beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/controller/beneficiary_controller.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/text_area_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class EditBeneficiaryPage extends StatefulWidget {
  final String beneficiaryId;
  final String currentName;
  final String currentCpf;
  final String currentEmail;
  final String currentPhoneNumber;
  final String? currentAddress;

  const EditBeneficiaryPage({
    super.key,
    required this.beneficiaryId,
    required this.currentName,
    required this.currentCpf,
    required this.currentEmail,
    required this.currentPhoneNumber,
    this.currentAddress,
  });

  @override
  State<EditBeneficiaryPage> createState() => _EditBeneficiaryPageState();
}

class _EditBeneficiaryPageState extends State<EditBeneficiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  late final BeneficiaryController _beneficiaryController;

  @override
  void initState() {
    super.initState();
    _beneficiaryController = BeneficiaryController(ImplBeneficiaryRepository());

    // Preenche os campos com os valores atuais
    _nameController.text = widget.currentName;
    _cpfController.text = widget.currentCpf;
    _emailController.text = widget.currentEmail;
    _phoneController.text = widget.currentPhoneNumber;
    _addressController.text = widget.currentAddress ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateBeneficiary() async {
    if (!_formKey.currentState!.validate()) return;

    // Cria DTO apenas com campos que foram alterados
    final updateBeneficiaryDTO = UpdateBeneficiaryDTO(
      name:
          _nameController.text.trim() != widget.currentName
              ? _nameController.text.trim()
              : null,
      cpf:
          _cpfController.text.trim() != widget.currentCpf
              ? _cpfController.text.trim()
              : null,
      email:
          _emailController.text.trim() != widget.currentEmail
              ? _emailController.text.trim()
              : null,
      phoneNumber:
          _phoneController.text.trim() != widget.currentPhoneNumber
              ? _phoneController.text.trim()
              : null,
      address:
          _addressController.text.trim() != (widget.currentAddress ?? '')
              ? _addressController.text.trim()
              : null,
    );

    // Verifica se há mudanças para enviar
    if (updateBeneficiaryDTO.toJson().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração foi feita'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await _beneficiaryController.updateBeneficiary(
      id: widget.beneficiaryId,
      updateBeneficiaryDTO: updateBeneficiaryDTO,
    );

    if (mounted) {
      result.fold(
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Beneficiário atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _beneficiaryController.error ??
                    'Erro ao atualizar beneficiário',
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Editar Beneficiário"),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColors.warning.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.pen,
                          color: CustomColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Editando beneficiário:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.currentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form fields
              Text(
                'Dados do Beneficiário',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              InputField(
                controller: _nameController,
                hint: 'Nome completo',
                icon: LucideIcons.user,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              InputField(
                controller: _cpfController,
                hint: 'CPF',
                icon: LucideIcons.creditCard,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'CPF é obrigatório';
                  }
                  if (value.trim().length < 11) {
                    return 'CPF deve ter 11 dígitos';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              InputField(
                controller: _emailController,
                hint: 'E-mail',
                icon: LucideIcons.mail,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-mail é obrigatório';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              InputField(
                controller: _phoneController,
                hint: 'Telefone',
                icon: LucideIcons.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Telefone é obrigatório';
                  }
                  if (value.trim().length < 10) {
                    return 'Telefone deve ter pelo menos 10 dígitos';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextAreaField(
                controller: _addressController,
                hint: 'Endereço completo',
                icon: LucideIcons.mapPin,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Endereço é obrigatório';
                  }
                  if (value.trim().length < 10) {
                    return 'Endereço deve ser mais detalhado';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _beneficiaryController.isLoading
                              ? null
                              : () => Navigator.pop(context),
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
                    child: ListenableBuilder(
                      listenable: _beneficiaryController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed:
                              _beneficiaryController.isLoading
                                  ? null
                                  : _updateBeneficiary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.warning,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _beneficiaryController.isLoading
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
                                    'Salvar Alterações',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                        );
                      },
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
