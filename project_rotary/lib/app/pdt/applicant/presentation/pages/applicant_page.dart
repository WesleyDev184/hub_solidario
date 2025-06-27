import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicant/presentation/widgets/beneficiary_card.dart';
import 'package:project_rotary/app/pdt/beneficiary/presentation/pages/beneficiary_page.dart';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash,
                        color: CustomColors.error,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
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
                    ),
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
