import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class LoanPage extends StatelessWidget {
  final String loanId;
  final String loanTitle;
  final String loanResponsible;
  final String loanApplicant;
  final String loanBeneficiary;
  final String loanDate;
  final String loanReturnDate;
  final String loanStatus;

  const LoanPage({
    super.key,
    required this.loanId,
    required this.loanTitle,
    required this.loanResponsible,
    required this.loanApplicant,
    required this.loanBeneficiary,
    required this.loanDate,
    required this.loanReturnDate,
    required this.loanStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: loanTitle),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260.0,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: CustomColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/cr.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.69,
            minChildSize: 0.68,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CustomColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.textPrimary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          loanTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.textPrimary, // cor roxa escura
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Responsável
                        _buildInfoRow(
                          LucideIcons.idCard,
                          'Responsável:',
                          loanResponsible,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Solicitante
                        _buildInfoRow(
                          LucideIcons.idCard,
                          'Solicitante:',
                          loanApplicant,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Beneficiado
                        _buildInfoRow(
                          LucideIcons.idCard,
                          'Beneficiado:',
                          loanBeneficiary,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Empréstimo
                        _buildInfoRow(
                          LucideIcons.calendar,
                          'Empréstimo:',
                          loanDate,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Devolução
                        _buildInfoRow(
                          LucideIcons.calendar,
                          'Devolução:',
                          loanReturnDate,
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Button(
                        onPressed: () {},
                        text: 'Finalizar Empréstimo',
                        backgroundColor: CustomColors.success,
                        icon: Icon(
                          LucideIcons.cornerDownLeft,
                          color: CustomColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: CustomColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Icon(icon, color: CustomColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: CustomColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
