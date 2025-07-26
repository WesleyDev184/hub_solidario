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

class EditApplicantPage extends StatefulWidget {
  final String applicantId;

  const EditApplicantPage({super.key, required this.applicantId});

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
  bool _isBeneficiary = false;
  Applicant? _applicant;

  final _applicantsController = Get.find<ApplicantsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplicant();
    });
  }

  Future<void> _loadApplicant() async {
    await _applicantsController.getApplicant(widget.applicantId);
    final applicant = _applicantsController.allApplicants.firstWhere(
      (a) => a.id == widget.applicantId,
      orElse: () => Applicant(
        id: widget.applicantId,
        name: '',
        cpf: '',
        email: '',
        phoneNumber: '',
        address: null,
        isBeneficiary: false,
        beneficiaryQtd: 0,
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _applicant = applicant;
      _nameController.text = applicant.name ?? '';
      _cpfController.text = applicant.cpf ?? '';
      _emailController.text = applicant.email ?? '';
      _phoneController.text = applicant.phoneNumber ?? '';
      _addressController.text = applicant.address ?? '';
      _isBeneficiary = applicant.isBeneficiary;
    });
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
    return _nameController.text.trim() != _applicant?.name ||
        _cpfController.text.trim() != _applicant?.cpf ||
        _emailController.text.trim() != _applicant?.email ||
        _phoneController.text.trim() != _applicant?.phoneNumber ||
        _addressController.text.trim() != _applicant?.address ||
        _isBeneficiary != _applicant?.isBeneficiary;
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

    final request = UpdateApplicantRequest(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      cpf: _cpfController.text.trim().isNotEmpty
          ? _cpfController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      isBeneficiary: _isBeneficiary != _applicant?.isBeneficiary
          ? _isBeneficiary
          : null,
    );

    final result = await _applicantsController.updateApplicant(
      widget.applicantId,
      request,
    );

    if (mounted) {
      result.fold(
        (updatedApplicant) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_nameController.text.trim()} atualizado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go(RoutePaths.ptd.applicantId(widget.applicantId));
        },
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar solicitante: $failure'),
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
      body: Obx(() {
        final isLoading = _applicantsController.isLoading;
        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
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
                                mask: InputMask.cpf,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
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
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                              onPressed: isLoading ? null : _updateApplicant,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
              );
      }),
    );
  }
}
