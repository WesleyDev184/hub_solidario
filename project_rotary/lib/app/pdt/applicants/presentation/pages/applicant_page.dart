import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/create_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/delete_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/edit_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/edit_beneficiary_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/widgets/action_menu_applicant.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/widgets/beneficiary_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/avatar.dart';
import 'package:project_rotary/core/components/info_row.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

final List<Map<String, dynamic>> beneficiaries = List.generate(10, (index) {
  return {
    'id': 'beneficiary_$index',
    'imageUrl': 'assets/images/dog.jpg',
    'name': 'Beneficiário ${index + 1}',
    'cpf': '000.000.00${index + 1}-00',
    'phone': '(00) 00000-000${index + 1}',
    'email': 'beneficiario${index + 1}@example.com',
    'address': 'Rua Exemplo, ${index + 1}, Bairro, Cidade, Estado',
  };
});

class ApplicantPage extends StatelessWidget {
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

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuApplicant(
          onCreatedPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => CreateBeneficiaryPage(
                      applicantId: applicantId,
                      applicantName: name,
                    ),
              ),
            );
          },
          onEditPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => EditApplicantPage(
                      applicantId: applicantId,
                      currentName: name,
                      currentCpf: cpf,
                      currentEmail: email,
                      currentPhoneNumber: phone,
                      currentAddress: address,
                      currentIsBeneficiary: beneficiaryStatus,
                    ),
              ),
            );
          },
          onDeletePressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DeleteApplicantPage(
                      applicantId: applicantId,
                      applicantName: name,
                      applicantCpf: cpf,
                      applicantEmail: email,
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
      backgroundColor: Colors.transparent, // ou CustomColors.transparent
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
            const SizedBox(height: 5),
            InfoRow(
              icon: LucideIcons.user,
              label: 'E beneficiário: ${beneficiaryStatus ? 'Sim' : 'Não'}',
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

            const SizedBox(height: 16),
            const Text(
              'Beneficiários:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomColors.primary,
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: beneficiaries.length,
                itemBuilder: (context, index) {
                  final beneficiary = beneficiaries[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => BeneficiaryPage(
                                beneficiaryId: beneficiary["id"],
                                name: beneficiary["name"],
                                cpf: beneficiary["cpf"],
                                phone: beneficiary["phone"],
                                email: beneficiary["email"],
                                address: beneficiary["address"],
                                imageUrl: beneficiary["imageUrl"],
                              ),
                        ),
                      );
                    },
                    child: BeneficiaryCard(
                      id: beneficiary["id"]!,
                      imageUrl: beneficiary["imageUrl"],
                      name: beneficiary["name"]!,
                      cpf: beneficiary["cpf"]!,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => EditBeneficiaryPage(
                                  beneficiaryId: beneficiary["id"]!,
                                  currentName: beneficiary["name"]!,
                                  currentCpf: beneficiary["cpf"]!,
                                  currentEmail: beneficiary["email"]!,
                                  currentPhoneNumber: beneficiary["phone"]!,
                                  currentAddress: beneficiary["address"],
                                ),
                          ),
                        );
                      },
                      onDelete: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => DeleteBeneficiaryPage(
                                  beneficiaryId: beneficiary["id"]!,
                                  beneficiaryName: beneficiary["name"]!,
                                  beneficiaryCpf: beneficiary["cpf"]!,
                                  beneficiaryEmail: beneficiary["email"]!,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: CustomColors.white),
      ),
    );
  }
}
