import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/data/impl_category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/category_controller.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

// Mock data para bancos ortopédicos
final List<Map<String, dynamic>> orthopedicBanks = [
  {"id": "1", "name": "Banco Ortopédico Central"},
  {"id": "2", "name": "Banco Ortopédico Norte"},
  {"id": "3", "name": "Banco Ortopédico Sul"},
  {"id": "4", "name": "Banco Ortopédico Leste"},
  {"id": "5", "name": "Banco Ortopédico Oeste"},
];

class NewCategoryPage extends StatefulWidget {
  const NewCategoryPage({super.key});

  @override
  State<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final categoryController = CategoryController(ImplCategoryRepository());

  String? _selectedOrthopedicBankId;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateOrthopedicBank(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione um banco ortopédico';
    }
    return null;
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await categoryController.createCategory(
      createCategoryDTO: CreateCategoryDTO(
        title: _titleController.text.trim(),
        orthopedicBankId: _selectedOrthopedicBankId!,
      ),
    );

    if (mounted) {
      result.fold(
        (success) {
          // Em caso de sucesso
          print('Categoria criada com sucesso:');
          print('ID: ${success.id}');
          print('Título: ${success.title}');
          print('Banco Ortopédico: ${success.orthopedicBank['name']}');
          print('Criado em: ${success.createdAt}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        (error) {
          // Em caso de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                categoryController.error ?? 'Erro ao criar categoria',
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
      appBar: AppBarCustom(title: "Nova Categoria"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Título da página
              const Text(
                'Criar Nova Categoria',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os dados para criar uma nova categoria',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 32),

              // Campo Título
              const Text(
                'Título *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _titleController,
                hint: 'Digite o título da categoria',
                icon: LucideIcons.tag,
                validator: _validateTitle,
              ),

              const SizedBox(height: 24),

              // Campo Banco Ortopédico
              const Text(
                'Banco Ortopédico *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SelectField<String>(
                value: _selectedOrthopedicBankId,
                hint: 'Selecione um banco ortopédico',
                icon: LucideIcons.building,
                validator: _validateOrthopedicBank,
                items:
                    orthopedicBanks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['id'],
                        child: Text(bank['name']),
                      );
                    }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedOrthopedicBankId = value;
                  });
                },
              ),

              const Spacer(),

              // Botões
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
                    child: ElevatedButton(
                      onPressed:
                          categoryController.isLoading ? null : _saveCategory,
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
