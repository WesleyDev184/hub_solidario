import 'package:app/app/ptd/applicants/dependents/widgets/action_menu_dependent.dart';
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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Avatar(imageUrl: imageUrl, size: 150, isNetworkImage: true),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dependentName,
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
            InfoRow(icon: LucideIcons.idCard, label: dependentCpf),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.phone, label: dependentPhone),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.mail, label: dependentEmail),

            const SizedBox(height: 24),
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
              label: 'Residência de $dependentName',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dependentAddress != null && dependentAddress.isNotEmpty)
                    ...dependentAddress
                        .split(',')
                        .map((section) => Text('${section.trim()},'))
                  else
                    const Text('Endereço não informado'),
                ],
              ),
            ),
          ],
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
}
