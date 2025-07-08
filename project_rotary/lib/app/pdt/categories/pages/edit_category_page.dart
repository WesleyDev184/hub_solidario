import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  final TextEditingController _availableController = TextEditingController();
  final TextEditingController _maintenanceController = TextEditingController();
  final TextEditingController _borrowedController = TextEditingController();

  bool _isLoading = false;

  // Campos para upload de imagem
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
    _availableController.text = widget.currentAvailable.toString();
    _maintenanceController.text = widget.currentInMaintenance.toString();
    _borrowedController.text = widget.currentInUse.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _availableController.dispose();
    _maintenanceController.dispose();
    _borrowedController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final number = int.tryParse(value.trim());
      if (number == null || number < 0) {
        return 'Deve ser um número válido maior ou igual a zero';
      }
    }
    return null;
  }

  bool _hasChanges() {
    return _titleController.text.trim() != widget.currentTitle ||
        int.tryParse(_availableController.text.trim()) !=
            widget.currentAvailable ||
        int.tryParse(_maintenanceController.text.trim()) !=
            widget.currentInMaintenance ||
        int.tryParse(_borrowedController.text.trim()) != widget.currentInUse ||
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
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modifique apenas os campos que deseja alterar',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 32),

              const Text(
                'Título',
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

              const Text(
                'Quantidade Disponível',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _availableController,
                hint: 'Quantidade disponível',
                icon: LucideIcons.check,
                validator: _validateNumber,
              ),

              const SizedBox(height: 24),

              const Text(
                'Quantidade Em Manutenção',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _maintenanceController,
                hint: 'Quantidade em manutenção',
                icon: LucideIcons.wrench,
                validator: _validateNumber,
              ),

              const SizedBox(height: 24),

              const Text(
                'Quantidade Emprestada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _borrowedController,
                hint: 'Quantidade emprestada',
                icon: LucideIcons.userCheck,
                validator: _validateNumber,
              ),

              const SizedBox(height: 24),

              const Text(
                'Imagem da Categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecione uma nova imagem ou mantenha a atual',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
      ),
    );
  }
}
