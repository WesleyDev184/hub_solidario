import 'package:app/app/ptd/applicants/widgets/applicants_card.dart';
import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final applicantsController = Get.find<ApplicantsController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Solicitantes", initialRoute: true),
      backgroundColor: CustomColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: "applicants_list_fab",
        onPressed: () {
          context.go(RoutePaths.ptd.addApplicant);
        },
        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InputField(
              controller: _searchController,
              hint: "Buscar",
              icon: LucideIcons.search,
              onChanged: (value) {
                // Não precisa de setState nem variável extra
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final applicants = applicantsController.allApplicants;
              if (applicantsController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final searchText = _searchController.text;
              final filteredApplicants = searchText.isEmpty
                  ? applicants
                  : applicants.where((applicant) {
                      final name = (applicant.name ?? '').toLowerCase();
                      final cpf = (applicant.cpf ?? '').toLowerCase();
                      final email = (applicant.email ?? '').toLowerCase();
                      final phone = (applicant.phoneNumber ?? '').toLowerCase();
                      return name.contains(searchText.toLowerCase()) ||
                          cpf.contains(searchText.toLowerCase()) ||
                          email.contains(searchText.toLowerCase()) ||
                          phone.contains(searchText.toLowerCase());
                    }).toList();
              if (filteredApplicants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchText.isEmpty
                            ? 'Nenhum solicitante encontrado'
                            : 'Nenhum resultado para "$searchText"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredApplicants.length,
                itemBuilder: (context, index) {
                  final applicant = filteredApplicants[index];
                  return InkWell(
                    onTap: () {
                      context.go(RoutePaths.ptd.applicantId(applicant.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 8.0,
                      ),
                      child: ApplicantsCard(
                        id: applicant.id,
                        imageUrl: applicant.profileImageUrl,
                        name: applicant.name ?? '',
                        qtd: applicant.beneficiaryQtd,
                        beneficiary: applicant.isBeneficiary,
                        onEdit: () {
                          context.go(
                            RoutePaths.ptd.applicantEdit(applicant.id),
                          );
                        },
                        onDelete: () {
                          context.go(
                            RoutePaths.ptd.applicantDelete(applicant.id),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
