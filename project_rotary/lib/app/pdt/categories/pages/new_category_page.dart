import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/image_uploader.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class NewCategoryPage extends StatefulWidget {
  const NewCategoryPage({super.key});

  @override
  State<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  String? _selectedOrthopedicBankId;
  List<Map<String, dynamic>> _orthopedicBanks = [
    {"id": "1", "name": "Banco Ortopédico Central - São Paulo"},
    {"id": "2", "name": "Instituto de Ortopedia - Rio de Janeiro"},
    {"id": "3", "name": "Centro Ortopédico Belo Horizonte - Belo Horizonte"},
    {"id": "4", "name": "Clínica Ortopédica Norte - Brasília"},
    {"id": "5", "name": "Hospital Ortopédico Sul - Porto Alegre"},
  ];
  bool _isLoadingBanks = false;
  bool _isLoading = false;

  // Campo para indicar se uma imagem foi selecionada
  bool _hasSelectedImage = false;

  @override
  void initState() {
    super.initState();
    // Seleciona o primeiro banco por padrão
    if (_orthopedicBanks.isNotEmpty) {
      _selectedOrthopedicBankId = _orthopedicBanks.first["id"];
    }
  }

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

  void _onImageSelected(File? file, Uint8List? bytes) {
    setState(() {
      _hasSelectedImage = true;
    });
  }

  void _onImageRemoved() {
    setState(() {
      _hasSelectedImage = false;
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOrthopedicBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um banco ortopédico'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validação da imagem obrigatória
    if (!_hasSelectedImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma imagem para a categoria'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simula um delay de salvamento
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Em caso de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria criada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Retornar com indicação de sucesso para recarregar a lista
      Navigator.pop(context, true);
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
              _isLoadingBanks
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: CustomColors.primary,
                    ),
                  )
                  : SelectField<String>(
                    value: _selectedOrthopedicBankId,
                    hint: 'Selecione um banco ortopédico',
                    icon: LucideIcons.building,
                    validator: _validateOrthopedicBank,
                    items:
                        _orthopedicBanks.map((bank) {
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

              const SizedBox(height: 24),

              // Campo Imagem
              const Text(
                'Imagem *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ImageUploader(
                onImageSelected: _onImageSelected,
                onImageRemoved: _onImageRemoved,
                hint: 'Selecione uma imagem para a categoria',
                isRequired: true,
                height: 200,
              ),

              const Spacer(),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => Navigator.pop(context, false),
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
                      onPressed: _isLoading ? null : _saveCategory,

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
