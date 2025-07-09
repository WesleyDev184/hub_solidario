import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/text_area_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class EditDependentPage extends StatefulWidget {
  final String dependentId;
  final String currentName;
  final String currentCpf;
  final String currentEmail;
  final String currentPhoneNumber;
  final String? currentAddress;
  final String applicantName;

  const EditDependentPage({
    super.key,
    required this.dependentId,
    required this.currentName,
    required this.currentCpf,
    required this.currentEmail,
    required this.currentPhoneNumber,
    this.currentAddress,
    required this.applicantName,
  });

  @override
  State<EditDependentPage> createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage> {
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

  Future<void> _updateDependent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final request = UpdateDependentRequest(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    final result = await ApplicantsService.updateDependent(
      widget.dependentId,
      request,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.fold(
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_nameController.text} atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
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
    if (phone.length < 10) {
      return 'Telefone deve ter pelo menos 10 dígitos';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: 'Editar Dependente'),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dependente de: ${widget.applicantName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Nome
              InputField(
                controller: _nameController,
                hint: 'Nome Completo',
                icon: LucideIcons.user,
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // CPF
              InputField(
                controller: _cpfController,
                hint: 'CPF',
                icon: LucideIcons.idCard,
                validator: _validateCPF,
              ),
              const SizedBox(height: 16),

              // Email
              InputField(
                controller: _emailController,
                hint: 'Email',
                icon: LucideIcons.mail,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Telefone
              InputField(
                controller: _phoneController,
                hint: 'Telefone',
                icon: LucideIcons.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // Endereço
              TextAreaField(
                controller: _addressController,
                hint: 'Endereço',
                icon: LucideIcons.mapPin,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateDependent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                            'Salvar Alterações',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
