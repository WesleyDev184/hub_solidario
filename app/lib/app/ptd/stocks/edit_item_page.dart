import 'package:app/core/api/api.dart';
import 'package:app/core/api/stocks/models/items_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/utils.dart' as CoreUtils;
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditItemPage extends StatefulWidget {
  final String itemId;
  final String stockId;

  const EditItemPage({super.key, required this.itemId, required this.stockId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final StocksController _stocksController = Get.find<StocksController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serialCodeController = TextEditingController();
  late ItemStatus _selectedStatus;

  Item? _currentItem;

  @override
  void initState() {
    super.initState();
    // Busca o item atual para preencher os campos
    final stock = _stocksController.allStocks.firstWhere(
      (stock) => stock.id == widget.stockId,
      orElse: () => throw Exception('Stock not found'),
    );

    _currentItem = stock.items?.firstWhere(
      (item) => item.id == widget.itemId,
      orElse: () => throw Exception('Item not found'),
    );

    _serialCodeController.text = CoreUtils.Formats.formatSerialCode(
      _currentItem?.serialCode ?? 0,
    );

    _selectedStatus = _currentItem?.status ?? ItemStatus.available;
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

  bool _hasChanges() {
    final cleanedSerial = _serialCodeController.text.trim().replaceAll('-', '');
    final serialChanged =
        int.tryParse(cleanedSerial) != _currentItem?.serialCode;
    final statusChanged = _selectedStatus != _currentItem?.status;
    return serialChanged || statusChanged;
  }

  Future<void> _updateItem() async {
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

    try {
      final cleanedSerial = _serialCodeController.text.trim().replaceAll(
        '-',
        '',
      );
      final request = UpdateItemRequest(
        serialCode: int.parse(cleanedSerial),
        status: _selectedStatus,
      );
      final result = await _stocksController.updateItem(widget.itemId, request);
      if (mounted) {
        result.fold(
          (item) async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item atualizado com sucesso!'),
                backgroundColor: CustomColors.success,
              ),
            );

            context.go(RoutePaths.ptd.stockId(widget.stockId));
          },
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar item: $failure'),
                backgroundColor: CustomColors.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: CustomColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: "Editar Item",
        path: RoutePaths.ptd.stockId(widget.stockId),
      ),
      backgroundColor: const Color(0xFFFFF8E1), // Amarelo claro
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
                  'Editar Item',
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        color: CustomColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Atenção: Alterar o código serial pode causar inconsistências entre o sistema e o item físico. Só edite se for realmente necessário.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CustomColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Código Serial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
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
                const SizedBox(height: 24),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ItemStatus>(
                  value: _selectedStatus,
                  items: ItemStatus.values
                      .where((status) => status != ItemStatus.unavailable)
                      .map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            CoreUtils.StatusUtils.getStatusText(status.value),
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final isLoading = _stocksController.isLoading;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
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
                          onPressed: isLoading ? null : _updateItem,
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
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
