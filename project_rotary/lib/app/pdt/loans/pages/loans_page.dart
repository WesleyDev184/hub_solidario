import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/widgets/loan_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredLoans = [];
  bool _isLoading = false;

  // Mock data for loans
  final List<Map<String, dynamic>> _mockLoans = [
    {
      'id': '1',
      'applicantId': 'João Silva',
      'responsibleId': 'Ana Oliveira',
      'itemId': 'ITM001',
      'reason': 'Uso em evento beneficente',
      'status': 'Ativo',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'dueDate': DateTime.now().add(const Duration(days: 10)),
    },
    {
      'id': '2',
      'applicantId': 'Maria Santos',
      'responsibleId': 'Carlos Lima',
      'itemId': 'ITM002',
      'reason': 'Projeto comunitário',
      'status': 'Vencido',
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
      'dueDate': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '3',
      'applicantId': 'Pedro Costa',
      'responsibleId': 'Lucia Ferreira',
      'itemId': 'ITM003',
      'reason': 'Atividade educacional',
      'status': 'Finalizado',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'dueDate': DateTime.now().subtract(const Duration(days: 15)),
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterLoans);
    filteredLoans = List.from(_mockLoans);
  }

  void filterLoans() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredLoans = List.from(_mockLoans);
      } else {
        filteredLoans =
            _mockLoans.where((loan) {
              final applicant = loan['applicantId'].toString().toLowerCase();
              final reason = loan['reason'].toString().toLowerCase();
              final responsibleId =
                  loan['responsibleId'].toString().toLowerCase();
              final itemId = loan['itemId'].toString().toLowerCase();

              return applicant.contains(query) ||
                  reason.contains(query) ||
                  responsibleId.contains(query) ||
                  itemId.contains(query);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterLoans);
    searchController.dispose();
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

            Expanded(
              child:
                  _isLoading
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
                                      id: loan['id'].toString(),
                                      imageUrl:
                                          "assets/images/cr.jpg", // URL padrão
                                      name: loan['applicantId'].toString(),
                                      serialCode:
                                          loan['itemId'].toString().hashCode,
                                      date: _formatDate(
                                        loan['createdAt'] as DateTime,
                                      ),
                                      beneficiary:
                                          loan['applicantId'].toString(),
                                      responsible:
                                          loan['responsibleId'].toString(),
                                      returnDate:
                                          loan['status'] == 'Finalizado'
                                              ? _formatDate(
                                                (loan['dueDate'] as DateTime)
                                                    .subtract(
                                                      const Duration(days: 3),
                                                    ),
                                              )
                                              : "Não devolvido",
                                      status: loan['status'].toString(),
                                      reason: loan['reason'].toString(),
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
