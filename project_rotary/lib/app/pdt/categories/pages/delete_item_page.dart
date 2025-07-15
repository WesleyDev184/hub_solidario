import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class DeleteItemPage extends StatefulWidget {
  final String itemId;
  final String stockId;
  final int itemSerialCode;
  final ItemStatus status;

  const DeleteItemPage({
    super.key,
    required this.itemId,
    required this.stockId,
    required this.itemSerialCode,
    required this.status,
  });

  @override
  State<DeleteItemPage> createState() => _DeleteItemPageState();
}

class _DeleteItemPageState extends State<DeleteItemPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteCategory() async {
    setState(() {
      _isLoading = true;
    });

    final res = await ItemsService.deleteItem(widget.itemId, widget.stockId);
    res.fold(
      (success) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deletada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isLoading = false;
        });

        final stocks = await StocksService.getStocksByOrthopedicBank();

        stocks.fold(
          (stocks) async {
            final temp = stocks.firstWhere(
              (stock) => stock.id == widget.stockId,
              orElse: () => throw Exception('Estoque não encontrado'),
            );
            final Stock updatedStock;
            if (widget.status == ItemStatus.available) {
              updatedStock = temp.copyWith(
                totalQtd: temp.totalQtd - 1,
                availableQtd: temp.availableQtd - 1,
              );
            } else {
              updatedStock = temp.copyWith(
                totalQtd: temp.totalQtd - 1,
                maintenanceQtd: temp.maintenanceQtd - 1,
              );
            }

            await StocksService.cacheStock(updatedStock);

            Navigator.of(context).pop(true); // Return true to indicate deletion
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
      (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar Item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Deletar Item"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Warning Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded, color: Colors.red, size: 40),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Confirmar Exclusão',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Tem certeza de que deseja deletar o Item?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.tag, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Item a ser deletado:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CoreUtils.Formats.formatSerialCode(widget.itemSerialCode),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
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
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Atenção:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta ação não pode ser desfeita. Todos os Empréstimos relacionados a este Item também serão removidos caso estejam finalizados.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                    onPressed: _isLoading ? null : _deleteCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                              'Deletar',
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
    );
  }
}
