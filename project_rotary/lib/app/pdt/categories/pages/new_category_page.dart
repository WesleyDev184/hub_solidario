import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/orthopedic_banks/orthopedic_banks.dart';
import 'package:project_rotary/core/api/stocks/stocks.dart';
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
  List<DropdownMenuItem<String>> orthopedicBankItems = [];
  bool isLoadingBanks = false;
  bool _isLoading = false;
  bool hasErrorLoadingBanks = false;

  // Campos para upload de imagem
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    // Seleciona o primeiro banco por padrão
    _loadOrthopedicBanks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Método para carregar bancos ortopédicos
  Future<void> _loadOrthopedicBanks() async {
    if (isLoadingBanks) return;

    setState(() {
      isLoadingBanks = true;
      hasErrorLoadingBanks = false;
    });

    try {
      final result = await OrthopedicBanksService.getOrthopedicBanks();

      result.fold(
        (banks) {
          setState(() {
            orthopedicBankItems =
                banks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank.id,
                    child: Text('${bank.name} - ${bank.city}'),
                  );
                }).toList();

            // Seleciona automaticamente o primeiro item da lista
            if (orthopedicBankItems.isNotEmpty &&
                _selectedOrthopedicBankId == null) {
              _selectedOrthopedicBankId = orthopedicBankItems.first.value;
            }

            isLoadingBanks = false;
            hasErrorLoadingBanks = false;
          });
        },
        (error) {
          setState(() {
            isLoadingBanks = false;
            hasErrorLoadingBanks = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        isLoadingBanks = false;
        hasErrorLoadingBanks = true;
      });
    }
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

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOrthopedicBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um banco ortopédico'),
          backgroundColor: CustomColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validação da imagem obrigatória
    if (_selectedImageFile == null && _selectedImageBytes == null) {
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

    final data = CreateStockRequest(
      title: _titleController.text.trim(),
      orthopedicBankId: _selectedOrthopedicBankId!,
      imageFile: _selectedImageFile,
      imageBytes: _selectedImageBytes,
      imageFileName: _selectedImageFile?.path.split('/').last,
    );

    try {
      final response = await StocksService.createStock(data);

      response.fold(
        (categoryId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria criada com sucesso!'),
              backgroundColor: CustomColors.success,
            ),
          );

          Navigator.pop(context, true);
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar categoria: $error'),
              backgroundColor: CustomColors.error,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar categoria: $e'),
          backgroundColor: CustomColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Nova Categoria"),
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
                // Título da página
                const Text(
                  'Criar Nova Categoria',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para criar uma nova categoria',
                  style: TextStyle(
                    fontSize: 16,
                    color: CustomColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Campo Título
                const Text(
                  'Título *',
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
                // Campo Banco Ortopédico
                const Text(
                  'Banco Ortopédico *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                isLoadingBanks
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
                      items: orthopedicBankItems,
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
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecione uma imagem para a categoria',
                  style: TextStyle(
                    fontSize: 12,
                    color: CustomColors.textSecondary,
                    fontStyle: FontStyle.italic,
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
                const SizedBox(height: 32),
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
                                      CustomColors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Salvar',
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
      ),
    );
  }
}
