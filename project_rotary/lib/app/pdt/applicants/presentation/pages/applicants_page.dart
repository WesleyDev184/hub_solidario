import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/edit_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/widgets/applicants_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

final List<Map<String, dynamic>> applicantsData = List.generate(10, (index) {
  return {
    'id': 'applicant_$index',
    'imageUrl': 'assets/images/dog.jpg',
    'name': 'Solicitante ${index + 1}',
    'cpf': '000.000.00${index + 1}-00',
    'phone': '(00) 00000-000${index + 1}',
    'email': 'solicitante${index + 1}@email.com',
    'address': 'Rua Exemplo, ${index + 1}, Bairro, Cidade, Estado',
    'isBeneficiary': index % 2 == 0 ? true : false,
    'qtdBeneficiaries': index + 1, // add an integer value here
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
                final name = applicant["name"].toString().toLowerCase();
                final cpf = applicant["cpf"].toString().toLowerCase();
                final email = applicant["email"].toString().toLowerCase();
                final phone = applicant["phone"].toString().toLowerCase();

                return name.contains(query) ||
                    cpf.contains(query) ||
                    email.contains(query) ||
                    phone.contains(query);
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
                                        name: applicant["name"],
                                        imageUrl: applicant["imageUrl"],
                                        cpf: applicant["cpf"],
                                        phone: applicant["phone"],
                                        email: applicant["email"],
                                        address: applicant["address"],
                                        beneficiaryStatus:
                                            applicant["isBeneficiary"],
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: ApplicantsCard(
                                id: applicant["id"] as String,
                                imageUrl: applicant["imageUrl"] as String?,
                                name: applicant["name"] as String,
                                qtd: applicant["qtdBeneficiaries"] as int,
                                beneficiary:
                                    applicant["isBeneficiary"] ?? false,
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditApplicantPage(
                                            applicantId: applicant["id"],
                                            currentName: applicant["name"],
                                            currentCpf: applicant["cpf"],
                                            currentEmail: applicant["email"],
                                            currentPhoneNumber:
                                                applicant["phone"],
                                            currentAddress:
                                                applicant["address"],
                                            currentIsBeneficiary:
                                                applicant["isBeneficiary"] ??
                                                false,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DeleteApplicantPage(
                                            applicantId: applicant["id"],
                                            applicantName: applicant["name"],
                                            applicantCpf: applicant["cpf"],
                                            applicantEmail: applicant["email"],
                                          ),
                                    ),
                                  );
                                },
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
