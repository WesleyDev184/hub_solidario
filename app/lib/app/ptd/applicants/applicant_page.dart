import 'package:app/app/ptd/applicants/widgets/action_menu_applicant.dart';
import 'package:app/app/ptd/applicants/widgets/dependent_card.dart';
import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/avatar.dart';
import 'package:app/core/widgets/info_row.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ApplicantPage extends StatefulWidget {
  final String applicantId;

  const ApplicantPage({super.key, required this.applicantId});

  @override
  State<ApplicantPage> createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  final _applicantsController = Get.find<ApplicantsController>();

  Applicant? applicant;

  @override
  void initState() {
    super.initState();
    _loadApplicantData();
  }

  Future<void> _loadApplicantData({bool forceRefresh = false}) async {
    // Load applicant details (que já inclui os dependentes)
    final applicantResult = await _applicantsController.getApplicant(
      widget.applicantId,
      forceRefresh: forceRefresh,
    );

    applicantResult.fold(
      (loadedApplicant) {
        setState(() {
          applicant = loadedApplicant;
        });
      },
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar solicitante: ${failure.toString()}',
            ),
          ),
        );
      },
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuApplicant(
          onCreatedPressed: () {
            // Navega para tela de adicionar dependente
            // context.go(RoutePaths.ptd.addDependent(applicantId: widget.applicantId)); // ajuste conforme sua rota
          },
          onEditPressed: () {
            // Navega para tela de editar solicitante
            // context.go(RoutePaths.ptd.editApplicant(applicantId: widget.applicantId)); // ajuste conforme sua rota
          },
          onDeletePressed: () {
            // Navega para tela de deletar solicitante
            context.go(
              RoutePaths.ptd.applicantDelete(widget.applicantId),
            ); // ajuste conforme sua rota
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentApplicant =
        applicant ??
        Applicant(
          id: widget.applicantId,
          name: 'Nome não informado',
          cpf: 'CPF não informado',
          email: 'Email não informado',
          phoneNumber: 'Telefone não informado',
          address: null,
          isBeneficiary: false,
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
                // TODO: Implementar a lógica de exibição da imagem do solicitante
                // Exemplo de imagem estática
                Avatar(imageUrl: 'assets/images/dog.jpg', size: 150),
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
                  '${currentApplicant.dependents?.length} dependente(s)',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: (currentApplicant.dependents?.isEmpty ?? true)
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum dependente cadastrado',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: currentApplicant.dependents?.length,
                      itemBuilder: (context, index) {
                        final dependent = currentApplicant.dependents?[index];
                        if (dependent == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              // Navega para detalhes do dependente
                              // context.go(RoutePaths.ptd.dependentId(
                              //     dependent.id)); // ajuste conforme sua rota
                            },
                            child: DependentCard(
                              dependent: dependent,
                              imageUrl: 'assets/images/dog.jpg',
                              applicantName: applicant?.name ?? 'Solicitante',
                              onEdit: () {
                                // Navega para tela de editar dependente
                                // context.go(RoutePaths.ptd.editDependent(
                                //     dependentId: dependent.id,
                                //     applicantId: widget.applicantId)); // ajuste conforme sua rota
                              },
                              onDelete: () {
                                // Navega para tela de deletar dependente
                                // context.go(RoutePaths.ptd.deleteDependent(
                                //     dependentId: dependent.id,
                                //     applicantId: widget.applicantId)); // ajuste conforme sua rota
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
