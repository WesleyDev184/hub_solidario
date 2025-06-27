import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/presentation/pages/loan_page.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class LoanCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String date;
  final int serialCode;
  final String responsible;
  final String beneficiary;
  final String returnDate;
  final String status;
  final String reason;

  const LoanCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.date,
    required this.serialCode,
    required this.responsible,
    required this.beneficiary,
    required this.returnDate,
    required this.status,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final serialCodeText = "Empréstimo do item: $serialCode"; // Variável criada

    return Card(
      color: CustomColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imageUrl,
                    width: 120,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        serialCodeText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: CustomColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Button(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => LoanPage(
                                        loanId: id,
                                        loanSerialCode: serialCodeText,
                                        loanApplicant: name,
                                        loanBeneficiary: beneficiary,
                                        loanResponsible: responsible,
                                        loanReturnDate: returnDate,
                                        loanStatus: status,
                                        loanDate: date,
                                        loanReason: reason,
                                      ),
                                ),
                              );
                            },
                            icon: Icon(
                              LucideIcons.info,
                              color: CustomColors.white,
                            ),
                            backgroundColor: CustomColors.border,
                          ),
                          const SizedBox(width: 8),
                          Button(
                            onPressed: () {},
                            icon: Icon(
                              LucideIcons.arrowLeft,
                              color: Colors.white,
                            ),
                            backgroundColor: CustomColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
