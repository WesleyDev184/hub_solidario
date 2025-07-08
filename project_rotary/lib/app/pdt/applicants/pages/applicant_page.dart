import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/create_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/delete_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/edit_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/edit_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/widgets/action_menu_applicant.dart';
import 'package:project_rotary/app/pdt/applicants/widgets/beneficiary_card.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/avatar.dart';
import 'package:project_rotary/core/components/info_row.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class ApplicantPage extends StatefulWidget {
  final String applicantId;
  final String name;
  final String? imageUrl;
  final String cpf;
  final String phone;
  final String email;
  final String? address;
  final bool beneficiaryStatus;

  const ApplicantPage({
    super.key,
    required this.applicantId,
    required this.name,
    this.imageUrl,
    required this.cpf,
    required this.phone,
    required this.email,
    this.address,
    required this.beneficiaryStatus,
  });

  @override
  State<ApplicantPage> createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  Applicant? applicant;
  List<Dependent> dependents = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplicantData();
  }

  Future<void> _loadApplicantData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Load applicant details
    final applicantResult = await ApplicantsService.getApplicant(
      widget.applicantId,
    );

    applicantResult.fold(
      (loadedApplicant) {
        setState(() {
          applicant = loadedApplicant;
          dependents = loadedApplicant.dependents ?? [];
          isLoading = false;
        });
      },
      (failure) {
        setState(() {
          errorMessage = 'Erro ao carregar dados: $failure';
          isLoading = false;
        });
      },
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuApplicant(
          onCreatedPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => CreateBeneficiaryPage(
                      applicantId: widget.applicantId,
                      applicantName: widget.name,
                    ),
              ),
            );
            if (result == true) {
              _loadApplicantData();
            }
          },
          onEditPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => EditApplicantPage(
                      applicantId: widget.applicantId,
                      currentName: widget.name,
                      currentCpf: widget.cpf,
                      currentEmail: widget.email,
                      currentPhoneNumber: widget.phone,
                      currentAddress: widget.address,
                      currentIsBeneficiary: widget.beneficiaryStatus,
                    ),
              ),
            );
            if (result == true) {
              _loadApplicantData();
            }
          },
          onDeletePressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DeleteApplicantPage(
                      applicantId: widget.applicantId,
                      applicantName: widget.name,
                      applicantCpf: widget.cpf,
                      applicantEmail: widget.email,
                    ),
              ),
            );
            if (result == true) {
              Navigator.of(context).pop(true);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBarCustom(title: widget.name),
        backgroundColor: Colors.transparent,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBarCustom(title: widget.name),
        backgroundColor: Colors.transparent,
        body: Center(
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
                onPressed: _loadApplicantData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final currentApplicant =
        applicant ??
        Applicant(
          id: widget.applicantId,
          name: widget.name,
          cpf: widget.cpf,
          email: widget.email,
          phoneNumber: widget.phone,
          address: widget.address,
          isBeneficiary: widget.beneficiaryStatus,
          beneficiaryQtd: 0,
          createdAt: DateTime.now(),
        );

    return Scaffold(
      appBar: AppBarCustom(title: currentApplicant.name ?? 'Solicitante'),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Avatar(imageUrl: widget.imageUrl, size: 150),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentApplicant.name ?? 'Nome não informado',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informações
            InfoRow(
              icon: LucideIcons.idCard,
              label: currentApplicant.cpf ?? 'CPF não informado',
            ),
            const SizedBox(height: 5),
            InfoRow(
              icon: LucideIcons.phone,
              label: currentApplicant.phoneNumber ?? 'Telefone não informado',
            ),
            const SizedBox(height: 5),
            InfoRow(
              icon: LucideIcons.mail,
              label: currentApplicant.email ?? 'Email não informado',
            ),
            const SizedBox(height: 5),
            InfoRow(
              icon: LucideIcons.user,
              label:
                  'É beneficiário: ${currentApplicant.isBeneficiary ? 'Sim' : 'Não'}',
            ),

            const SizedBox(height: 12),
            const Text(
              'Endereço:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            InfoRow(
              icon: LucideIcons.house,
              label: 'Residência de ${currentApplicant.name ?? 'Solicitante'}',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentApplicant.address != null &&
                      currentApplicant.address!.isNotEmpty)
                    ...currentApplicant.address!
                        .split('\n')
                        .map(
                          (line) =>
                              Text(line, style: const TextStyle(fontSize: 14)),
                        )
                        .toList()
                  else
                    const Text(
                      'Endereço não informado',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dependentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primary,
                  ),
                ),
                Text(
                  '${dependents.length} dependente(s)',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child:
                  dependents.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum dependente cadastrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: dependents.length,
                        itemBuilder: (context, index) {
                          final dependent = dependents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => BeneficiaryPage(
                                          beneficiaryId: dependent.id,
                                          name: dependent.name ?? '',
                                          imageUrl: 'assets/images/dog.jpg',
                                          cpf: dependent.cpf ?? '',
                                          phone: dependent.phoneNumber ?? '',
                                          email: dependent.email ?? '',
                                          address: dependent.address,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _loadApplicantData();
                                }
                              },
                              child: BeneficiaryCard(
                                id: dependent.id,
                                imageUrl: 'assets/images/dog.jpg',
                                name: dependent.name ?? 'Nome não informado',
                                cpf: dependent.cpf ?? 'CPF não informado',
                                onEdit: () async {
                                  final result = await Navigator.of(
                                    context,
                                  ).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditBeneficiaryPage(
                                            beneficiaryId: dependent.id,
                                            currentName: dependent.name ?? '',
                                            currentCpf: dependent.cpf ?? '',
                                            currentEmail: dependent.email ?? '',
                                            currentPhoneNumber:
                                                dependent.phoneNumber ?? '',
                                            currentAddress: dependent.address,
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadApplicantData();
                                  }
                                },
                                onDelete: () async {
                                  final result = await Navigator.of(
                                    context,
                                  ).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DeleteBeneficiaryPage(
                                            beneficiaryId: dependent.id,
                                            beneficiaryName:
                                                dependent.name ?? '',
                                            beneficiaryCpf: dependent.cpf ?? '',
                                            beneficiaryEmail:
                                                dependent.email ?? '',
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadApplicantData();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "applicant_detail_fab",
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: CustomColors.white),
      ),
    );
  }
}
