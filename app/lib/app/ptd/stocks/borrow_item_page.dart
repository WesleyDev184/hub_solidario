import 'package:app/core/api/api.dart';
import 'package:app/core/api/stocks/models/items_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/core/widgets/select_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BorrowItemPage extends StatefulWidget {
  final String stockId;

  const BorrowItemPage({super.key, required this.stockId});

  @override
  State<BorrowItemPage> createState() => _BorrowItemPageState();
}

class _BorrowItemPageState extends State<BorrowItemPage> {
  final _stocksController = Get.find<StocksController>();
  final _applicantsController = Get.find<ApplicantsController>();
  final _authController = Get.find<AuthController>();
  final _loansController = Get.find<LoansController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedItemId;
  String? _selectedApplicantId;
  String? _selectedResponsibleId;

  String _categoryTitle = '';

  List<DropdownMenuItem<String>> _responsible = [];
  List<DropdownMenuItem<String>> _items = [];
  List<DropdownMenuItem<String>> _applicants = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    await _loadItens();
    _loadApplicants();
    await _loadUsers();

    setState(() {});
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadItens() async {
    _categoryTitle = _stocksController.allStocks
        .firstWhere((stock) => stock.id == widget.stockId)
        .title;

    final res = await _stocksController.getItemsByStockId(widget.stockId);

    res.fold(
      (items) {
        final availableItems = items
            .where((item) => item.status == ItemStatus.available)
            .toList();

        setState(() {
          _items = availableItems.map((item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.formattedSerialCode),
            );
          }).toList();

          if (_items.isNotEmpty) {
            _selectedItemId = _items.first.value;
          } else {
            _selectedItemId = null;
          }
        });
      },
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar os itens: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _loadApplicants() {
    final applicants = _applicantsController.allApplicants;
    setState(() {
      _applicants = applicants.map((applicant) {
        return DropdownMenuItem<String>(
          value: applicant.id,
          child: Text(applicant.name ?? ''),
        );
      }).toList();

      if (_applicants.isNotEmpty) {
        _selectedApplicantId = _applicants.first.value;
      }
    });
  }

  Future<void> _loadUsers() async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final orthopedicBankId = currentUser.hub?.id;
    if (orthopedicBankId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banco ortopédico não encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final res = await _authController.getAllUsers(orthopedicBankId);
    res.fold(
      (users) {
        setState(() {
          _responsible = users.map((user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(user.name),
            );
          }).toList();

          // Seleciona automaticamente o primeiro item da lista
          if (_responsible.isNotEmpty) {
            _selectedResponsibleId = _responsible.first.value;
          }
        });
      },
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar responsáveis: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  String? _validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Motivo é obrigatório';
    }
    if (value.trim().length < 10) {
      return 'Motivo deve ter pelo menos 10 caracteres';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Selecione um $fieldName';
    }
    return null;
  }

  Future<void> _createLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = CreateLoanRequest(
      itemId: _selectedItemId!,
      applicantId: _selectedApplicantId!,
      responsibleId: _selectedResponsibleId!,
      reason: _reasonController.text.trim(),
    );

    final res = await _loansController.createLoan(data);

    res.fold(
      (success) async {
        final res = await _stocksController.updateItemAfterBorrow(
          success.item!.id,
          widget.stockId,
        );

        res.fold(
          (updatedItem) {
            // Empréstimo criado com sucesso
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Empréstimo criado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go(RoutePaths.ptd.stockId(widget.stockId));
            }
          },
          (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao atualizar item: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar empréstimo: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Criar Empréstimo"),
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
                const Text(
                  'Criar Novo Empréstimo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categoria: $_categoryTitle',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Seção de seleção
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Selection
                    const Text(
                      'Item *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Use Obx or GetBuilder if the `_items` list itself is an RxList
                    // or if changes to the StocksController should rebuild this specific dropdown.
                    // Otherwise, rely on local setState calls.
                    SelectField<String>(
                      value: _selectedItemId,
                      hint: 'Selecione um item',
                      icon: LucideIcons.package,
                      validator: (value) => _validateSelection(value, 'item'),
                      items: _items,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedItemId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Applicant Selection
                    const Text(
                      'Solicitante *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectField<String>(
                      value: _selectedApplicantId,
                      hint: 'Selecione um solicitante',
                      icon: LucideIcons.user,
                      validator: (value) =>
                          _validateSelection(value, 'solicitante'),
                      items: _applicants,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedApplicantId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Responsible Selection
                    const Text(
                      'Responsável *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectField<String>(
                      value: _selectedResponsibleId,
                      hint: 'Selecione um banco ortopédico',
                      icon: LucideIcons.building,
                      validator: (value) =>
                          _validateSelection(value, 'responsável'),
                      items: _responsible,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedResponsibleId = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Reason Field
                const Text(
                  'Motivo *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                InputField(
                  controller: _reasonController,
                  hint: 'Descreva o motivo do empréstimo...',
                  icon: LucideIcons.messageSquare,
                  validator: _validateReason,
                ),
                const SizedBox(height: 32),
                // === OBX para observar o isLoading do LoansController ===
                Obx(() {
                  final isLoading = _loansController.isLoading;
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
                          onPressed: isLoading ? null : _createLoan,
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
                                  'Criar Empréstimo',
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
      ),
    );
  }
}
