import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/data/impl_applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/controller/applicant_controller.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class EditApplicantPage extends StatefulWidget {
  final String applicantId;
  final String currentName;
  final String currentCpf;
  final String currentEmail;
  final String currentPhoneNumber;
  final String? currentAddress;
  final bool currentIsBeneficiary;

  const EditApplicantPage({
    super.key,
    required this.applicantId,
    required this.currentName,
    required this.currentCpf,
    required this.currentEmail,
    required this.currentPhoneNumber,
    this.currentAddress,
    required this.currentIsBeneficiary,
  });

  @override
  State<EditApplicantPage> createState() => _EditApplicantPageState();
}

class _EditApplicantPageState extends State<EditApplicantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final applicantController = ApplicantController(ImplApplicantRepository());
  bool _isBeneficiary = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _cpfController.text = widget.currentCpf;
    _emailController.text = widget.currentEmail;
    _phoneController.text = widget.currentPhoneNumber;
    _addressController.text = widget.currentAddress ?? '';
    _isBeneficiary = widget.currentIsBeneficiary;
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

  String? _validateName(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateCpf(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final cpfRegex = RegExp(r'^\d{11}$');
      if (!cpfRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
        return 'CPF deve ter 11 dígitos';
      }
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Email inválido';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\d{10,11}$');
      if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
        return 'Telefone deve ter 10 ou 11 dígitos';
      }
    }
    return null;
  }

  bool _hasChanges() {
    return _nameController.text.trim() != widget.currentName ||
        _cpfController.text.trim() != widget.currentCpf ||
        _emailController.text.trim() != widget.currentEmail ||
        _phoneController.text.trim() != widget.currentPhoneNumber ||
        _addressController.text.trim() != (widget.currentAddress ?? '') ||
        _isBeneficiary != widget.currentIsBeneficiary;
  }

  Future<void> _updateApplicant() async {
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

    // Construir DTO apenas com campos alterados
    final updateDTO = UpdateApplicantDTO(
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
      isBeneficiary:
          _isBeneficiary != widget.currentIsBeneficiary ? _isBeneficiary : null,
    );

    final result = await applicantController.updateApplicant(
      id: widget.applicantId,
      updateApplicantDTO: updateDTO,
    );

    if (mounted) {
      result.fold(
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitante atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                applicantController.error ?? 'Erro ao atualizar solicitante',
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
      appBar: AppBarCustom(title: "Editar Solicitante"),
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
                'Editar Solicitante',
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome
                      const Text(
                        'Nome',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _nameController,
                        hint: 'Digite o nome completo',
                        icon: LucideIcons.user,
                        validator: _validateName,
                      ),

                      const SizedBox(height: 24),

                      // CPF
                      const Text(
                        'CPF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _cpfController,
                        hint: 'Digite o CPF',
                        icon: LucideIcons.creditCard,
                        validator: _validateCpf,
                      ),

                      const SizedBox(height: 24),

                      // Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _emailController,
                        hint: 'Digite o email',
                        icon: LucideIcons.mail,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 24),

                      // Telefone
                      const Text(
                        'Telefone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _phoneController,
                        hint: 'Digite o telefone',
                        icon: LucideIcons.phone,
                        validator: _validatePhone,
                      ),

                      const SizedBox(height: 24),

                      // Endereço
                      const Text(
                        'Endereço',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _addressController,
                        hint: 'Digite o endereço (opcional)',
                        icon: LucideIcons.mapPin,
                      ),

                      const SizedBox(height: 24),

                      // Status de Beneficiário
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            _isBeneficiary
                                ? 'É Beneficiário'
                                : 'Não é Beneficiário',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _isBeneficiary
                                ? 'Esta pessoa é beneficiária'
                                : 'Esta pessoa não é beneficiária',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          value: _isBeneficiary,
                          onChanged:
                              applicantController.isLoading
                                  ? null
                                  : (value) {
                                    setState(() {
                                      _isBeneficiary = value;
                                    });
                                  },
                          activeColor: CustomColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          applicantController.isLoading
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
                      listenable: applicantController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed:
                              applicantController.isLoading
                                  ? null
                                  : _updateApplicant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              applicantController.isLoading
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
