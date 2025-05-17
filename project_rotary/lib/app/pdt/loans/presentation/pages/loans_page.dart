import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loan/presentation/pages/loan_page.dart';
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

  final List<Map<String, dynamic>> loansData = [
    {
      "id": "1",
      "imageUrl": "assets/images/cr.jpg",
      "name": "João Silva",
      "title": "Empréstimo Aprovado",
      "date": "15/05/2025",
    },
    {
      "id": "3",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Carlos Souza",
      "title": "Empréstimo Aprovado",
      "date": "15/05/2025",
    },
    {
      "id": "4",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Ana Paula",
      "title": "Empréstimo Pendente",
      "date": "15/05/2025",
    },
    {
      "id": "5",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Roberto Lima",
      "title": "Empréstimo Aprovado",
      "date": "15/05/2025",
    },
    {
      "id": "6",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Fernanda Costa",
      "title": "Empréstimo Pendente",
      "date": "15/05/2025",
    },
    {
      "id": "7",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Lucas Pereira",
      "title": "Empréstimo Aprovado",
      "date": "15/05/2025",
    },
    {
      "id": "8",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Camila Santos",
      "title": "Empréstimo Pendente",
      "date": "15/05/2025",
    },
    {
      "id": "9",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Bruno Carvalho",
      "title": "Empréstimo Aprovado",
      "date": "15/05/2025",
    },
    {
      "id": "10",
      "imageUrl": "assets/images/cr.jpg",
      "name": "Patrícia Almeida",
      "title": "Empréstimo Pendente",
      "date": "15/05/2025",
    },
  ];

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
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => LoanPage(
                                        loanId: loan["id"],
                                        loanTitle: loan["title"],
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: LoanCard(
                                id: loan["id"] as String,
                                imageUrl: loan["imageUrl"] as String,
                                name: loan["name"] as String,
                                title: loan["title"] as String,
                                date: loan["date"] as String,
                              ),
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
}
