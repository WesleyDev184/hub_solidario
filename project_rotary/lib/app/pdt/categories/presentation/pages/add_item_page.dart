import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/di/category_dependency_factory.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/item_controller.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class AddItemPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const AddItemPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serialCodeController = TextEditingController();
  late final ItemController itemController;

  @override
  void initState() {
    super.initState();
    itemController = CategoryDependencyFactory.instance.itemController;
  }

  @override
  void dispose() {
    _serialCodeController.dispose();
    super.dispose();
  }

  String? _validateSerialCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Código serial é obrigatório';
    }
    final code = int.tryParse(value.trim());
    if (code == null) {
      return 'Código serial deve ser um número';
    }
    if (code <= 0) {
      return 'Código serial deve ser maior que zero';
    }
    return null;
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await itemController.createItem(
        createItemDTO: CreateItemDTO(
          serialCode: int.parse(_serialCodeController.text.trim()),
          stockId: widget.categoryId, // categoryId é o stockId da API
        ),
      );

      if (mounted) {
        if (itemController.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item criado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        } else {
          debugPrint('Erro ao criar item: ${itemController.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                itemController.errorMessage ?? 'Erro ao criar item',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Adicionar Item"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              Text(
                'Adicionar novo item à categoria',
                style: const TextStyle(
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

              const Text(
                'Código Serial *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _serialCodeController,
                hint: 'Digite o código serial do item',
                icon: LucideIcons.hash,
                validator: _validateSerialCode,
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          itemController.isLoading
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
                      listenable: itemController,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed:
                              itemController.isLoading ? null : _saveItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              itemController.isLoading
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
                                    'Adicionar Item',
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
