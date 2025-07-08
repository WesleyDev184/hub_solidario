import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CreateApplicantPage extends StatefulWidget {
  const CreateApplicantPage({super.key});

  @override
  State<CreateApplicantPage> createState() => _CreateApplicantPageState();
}

class _CreateApplicantPageState extends State<CreateApplicantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isBeneficiary = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createApplicant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final request = CreateApplicantRequest(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      isBeneficiary: _isBeneficiary,
    );

    final result = await ApplicantsService.createApplicant(request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.fold(
        (applicantId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitante criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        },
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar solicitante: $failure'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateCPF(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF é obrigatório';
    }
    // Remover pontuação para validação
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final phone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.length < 10 || phone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: "Criar Solicitante"),
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Nome
              InputField(
                controller: _nameController,
                hint: "Nome completo",
                icon: LucideIcons.user,
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // CPF
              InputField(
                controller: _cpfController,
                hint: "CPF",
                icon: Icons.badge,
                validator: _validateCPF,
              ),
              const SizedBox(height: 16),

              // Email
              InputField(
                controller: _emailController,
                hint: "Email",
                icon: LucideIcons.mail,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Telefone
              InputField(
                controller: _phoneController,
                hint: "Telefone",
                icon: LucideIcons.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // Endereço
              InputField(
                controller: _addressController,
                hint: "Endereço (opcional)",
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),

              // Status de beneficiário
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _isBeneficiary
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color:
                              _isBeneficiary
                                  ? CustomColors.primary
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Beneficiário',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Marque se este solicitante já é um beneficiário',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isBeneficiary,
                          onChanged: (value) {
                            setState(() {
                              _isBeneficiary = value;
                            });
                          },
                          activeColor: CustomColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createApplicant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              : const Text('Criar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
