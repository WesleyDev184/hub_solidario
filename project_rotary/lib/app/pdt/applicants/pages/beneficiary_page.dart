import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/delete_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/edit_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/widgets/action_menu_beneficiary.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/avatar.dart';
import 'package:project_rotary/core/components/info_row.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class BeneficiaryPage extends StatelessWidget {
  final String beneficiaryId;
  final String name;
  final String? imageUrl;
  final String cpf;
  final String phone;
  final String email;
  final String? address;
  final String applicantName;

  const BeneficiaryPage({
    super.key,
    required this.beneficiaryId,
    required this.name,
    this.imageUrl,
    required this.cpf,
    required this.phone,
    required this.email,
    this.address,
    required this.applicantName,
  });

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuBeneficiary(
          onEditPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => EditBeneficiaryPage(
                      dependentId: beneficiaryId,
                      currentName: name,
                      currentCpf: cpf,
                      currentEmail: email,
                      currentPhoneNumber: phone,
                      currentAddress: address,
                      applicantName: applicantName,
                    ),
              ),
            );
          },
          onDeletePressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DeleteBeneficiaryPage(
                      dependentId: beneficiaryId,
                      dependentName: name,
                      dependentCpf: cpf,
                      dependentEmail: email,
                      applicantName: applicantName,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: name),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Avatar(imageUrl: imageUrl, size: 150),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
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
            InfoRow(icon: LucideIcons.idCard, label: cpf),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.phone, label: phone),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.mail, label: email),

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

            InfoRow(icon: LucideIcons.house, label: 'Residencia de $name'),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address != null && address!.isNotEmpty)
                    ...address!
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
        heroTag: "beneficiary_detail_fab",
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: CustomColors.white),
      ),
    );
  }
}
