import 'package:app/core/api/api.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/utils.dart' as CoreUtils;
import 'package:app/core/widgets/button.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoanCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final LoanListItem loan;

  const LoanCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.loan,
  });

  Widget _buildImage() {
    // Adiciona uma borda à imagem usando Container e BoxDecoration
    final borderRadius = BorderRadius.circular(12);
    final border = Border.all(
      color: CustomColors.primarySwatch.shade100,
      width: 2,
    );
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: Image.network(
                  imageUrl,
                  cacheWidth: 120,
                  cacheHeight: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Icon(
                        LucideIcons.image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
            ),
          ],
        ),
      );
    } else {
      // É um asset local
      return SizedBox(
        width: 120,
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: Image.asset(
                  imageUrl,
                  cacheWidth: 120,
                  cacheHeight: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 130,
                      color: Colors.grey.shade200,
                      child: Icon(
                        LucideIcons.image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
            ),
          ],
        ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(),
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
                            onPressed: () {
                              context.go(RoutePaths.ptd.loanId(loan.id));
                            },
                            icon: LucideIcons.info,
                            color: CustomColors.border,
                          ),
                          const SizedBox(width: 8),
                          Button(
                            onPressed: () {
                              context.go(RoutePaths.ptd.loanFinalize(loan.id));
                            },
                            icon: LucideIcons.arrowLeft,
                            color: CustomColors.success,
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
