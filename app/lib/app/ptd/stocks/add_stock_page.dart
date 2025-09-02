import 'dart:io';

import 'package:app/core/api/hubs/controllers/hubs_controller.dart';
import 'package:app/core/api/stocks/stocks.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/image_uploader.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/core/widgets/select_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
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
  void initState() async {
    super.initState();

    final hubsController = Get.find<HubsController>();

    final result = await hubsController.loadHubs();

    result.fold(
      (hubs) {
        orthopedicBankItems = <DropdownMenuItem<String>>[
          for (var hub in hubs) ...[
            DropdownMenuItem<String>(
              value: hub.id,
              child: Text('${hub.name} - ${hub.city}'),
            ),
          ],
        ];
      },
      (error) {
        // Lida com o erro ao carregar os hubs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar bancos ortopédicos: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
    // Seleciona automaticamente o primeiro item da lista
    if (orthopedicBankItems.isNotEmpty && _selectedOrthopedicBankId == null) {
      _selectedOrthopedicBankId = orthopedicBankItems.first.value;
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

  Future<void> _saveStock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validação da imagem obrigatória
    if (_selectedImageFile == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma imagem para o estoque'),
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
      hubId: _selectedOrthopedicBankId!,
      imageFile: _selectedImageFile,
      imageBytes: _selectedImageBytes,
      imageFileName: _selectedImageFile?.path.split('/').last,
    );

    try {
      final stockController = Get.find<StocksController>();

      final response = await stockController.createStock(data);

      response.fold(
        (stockId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estoque criado com sucesso!'),
              backgroundColor: CustomColors.success,
            ),
          );

          context.go(RoutePaths.ptd.stocks);
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar estoque: $error'),
              backgroundColor: CustomColors.error,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar estoque: $e'),
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
      appBar: AppBarCustom(title: "Novo Estoque", path: RoutePaths.ptd.stocks),
      backgroundColor: CustomColors.background,
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
                  'Criar Novo Estoque',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para criar um novo estoque',
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
                  hint: 'Digite o título do estoque',
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
                  'Selecione uma imagem para o estoque',
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
                  hint: 'Selecione uma imagem para o estoque',
                  isRequired: true,
                  height: 200,
                ),
                const SizedBox(height: 32),
                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go(RoutePaths.ptd.stocks),
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
                        onPressed: _isLoading ? null : _saveStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
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
