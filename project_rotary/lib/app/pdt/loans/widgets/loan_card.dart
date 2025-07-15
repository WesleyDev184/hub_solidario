import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/pages/finalize_loan_page.dart';
import 'package:project_rotary/app/pdt/loans/pages/loan_page.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class LoanCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final LoanListItem loan;
  final Function()? loadData;

  const LoanCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.loan,
    required this.loadData,
  });

  Widget _buildImage() {
    // Verifica se é uma URL web (começa com http:// ou https://)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: 120,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 130,
            color: Colors.grey.shade200,
            child: Icon(LucideIcons.image, color: Colors.grey, size: 48),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 130,
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
      );
    } else {
      // É um asset local
      return Image.asset(
        imageUrl,
        width: 120,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 130,
            color: Colors.grey.shade200,
            child: Icon(LucideIcons.image, color: Colors.grey, size: 48),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serialCodeText =
        "Empréstimo do item: ${CoreUtils.Formats.formatSerialCode(loan.item)}"; // Variável criada

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
                  child: _buildImage(),
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
                        loan.applicant,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CoreUtils.DateUtils.formatDateBR(loan.createdAt),
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
                            onPressed: () async {
                              final res = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => LoanPage(loanId: id, loan: loan),
                                ),
                              );

                              if (res == true) {
                                loadData?.call();
                              }
                            },
                            icon: Icon(
                              LucideIcons.info,
                              color: CustomColors.white,
                            ),
                            backgroundColor: CustomColors.border,
                          ),
                          const SizedBox(width: 8),
                          Button(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => FinalizeLoanPage(
                                        loanId: id,
                                        loanSerialCode: serialCodeText,
                                        loanApplicant: loan.applicant,
                                        loanDate: CoreUtils
                                            .DateUtils.formatDateBR(
                                          loan.createdAt,
                                        ),
                                      ),
                                ),
                              );
                            },
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
