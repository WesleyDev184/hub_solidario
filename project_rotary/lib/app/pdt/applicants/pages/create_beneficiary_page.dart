import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/text_area_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CreateBeneficiaryPage extends StatefulWidget {
  final String applicantId;
  final String applicantName;

  const CreateBeneficiaryPage({
    super.key,
    required this.applicantId,
    required this.applicantName,
  });

  @override
  State<CreateBeneficiaryPage> createState() => _CreateBeneficiaryPageState();
}

class _CreateBeneficiaryPageState extends State<CreateBeneficiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _createBeneficiary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final request = CreateDependentRequest(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      applicantId: widget.applicantId,
    );

    final result = await ApplicantsService.createDependent(request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.fold(
        (dependentId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Beneficiário ${_nameController.text.trim()} criado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        },
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar beneficiário: $failure'),
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

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Endereço é obrigatório';
    }
    if (value.trim().length < 10) {
      return 'Endereço deve ser mais detalhado';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Criar Beneficiário"),
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
                'Criar Beneficiário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione um novo beneficiário para ${widget.applicantName}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.userPlus,
                      color: CustomColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solicitante:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            widget.applicantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                        validator: _validateCPF,
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
                      TextAreaField(
                        controller: _addressController,
                        hint: 'Digite o endereço completo',
                        icon: LucideIcons.mapPin,
                        maxLines: 3,
                        validator: _validateAddress,
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
                      onPressed: _isLoading ? null : _createBeneficiary,
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
                                'Criar Beneficiário',
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
