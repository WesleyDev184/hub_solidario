import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/stocks/models/stocks_models.dart';
import 'package:project_rotary/core/api/stocks/stocks_service.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/image_uploader.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class EditCategoryPage extends StatefulWidget {
  final String categoryId;
  final String currentTitle;
  final int currentAvailable;
  final int currentInMaintenance;
  final int currentInUse;

  const EditCategoryPage({
    super.key,
    required this.categoryId,
    required this.currentTitle,
    required this.currentAvailable,
    required this.currentInMaintenance,
    required this.currentInUse,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  bool _isLoading = false;

  // Campos para upload de imagem
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  bool _hasChanges() {
    return _titleController.text.trim() != widget.currentTitle ||
        _selectedImageFile != null ||
        _selectedImageBytes != null;
  }

  void _onImageSelected(File? file, Uint8List? bytes) {
    setState(() {
      _selectedImageFile = file;
      _selectedImageBytes = bytes;
    });
  }

  void _onImageRemoved() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBytes = null;
    });
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração foi feita'),
          backgroundColor: CustomColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepara a requisição de atualização
      final updateRequest = UpdateStockRequest(
        title:
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : null,
        imageFile: _selectedImageFile,
        imageBytes: _selectedImageBytes,
        imageFileName: _selectedImageFile?.path.split('/').last,
      );

      // Chama o serviço para atualizar o stock
      final result = await StocksService.updateStock(
        widget.categoryId,
        updateRequest,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        result.fold(
          (updatedStock) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoria atualizada com sucesso!'),
                backgroundColor: CustomColors.success,
              ),
            );
            Navigator.pop(context, updatedStock);
          },
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar categoria: $error'),
                backgroundColor: CustomColors.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: CustomColors.error,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CustomColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: CustomColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Editar Categoria"),
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
                'Editar Categoria',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modifique apenas os campos que deseja alterar',
                style: TextStyle(
                  fontSize: 16,
                  color: CustomColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Título',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textPrimary,
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

              // Informações não editáveis das quantidades
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: CustomColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informações da Categoria:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      LucideIcons.check,
                      'Disponível:',
                      widget.currentAvailable.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LucideIcons.wrench,
                      'Em Manutenção:',
                      widget.currentInMaintenance.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LucideIcons.userCheck,
                      'Emprestado:',
                      widget.currentInUse.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: CustomColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Atenção:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'As quantidades não podem ser editadas diretamente. Elas são atualizadas automaticamente através dos empréstimos e devoluções.',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Imagem da Categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecione uma nova imagem ou mantenha a atual',
                style: TextStyle(
                  fontSize: 12,
                  color: CustomColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              ImageUploader(
                height: 150,
                hint: 'Toque para selecionar uma nova imagem',
                onImageSelected: _onImageSelected,
                onImageRemoved: _onImageRemoved,
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: CustomColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateCategory,
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
                                    CustomColors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Atualizar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CustomColors.white,
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
