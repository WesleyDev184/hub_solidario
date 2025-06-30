import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/di/loan_dependency_factory.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/presentation/controller/loan_controller.dart';
import 'package:project_rotary/app/pdt/loans/presentation/widgets/loan_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final TextEditingController searchController = TextEditingController();
  late final LoanController _loanController;
  List<Loan> filteredLoans = [];

  @override
  void initState() {
    super.initState();
    _loanController = LoanDependencyFactory.instance.loanController;
    searchController.addListener(filterLoans);

    // Buscar empréstimos ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loanController.getAllLoans();
    });

    _loanController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!_loanController.isLoading && _loanController.errorMessage == null) {
      setState(() {
        filteredLoans = List.from(_loanController.loans);
      });
      filterLoans(); // Aplicar filtro se houver texto na busca
    }
  }

  void filterLoans() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredLoans = List.from(_loanController.loans);
      } else {
        filteredLoans =
            _loanController.loans.where((loan) {
              final applicant = loan.applicantId.toLowerCase();
              final reason = loan.reason.toLowerCase();
              final responsibleId = loan.responsibleId.toLowerCase();

              return applicant.contains(query) ||
                  reason.contains(query) ||
                  responsibleId.contains(query);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterLoans);
    searchController.dispose();
    _loanController.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Empréstimos Ativos"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InputField(
              controller: searchController,
              hint: "Buscar",
              icon: LucideIcons.search,
            ),
            const SizedBox(height: 16),

            // Exibir erro se houver
            if (_loanController.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loanController.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _loanController.clearError(),
                      icon: Icon(LucideIcons.x, color: Colors.red.shade600),
                    ),
                  ],
                ),
              ),

            Expanded(
              child:
                  _loanController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredLoans.isEmpty
                      ? const Center(
                        child: Text(
                          'Nenhum empréstimo encontrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : AnimationLimiter(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredLoans.length,
                          itemBuilder: (context, index) {
                            final loan = filteredLoans[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: LoanCard(
                                      id: loan.id,
                                      imageUrl:
                                          "assets/images/cr.jpg", // URL padrão
                                      name:
                                          loan.applicantId, // Usar applicantId como nome temporariamente
                                      serialCode:
                                          loan
                                              .id
                                              .hashCode, // Usar hash do ID como serialCode
                                      date: _formatDate(loan.createdAt),
                                      beneficiary:
                                          loan.applicantId, // Usar applicantId como beneficiário
                                      responsible: loan.responsibleId,
                                      returnDate:
                                          loan.returnedAt != null
                                              ? _formatDate(loan.returnedAt!)
                                              : "Não devolvido",
                                      status:
                                          loan.isActive ? "Ativo" : "Devolvido",
                                      reason: loan.reason,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
