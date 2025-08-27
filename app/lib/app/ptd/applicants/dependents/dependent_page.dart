import 'package:app/app/ptd/applicants/dependents/widgets/action_menu_dependent.dart';
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

class DependentPage extends StatefulWidget {
  final String dependentId;
  final String applicantId;

  const DependentPage({
    super.key,
    required this.dependentId,
    required this.applicantId,
  });

  @override
  State<DependentPage> createState() => _DependentPageState();
}

class _DependentPageState extends State<DependentPage> {
  final _applicantsController = Get.find<ApplicantsController>();
  Dependent? _dependent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependent();
    });
  }

  void _loadDependent() async {
    final result = await _applicantsController.getDependent(
      widget.dependentId,
      widget.applicantId,
    );

    result.fold(
      (dependent) {
        setState(() {
          _dependent = dependent;
        });
      },
      (error) {
        Get.snackbar(
          'Erro',
          'Não foi possível carregar os dados do dependente.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE8EAF6),
      builder: (BuildContext context) {
        return ActionMenuDependent(
          onEditPressed: () => {
            context.go(
              RoutePaths.ptd.dependentEdit(
                widget.applicantId,
                widget.dependentId,
              ),
            ),
          },
          onDeletePressed: () => {
            context.go(
              RoutePaths.ptd.dependentDelete(
                widget.applicantId,
                widget.dependentId,
              ),
            ),
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependent = _dependent;
    final imageUrl = dependent?.profileImageUrl ?? '';
    final dependentName = dependent?.name ?? '';
    final dependentCpf = dependent?.cpf ?? '';
    final dependentPhone = dependent?.phoneNumber ?? '';
    final dependentEmail = dependent?.email ?? '';
    final dependentAddress = dependent?.address;

    return Scaffold(
      appBar: AppBarCustom(
        title: dependentName,
        path: RoutePaths.ptd.applicantId(widget.applicantId),
      ),
      backgroundColor: CustomColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com avatar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: _buildHeader(),
              ),

              // Accordion: Informações de contato
              AccordionSection(
                title: 'Contato',
                icon: LucideIcons.phone,
                children: [
                  InfoRow(
                    icon: LucideIcons.idCard,
                    label: 'CPF',
                    value: dependentCpf,
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    icon: LucideIcons.phone,
                    label: 'Telefone',
                    value: dependentPhone,
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    icon: LucideIcons.mail,
                    label: 'Email',
                    value: dependentEmail,
                  ),
                ],
              ),

              // Accordion: Endereço
              AccordionSection(
                title: 'Endereço',
                icon: LucideIcons.house,
                children: [
                  InfoRow(
                    icon: LucideIcons.house,
                    label: 'Residência de $dependentName',
                    value:
                        (dependentAddress != null &&
                            dependentAddress.isNotEmpty)
                        ? dependentAddress
                        : 'Endereço não informado',
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "dependent_detail_fab",
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
                imageUrl: _dependent?.profileImageUrl,
                size: 72,
                isNetworkImage: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dependent?.name ?? 'Dependente',
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
                      '${_dependent != null ? _dependent!.phoneNumber : 'Carregando...'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: CustomColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Desde: ${utils.DateUtils.formatDateBR(_dependent?.createdAt ?? DateTime.now())}',
            style: TextStyle(
              fontSize: 13,
              color: CustomColors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
