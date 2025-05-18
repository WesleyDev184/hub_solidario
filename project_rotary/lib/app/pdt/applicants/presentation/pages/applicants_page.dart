import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicant/presentation/pages/applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/widgets/applicants_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

final List<Map<String, dynamic>> applicantsData = List.generate(10, (index) {
  return {
    'id': 'applicant_$index',
    'imageUrl': null,
    'title': 'Solicitante ${index + 1}',
    'cpf': '000.000.00${index + 1}-00',
    'phone': '(00) 00000-000${index + 1}',
    'email': 'solicitante${index + 1}@email.com',
    'address': 'Rua Exemplo, ${index + 1}, Bairro, Cidade, Estado',
    'beneficiaryStatus': index % 2 == 0 ? true : false,
    'qtd': index + 1, // add an integer value here
  };
});

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredApplicants = [];

  @override
  void initState() {
    super.initState();
    filteredApplicants = List.from(applicantsData);
    searchController.addListener(filterApplicants);
  }

  void filterApplicants() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredApplicants =
          query.isEmpty
              ? List.from(applicantsData)
              : applicantsData.where((applicant) {
                final title = applicant["title"].toString().toLowerCase();
                return title.contains(query);
              }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterApplicants);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Solicitantes"),
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
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    final applicant = filteredApplicants[index];
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
                                      (_) => ApplicantPage(
                                        applicantId: applicant["id"],
                                        name: applicant["title"],
                                        cpf: applicant["cpf"],
                                        phone: applicant["phone"],
                                        email: applicant["email"],
                                        address: applicant["address"],
                                        beneficiaryStatus:
                                            applicant["beneficiaryStatus"],
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: ApplicantsCard(
                                id: applicant["id"] as String,
                                imageUrl: applicant["imageUrl"] as String?,
                                name: applicant["title"] as String,
                                qtd: applicant["qtd"] as int,
                                beneficiary:
                                    applicant["beneficiaryStatus"] ?? false,
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
