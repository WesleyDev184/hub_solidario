import 'package:app/app/ptd/applicants/widgets/action_menu_applicant.dart';
import 'package:app/app/ptd/applicants/widgets/dependent_card.dart';
import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/utils.dart' as utils;
import 'package:app/core/widgets/accordion_section.dart';
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
            context.go(RoutePaths.ptd.addDependent(widget.applicantId));
          },
          onEditPressed: () {
            context.go(RoutePaths.ptd.applicantEdit(widget.applicantId));
          },
          onDeletePressed: () {
            context.go(RoutePaths.ptd.applicantDelete(widget.applicantId));
          },
          documentsViewPressed: () {
            context.go(RoutePaths.ptd.applicantDocuments(widget.applicantId));
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
      appBar: AppBarCustom(
        title: currentApplicant.name ?? 'Solicitante',
        path: RoutePaths.ptd.applicants,
      ),
      backgroundColor: CustomColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 18),

            // Header with avatar included
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: _buildHeader(),
            ),

            // Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AccordionSection(
                    title: 'Contato',
                    icon: LucideIcons.phone,
                    children: [
                      InfoRow(
                        icon: LucideIcons.idCard,
                        label: 'CPF',
                        value: currentApplicant.cpf ?? 'CPF não informado',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: LucideIcons.phone,
                        label: 'Telefone',
                        value:
                            currentApplicant.phoneNumber ??
                            'Telefone não informado',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: LucideIcons.mail,
                        label: 'Email',
                        value: currentApplicant.email ?? 'Email não informado',
                      ),
                    ],
                  ),

                  AccordionSection(
                    title: 'Endereço',
                    icon: LucideIcons.house,
                    children: [
                      if (currentApplicant.address != null &&
                          currentApplicant.address!.isNotEmpty)
                        ...currentApplicant.address!
                            .split('\n')
                            .map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CustomColors.textPrimary,
                                  ),
                                ),
                              ),
                            )
                      else
                        const Text(
                          'Endereço não informado',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),

                  AccordionSection(
                    title: 'Dependentes',
                    icon: LucideIcons.users,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${currentApplicant.dependents?.length ?? 0} dependente(s)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (currentApplicant.dependents == null ||
                          currentApplicant.dependents!.isEmpty)
                        Center(
                          child: Column(
                            children: const [
                              Icon(
                                LucideIcons.users,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Nenhum dependente cadastrado',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: currentApplicant.dependents!.map((
                            dependent,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: () {
                                  context.go(
                                    RoutePaths.ptd.dependentId(
                                      widget.applicantId,
                                      dependent.id,
                                    ),
                                  );
                                },
                                child: DependentCard(
                                  dependent: dependent,
                                  imageUrl: dependent.profileImageUrl,
                                  applicantName:
                                      applicant?.name ?? 'Solicitante',
                                  onEdit: () {
                                    context.go(
                                      RoutePaths.ptd.dependentEdit(
                                        widget.applicantId,
                                        dependent.id,
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    context.go(
                                      RoutePaths.ptd.dependentDelete(
                                        widget.applicantId,
                                        dependent.id,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            const SizedBox(height: 20),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomColors.primary.withOpacity(0.9), CustomColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatar(
                imageUrl: applicant?.profileImageUrl ?? '',
                size: 72,
                isNetworkImage: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant?.name ?? 'Solicitante',
                      // allow long names to wrap to multiple lines instead of
                      // being truncated; keep styling the same
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: CustomColors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${applicant != null ? applicant!.phoneNumber : 'Carregando...'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: CustomColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    (applicant != null && applicant!.isBeneficiary)
                        ? 'Beneficiário'
                        : 'Não Beneficiário',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: CustomColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Desde: ${utils.DateUtils.formatDateBR(applicant?.createdAt ?? DateTime.now())}',
            style: TextStyle(
              fontSize: 13,
              color: CustomColors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return (applicant != null && applicant!.isBeneficiary)
        ? CustomColors.success
        : CustomColors.error;
  }
}
