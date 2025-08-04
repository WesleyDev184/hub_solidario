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

class EditDependentPage extends StatefulWidget {
  final String dependentId;
  final String applicantId;

  const EditDependentPage({
    super.key,
    required this.dependentId,
    required this.applicantId,
  });

  @override
  State<EditDependentPage> createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage> {
  final _applicantsController = Get.find<ApplicantsController>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _applicantName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInfo();
    });
  }

  void _loadInfo() async {
    final result = await _applicantsController.getDependent(
      widget.dependentId,
      widget.applicantId,
    );

    final applicantResult = await _applicantsController.getApplicant(
      widget.applicantId,
    );

    applicantResult.fold(
      (applicant) {
        setState(() {
          _applicantName = applicant.name;
        });
      },
      (error) {
        Get.snackbar(
          'Erro',
          'Não foi possível carregar os dados do responsável.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    result.fold(
      (dependent) {
        setState(() {
          _nameController.text = dependent.name ?? '';
          _cpfController.text = dependent.cpf ?? '';
          _emailController.text = dependent.email ?? '';
          _phoneController.text = dependent.phoneNumber ?? '';
          _addressController.text = dependent.address ?? '';
        });
      },
      (error) {
        Get.snackbar(
          'Erro',
          'Não foi possível carregar os dados do dependente.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
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

  Future<void> _updateDependent() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateDependentRequest(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    final result = await _applicantsController.updateDependent(
      widget.dependentId,
      request,
    );

    if (mounted) {
      result.fold(
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_nameController.text} atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(
            RoutePaths.ptd.dependentId(widget.applicantId, widget.dependentId),
          );
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar dependente: $error'),
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
      appBar: AppBarCustom(title: 'Editar Dependente'),
      backgroundColor: const Color(0xFFFFF8E1), // Amarelo claro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Editar Dependente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dependente de: ${_applicantName ?? 'Carregando...'}',
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
                        icon: LucideIcons.idCard,
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

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _applicantsController.isLoading
                            ? null
                            : () => context.go(
                                RoutePaths.ptd.applicantId(widget.applicantId),
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
                        onPressed: _applicantsController.isLoading
                            ? null
                            : _updateDependent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _applicantsController.isLoading
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
                                'Salvar',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
