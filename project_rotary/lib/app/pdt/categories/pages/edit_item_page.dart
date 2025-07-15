import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class EditItemPage extends StatefulWidget {
  final String itemId;
  final String stockId;
  final int currentSerialCode;
  final ItemStatus currentStatus;

  const EditItemPage({
    super.key,
    required this.itemId,
    required this.stockId,
    required this.currentSerialCode,
    required this.currentStatus,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serialCodeController = TextEditingController();
  late ItemStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serialCodeController.text = _formatSerialCode(widget.currentSerialCode);
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _serialCodeController.dispose();
    super.dispose();
  }

  String _formatSerialCode(int code) {
    final codeStr = code.toString().padLeft(8, '0');
    return '${codeStr.substring(0, 4)}-${codeStr.substring(4)}';
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
        int.tryParse(cleanedSerial) != widget.currentSerialCode;
    final statusChanged = _selectedStatus != widget.currentStatus;
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
    setState(() {
      _isLoading = true;
    });
    try {
      final cleanedSerial = _serialCodeController.text.trim().replaceAll(
        '-',
        '',
      );
      final request = UpdateItemRequest(
        serialCode: int.parse(cleanedSerial),
        status: _selectedStatus,
      );
      final result = await ItemsService.updateItem(widget.itemId, request);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        result.fold(
          (item) async {
            final stocks = await StocksService.getStocksByOrthopedicBank();

            stocks.fold(
              (stocks) async {
                final temp = stocks.firstWhere(
                  (stock) => stock.id == widget.stockId,
                  orElse: () => throw Exception('Estoque não encontrado'),
                );

                // Atualiza os valores de acordo com a troca de status
                int availableQtd = temp.availableQtd;
                int maintenanceQtd = temp.maintenanceQtd;
                int totalQtd = temp.totalQtd;

                // Remove do status antigo
                if (widget.currentStatus == ItemStatus.available) {
                  availableQtd -= 1;
                } else if (widget.currentStatus == ItemStatus.maintenance) {
                  maintenanceQtd -= 1;
                }

                // Adiciona ao novo status
                if (_selectedStatus == ItemStatus.available) {
                  availableQtd += 1;
                } else if (_selectedStatus == ItemStatus.maintenance) {
                  maintenanceQtd += 1;
                }

                // O totalQtd não muda ao editar status, apenas ao criar/deletar item
                final updatedStock = temp.copyWith(
                  availableQtd: availableQtd,
                  maintenanceQtd: maintenanceQtd,
                  totalQtd: totalQtd,
                );

                await StocksService.cacheStock(updatedStock);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item atualizado com sucesso!'),
                    backgroundColor: CustomColors.success,
                  ),
                );
                Navigator.pop(context, updatedStock);
              },
              (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao carregar Estoques: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Editar Item"),
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
                items:
                    ItemStatus.values
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
              const Spacer(),
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
                      onPressed: _isLoading ? null : _updateItem,
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
