import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/data/impl_category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/category_controller.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CreateLoanPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const CreateLoanPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends State<CreateLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final categoryController = CategoryController(ImplCategoryRepository());

  String? _selectedItemId;
  String? _selectedApplicantId;
  String? _selectedResponsibleId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      categoryController.getItemsByCategory(categoryId: widget.categoryId),
      categoryController.getApplicants(),
      categoryController.getResponsibles(),
    ]);
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

  List<Item> get _availableItems {
    return categoryController.items
        .where((item) => item.status == 'Disponível')
        .toList();
  }

  Future<void> _createLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await categoryController.createLoan(
      createLoanDTO: CreateLoanDTO(
        applicantId: _selectedApplicantId!,
        responsibleId: _selectedResponsibleId!,
        itemId: _selectedItemId!,
        reason: _reasonController.text.trim(),
      ),
    );

    if (mounted) {
      result.fold(
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empréstimo criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                categoryController.error ?? 'Erro ao criar empréstimo',
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
      appBar: AppBarCustom(title: "Criar Empréstimo"),
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

              ListenableBuilder(
                listenable: categoryController,
                builder: (context, child) {
                  return Column(
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
                        hint:
                            _availableItems.isEmpty
                                ? 'Nenhum item disponível'
                                : 'Selecione um item',
                        icon: LucideIcons.package,
                        validator: (value) => _validateSelection(value, 'item'),
                        items:
                            _availableItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(
                                  '${item.serialCode} - ${item.status}',
                                ),
                              );
                            }).toList(),
                        onChanged:
                            _availableItems.isEmpty
                                ? null
                                : (String? value) {
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
                        hint:
                            categoryController.applicants.isEmpty
                                ? 'Carregando solicitantes...'
                                : 'Selecione um solicitante',
                        icon: LucideIcons.user,
                        validator:
                            (value) => _validateSelection(value, 'solicitante'),
                        items:
                            categoryController.applicants.map((user) {
                              return DropdownMenuItem<String>(
                                value: user.id,
                                child: Text('${user.name} (${user.email})'),
                              );
                            }).toList(),
                        onChanged:
                            categoryController.applicants.isEmpty
                                ? null
                                : (String? value) {
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
                        hint:
                            categoryController.responsibles.isEmpty
                                ? 'Carregando responsáveis...'
                                : 'Selecione um responsável',
                        icon: LucideIcons.userCheck,
                        validator:
                            (value) => _validateSelection(value, 'responsável'),
                        items:
                            categoryController.responsibles.map((user) {
                              return DropdownMenuItem<String>(
                                value: user.id,
                                child: Text('${user.name} (${user.role})'),
                              );
                            }).toList(),
                        onChanged:
                            categoryController.responsibles.isEmpty
                                ? null
                                : (String? value) {
                                  setState(() {
                                    _selectedResponsibleId = value;
                                  });
                                },
                      ),
                    ],
                  );
                },
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

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          categoryController.isLoading
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
                      listenable: categoryController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed:
                              categoryController.isLoading ? null : _createLoan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              categoryController.isLoading
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
