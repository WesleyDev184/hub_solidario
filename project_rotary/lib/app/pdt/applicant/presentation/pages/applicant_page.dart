import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicant/presentation/widgets/beneficiary_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

final List<Map<String, String?>> beneficiaries = List.generate(10, (index) {
  return {
    'id': 'beneficiary_$index',
    'imageUrl': null,
    'name': 'Beneficiário ${index + 1}',
    'cpf': '000.000.00${index + 1}-00',
  };
});

class ApplicantPage extends StatelessWidget {
  final String applicantId;
  final String name;
  final String? imageUrl;
  final String cpf;
  final String phone;
  final String email;
  final String address;
  final bool beneficiaryStatus;

  const ApplicantPage({
    super.key,
    required this.applicantId,
    required this.name,
    this.imageUrl,
    required this.cpf,
    required this.phone,
    required this.email,
    required this.address,
    required this.beneficiaryStatus,
  });

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
            // Topo: Nome + ícones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColors.warning.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        beneficiaries.length.toString(),
                        style: const TextStyle(color: CustomColors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash,
                        color: CustomColors.error,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.pen,
                        color: CustomColors.warning,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informações
            InfoRow(icon: LucideIcons.idCard, label: cpf),
            const SizedBox(height: 16),
            InfoRow(icon: LucideIcons.phone, label: phone),
            const SizedBox(height: 16),
            InfoRow(icon: LucideIcons.mail, label: email),
            const SizedBox(height: 16),
            InfoRow(
              icon: LucideIcons.user,
              label: 'E beneficiário: ${beneficiaryStatus ? 'Sim' : 'Não'}',
            ),
            const SizedBox(height: 16),

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

            InfoRow(icon: LucideIcons.house, label: 'Residencia de jhon doe'),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...address
                      .split(',')
                      .map((section) => Text('${section.trim()},'))
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Beneficiários:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomColors.primary,
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: beneficiaries.length,
                itemBuilder: (context, index) {
                  final beneficiary = beneficiaries[index];
                  return BeneficiaryCard(
                    id: beneficiary["id"]!,
                    imageUrl: beneficiary["imageUrl"],
                    name: beneficiary["name"]!,
                    cpf: beneficiary["cpf"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CustomColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
