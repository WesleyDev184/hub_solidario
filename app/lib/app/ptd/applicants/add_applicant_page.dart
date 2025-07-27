import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddApplicantPage extends StatefulWidget {
  const AddApplicantPage({super.key});

  @override
  State<AddApplicantPage> createState() => _AddApplicantPageState();
}

class _AddApplicantPageState extends State<AddApplicantPage> {
  final ApplicantsController _applicantsController =
      Get.find<ApplicantsController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isBeneficiary = false;

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

    final request = CreateApplicantRequest(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      isBeneficiary: _isBeneficiary,
    );

    final result = await _applicantsController.createApplicant(request);

    if (mounted) {
      result.fold(
        (applicantId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitante criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(RoutePaths.ptd.applicants);
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
      appBar: AppBarCustom(
        title: "Criar Solicitante",
        path: RoutePaths.ptd.applicants,
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Obx(() {
            final isLoading = _applicantsController.isLoading;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Criar Solicitante',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados do novo solicitante',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
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
                    mask: InputMask.cpf,
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
                    mask: InputMask.phone,
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      value: _isBeneficiary,
                      onChanged: isLoading
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(
                                  RoutePaths.ptd.applicants,
                                ),
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
                          onPressed: isLoading ? null : _createApplicant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
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
                                  'Criar',
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
            );
          }),
        ),
      ),
    );
  }
}
