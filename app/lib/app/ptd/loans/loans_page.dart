import 'package:app/app/ptd/loans/widgets/loan_card.dart';
import 'package:app/core/api/loans/controllers/loans_controller.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final LoansController loansController = Get.find<LoansController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Empréstimos Ativos", initialRoute: true),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InputField(
              controller: _searchController,
              hint: "Buscar",
              icon: LucideIcons.search,
              onChanged: (value) {
                // Não precisa de setState nem variável extra
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final loans = loansController.allLoans;
                if (loansController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final searchText = _searchController.text;
                final filteredLoans = searchText.isEmpty
                    ? loans
                    : loans.where((loan) {
                        final applicant = loan.applicant
                            .toString()
                            .toLowerCase();
                        final reason = loan.reason.toString().toLowerCase();
                        final responsibleId = loan.responsible
                            .toString()
                            .toLowerCase();
                        final itemId = loan.item.toString().toLowerCase();
                        final query = searchText.toLowerCase();
                        return applicant.contains(query) ||
                            reason.contains(query) ||
                            responsibleId.contains(query) ||
                            itemId.contains(query);
                      }).toList();
                if (filteredLoans.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum empréstimo encontrado',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredLoans.length,
                  itemBuilder: (context, index) {
                    final loan = filteredLoans[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: LoanCard(
                        id: loan.id.toString(),
                        imageUrl: "assets/images/cr.jpg", // URL padrão
                        loan: loan,
                        loadData: () => loansController.loadLoans(),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
