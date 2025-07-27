import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CreateLoanPage extends StatefulWidget {
  final String categoryTitle;
  final List<Item> items;

  const CreateLoanPage({
    super.key,
    required this.categoryTitle,
    required this.items,
  });

  @override
  State<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends State<CreateLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingApplicants = false;
  bool _isLoadingUsers = false;

  String? _selectedItemId;
  String? _selectedApplicantId;
  String? _selectedResponsibleId;

  List<DropdownMenuItem<String>> _responsible = [];
  List<DropdownMenuItem<String>> _items = [];
  List<DropdownMenuItem<String>> _applicants = [];

  @override
  void initState() {
    super.initState();
    _loadItens(); // Carrega itens primeiro (sincrono)
    _loadUsers(); // Carrega usuários (assíncrono)
    _loadApplicants(); // Carrega solicitantes (assíncrono)
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _loadItens() {
    _items =
        widget.items.map((Item) {
          return DropdownMenuItem<String>(
            value: Item.id,
            child: Text(Item.formattedSerialCode),
          );
        }).toList();

    if (_items.isNotEmpty) {
      _selectedItemId = _items.first.value;
    } else {
      _selectedItemId = null;
    }
  }

  Future<void> _loadApplicants() async {
    if (_isLoadingApplicants) return;
    setState(() {
      _isLoadingApplicants = true;
    });

    final res = await ApplicantsService.getApplicants();
    res.fold(
      (applicants) {
        setState(() {
          _applicants =
              applicants.map((applicant) {
                return DropdownMenuItem<String>(
                  value: applicant.id,
                  child: Text(applicant.name ?? ''),
                );
              }).toList();

          // Seleciona automaticamente o primeiro item da lista
          if (_applicants.isNotEmpty) {
            _selectedApplicantId = _applicants.first.value;
          }
          _isLoadingApplicants = false;
        });
      },
      (error) {
        setState(() {
          _isLoadingApplicants = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar os Applicants: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _loadUsers() async {
    if (_isLoadingUsers) return;
    setState(() {
      _isLoadingUsers = true;
    });

    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final orthopedicBankId = currentUser.orthopedicBank?.id;
    if (orthopedicBankId == null) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banco ortopédico não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final res = await AuthService.getAllUsers(orthopedicBankId);
    res.fold(
      (users) {
        setState(() {
          _responsible =
              users.map((user) {
                return DropdownMenuItem<String>(
                  value: user.id,
                  child: Text(user.name),
                );
              }).toList();

          // Seleciona automaticamente o primeiro item da lista
          if (_responsible.isNotEmpty) {
            _selectedResponsibleId = _responsible.first.value;
          }

          _isLoadingUsers = false;
        });
      },
      (error) {
        setState(() {
          _isLoadingUsers = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar responsáveis: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  String? _validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Motivo é obrigatório';
    }
    if (value.trim().length < 10) {
      return 'Motivo deve ter pelo menos 10 caracteres';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Selecione um $fieldName';
    }
    return null;
  }

  Future<void> _createLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = CreateLoanRequest(
      itemId: _selectedItemId!,
      applicantId: _selectedApplicantId!,
      responsibleId: _selectedResponsibleId!,
      reason: _reasonController.text.trim(),
    );

    final res = await LoansService.createLoan(data);

    res.fold(
      (success) {
        // Empréstimo criado com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empréstimo criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, success);
        setState(() {
          _isLoading = false;
        });
      },
      (error) {
        // Erro ao criar o empréstimo
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar empréstimo: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Criar Empréstimo"),
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Criar Novo Empréstimo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categoria: ${widget.categoryTitle}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Seção de seleção
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Selection
                    const Text(
                      'Item *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectField<String>(
                      value: _selectedItemId,
                      hint: 'Selecione um item',
                      icon: LucideIcons.package,
                      validator: (value) => _validateSelection(value, 'item'),
                      items: _items,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedItemId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Applicant Selection
                    const Text(
                      'Solicitante *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectField<String>(
                      value: _selectedApplicantId,
                      hint: 'Selecione um solicitante',
                      icon: LucideIcons.user,
                      validator:
                          (value) => _validateSelection(value, 'solicitante'),
                      items: _applicants,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedApplicantId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Responsible Selection
                    const Text(
                      'Responsável *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectField<String>(
                      value: _selectedResponsibleId,
                      hint: 'Selecione um banco ortopédico',
                      icon: LucideIcons.building,
                      validator:
                          (value) => _validateSelection(value, 'responsável'),
                      items: _responsible,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedResponsibleId = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Reason Field
                const Text(
                  'Motivo *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                InputField(
                  controller: _reasonController,
                  hint: 'Descreva o motivo do empréstimo...',
                  icon: LucideIcons.messageSquare,
                  validator: _validateReason,
                ),
                const SizedBox(height: 32),
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
                        onPressed: _isLoading ? null : _createLoan,
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
                                  'Criar Empréstimo',
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
      ),
    );
  }
}
