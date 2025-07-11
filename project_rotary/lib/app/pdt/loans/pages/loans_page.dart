import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/widgets/loan_card.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class LoansPage extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const LoansPage({super.key, this.onRefreshCallback});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final TextEditingController searchController = TextEditingController();
  List<Loan> filteredLoans = [];
  List<Loan> _loans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
    searchController.addListener(filterLoans);

    // Registra o callback para recarregar a página
    widget.onRefreshCallback?.call(_refreshPage);
  }

  void _refreshPage() {
    setState(() {
      filteredLoans = List.from(_loans);
    });
  }

  Future<void> _fetchLoans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loans = await LoansService.getLoans();

      loans.fold(
        (fetchedLoans) {
          setState(() {
            _loans = fetchedLoans;
            filteredLoans = List.from(fetchedLoans);
          });
        },
        (error) {
          // Handle error, e.g., show a snackbar or dialog
          debugPrint("Error fetching loans: $error");
        },
      );
    } catch (e) {
      // Handle error, e.g., show a snackbar or dialog
      debugPrint("Error fetching loans: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterLoans() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredLoans = List.from(_loans);
      } else {
        filteredLoans =
            _loans.where((loan) {
              final applicant = loan.applicantId.toString().toLowerCase();
              final reason = loan.reason.toString().toLowerCase();
              final responsibleId = loan.responsibleId.toString().toLowerCase();
              final itemId = loan.itemId.toString().toLowerCase();

              return applicant.contains(query) ||
                  reason.contains(query) ||
                  responsibleId.contains(query) ||
                  itemId.contains(query);
            }).toList();
      }
    });
  }

  String _formatSerialCode(int itemId) {
    String idString = itemId.toString();
    if (idString.length >= 8) {
      return '${idString.substring(0, 4)}-${idString.substring(4, 8)}';
    } else {
      // Pad with zeros if needed
      idString = idString.padLeft(8, '0');
      return '${idString.substring(0, 4)}-${idString.substring(4, 8)}';
    }
  }

  @override
  void dispose() {
    searchController.removeListener(filterLoans);
    searchController.dispose();
    _loans.clear();
    filteredLoans.clear();
    _isLoading = false;
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
                                      id: loan.id.toString(),
                                      imageUrl:
                                          "assets/images/cr.jpg", // URL padrão
                                      name: loan.applicantId.toString(),
                                      serialCode: _formatSerialCode(
                                        loan.itemId.hashCode,
                                      ),
                                      date: _formatDate(loan.createdAt),
                                      beneficiary: loan.applicantId.toString(),
                                      responsible:
                                          loan.responsibleId.toString(),
                                      returnDate: _formatDate(
                                        loan.returnDate ?? DateTime.now(),
                                      ),
                                      status:
                                          loan.isActive ? "Ativo" : "Inativo",
                                      reason: loan.reason.toString(),
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
