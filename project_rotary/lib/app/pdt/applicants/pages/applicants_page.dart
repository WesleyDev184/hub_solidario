import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/create_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/edit_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/widgets/applicants_card.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final TextEditingController searchController = TextEditingController();
  List<Applicant> applicants = [];
  List<Applicant> filteredApplicants = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterApplicants);
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApplicantsService.getApplicants();

      result.fold(
        (loadedApplicants) {
          setState(() {
            applicants = loadedApplicants;
            filteredApplicants = List.from(applicants);
            isLoading = false;
          });
        },
        (failure) {
          setState(() {
            errorMessage = 'Erro ao carregar solicitantes: $failure';
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar solicitantes: $e';
        isLoading = false;
      });
    }
  }

  void filterApplicants() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredApplicants =
          query.isEmpty
              ? List.from(applicants)
              : applicants.where((applicant) {
                final name = (applicant.name ?? '').toLowerCase();
                final cpf = (applicant.cpf ?? '').toLowerCase();
                final email = (applicant.email ?? '').toLowerCase();
                final phone = (applicant.phoneNumber ?? '').toLowerCase();

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
      floatingActionButton: FloatingActionButton(
        heroTag: "applicants_list_fab",
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateApplicantPage()),
          );
          if (result == true) {
            _loadApplicants();
          }
        },
        child: const Icon(LucideIcons.plus),
      ),
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
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadApplicants,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (filteredApplicants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.users, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchController.text.isEmpty
                  ? 'Nenhum solicitante encontrado'
                  : 'Nenhum resultado para "${searchController.text}"',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
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
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => ApplicantPage(
                              applicantId: applicant.id,
                              name: applicant.name ?? '',
                              imageUrl: 'assets/images/dog.jpg',
                              cpf: applicant.cpf ?? '',
                              phone: applicant.phoneNumber ?? '',
                              email: applicant.email ?? '',
                              address: applicant.address,
                              beneficiaryStatus: applicant.isBeneficiary,
                            ),
                      ),
                    );
                    if (result == true) {
                      _loadApplicants();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: ApplicantsCard(
                      id: applicant.id,
                      imageUrl: 'assets/images/dog.jpg',
                      name: applicant.name ?? '',
                      qtd: applicant.beneficiaryQtd,
                      beneficiary: applicant.isBeneficiary,
                      onEdit: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => EditApplicantPage(
                                  applicantId: applicant.id,
                                  currentName: applicant.name ?? '',
                                  currentCpf: applicant.cpf ?? '',
                                  currentEmail: applicant.email ?? '',
                                  currentPhoneNumber:
                                      applicant.phoneNumber ?? '',
                                  currentAddress: applicant.address,
                                  currentIsBeneficiary: applicant.isBeneficiary,
                                ),
                          ),
                        );
                        if (result == true) {
                          _loadApplicants();
                        }
                      },
                      onDelete: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => DeleteApplicantPage(
                                  applicantId: applicant.id,
                                  applicantName: applicant.name ?? '',
                                  applicantCpf: applicant.cpf ?? '',
                                  applicantEmail: applicant.email ?? '',
                                ),
                          ),
                        );
                        if (result == true) {
                          _loadApplicants();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
