import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/api/stocks/models/items_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddItemPage extends StatefulWidget {
  final String stockId;

  const AddItemPage({super.key, required this.stockId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final stocksController = Get.find<StocksController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serialCodeController = TextEditingController();
  String stockTitle = '';

  @override
  void initState() {
    super.initState();

    // Busca o título da categoria (stock) para exibir na tela
    final stock = stocksController.allStocks.firstWhere(
      (stock) => stock.id == widget.stockId,
      orElse: () => throw Exception('Stock not found'),
    );

    stockTitle = stock.title;
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
    // Remove o hífen (-) do código serial
    final cleanedValue = value.trim().replaceAll('-', '');
    final code = int.tryParse(cleanedValue);
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
      final cleanedSerialCode = _serialCodeController.text.trim().replaceAll(
        '-',
        '',
      );
      final request = CreateItemRequest(
        serialCode: int.parse(cleanedSerialCode),
        stockId: widget.stockId,
      );

      // Chama o serviço para criar o item
      final result = await stocksController.createItem(request);

      if (mounted) {
        result.fold(
          (itemId) {
            // Mostra sucesso se item foi criado
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item criado com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            context.go(RoutePaths.ptd.stockId(widget.stockId));
          },
          (failure) {
            // Mostra erro se houve falha
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao criar item: $failure'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
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
      appBar: AppBarCustom(
        title: "Adicionar Item",
        path: RoutePaths.ptd.stockId(widget.stockId),
      ),
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
                'Categoria: $stockTitle',
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
                hint: '0000-0000',
                icon: LucideIcons.hash,
                mask: InputMask.serialCode,
                validator: _validateSerialCode,
              ),

              const Spacer(),

              Obx(() {
                final isLoading = stocksController.isLoading;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(
                                RoutePaths.ptd.stockId(widget.stockId),
                              ),
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
                        onPressed: isLoading ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
