import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/new_category_page.dart';
import 'package:project_rotary/app/pdt/loans/presentation/widgets/action_menu_loans.dart';
import 'package:project_rotary/app/pdt/loans/presentation/widgets/loan_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

final List<Map<String, dynamic>> loansData = List.generate(10, (index) {
  return {
    "id": "${index + 1}",
    "imageUrl": "assets/images/cr.jpg",
    "applicant": "Pessoa ${index + 1}",
    "serialCode": 1000 + (index * 137) % 9000,
    "date": "15/05/2025",
    "responsible": "Responsável ${index + 1}",
    "beneficiary": "Beneficiário ${index + 1}",
    "returnDate": "15/06/2025",
    "status": index % 2 == 0 ? "Ativo" : "devolvido",
  };
});

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredLoans = [];

  @override
  void initState() {
    super.initState();
    filteredLoans = List.from(loansData);
    searchController.addListener(filterLoans);
  }

  void filterLoans() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredLoans = List.from(loansData);
      } else {
        filteredLoans =
            loansData.where((loan) {
              final title = loan["title"].toString().toLowerCase();
              return title.contains(query);
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

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuLoans(
          onBorrowPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewCategoryPage()),
            );
          },
        );
      },
    );
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
              child: AnimationLimiter(
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
                              id: loan["id"] as String,
                              imageUrl: loan["imageUrl"] as String,
                              name: loan["applicant"] as String,
                              serialCode: loan["serialCode"] as int,
                              date: loan["date"] as String,
                              beneficiary: loan["beneficiary"] as String,
                              responsible: loan["responsible"] as String,
                              returnDate: loan["returnDate"] as String,
                              status: loan["status"] as String,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: Colors.white),
      ),
    );
  }
}
