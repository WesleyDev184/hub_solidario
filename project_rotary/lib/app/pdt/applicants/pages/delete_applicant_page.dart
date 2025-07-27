import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/applicants_page.dart';
import 'package:project_rotary/core/api/applicants/applicants_service.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class DeleteApplicantPage extends StatefulWidget {
  final String applicantId;
  final String applicantName;
  final String applicantCpf;
  final String applicantEmail;

  const DeleteApplicantPage({
    super.key,
    required this.applicantId,
    required this.applicantName,
    required this.applicantCpf,
    required this.applicantEmail,
  });

  @override
  State<DeleteApplicantPage> createState() => _DeleteApplicantPageState();
}

class _DeleteApplicantPageState extends State<DeleteApplicantPage> {
  bool _isLoading = false;

  Future<void> _showFinalConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Confirmação Final',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: CustomColors.textPrimary,
                  fontSize: 16,
                ),
                children: [
                  const TextSpan(text: 'Confirma a exclusão do solicitante '),
                  TextSpan(
                    text: widget.applicantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?\n\nEsta ação é '),
                  const TextSpan(
                    text: 'irreversível',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColors.error,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.error,
                  foregroundColor: CustomColors.white,
                ),
                child: const Text('Confirmar Exclusão'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteApplicant();
    }
  }

  Future<void> _deleteApplicant() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApplicantsService.deleteApplicant(widget.applicantId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.fold(
        (success) {
          // Mostra o snackbar antes de navegar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.applicantName} excluído com sucesso!'),
              backgroundColor: CustomColors.success,
              duration: const Duration(milliseconds: 1200),
            ),
          );
          // Aguarda um curto tempo para o usuário ver o snackbar
          Future.delayed(const Duration(milliseconds: 1200), () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ApplicantsPage()),
              (route) => false,
            );
          });
        },
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir solicitante: $failure'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Deletar Solicitante"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Warning Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: CustomColors.error,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Confirmar Exclusão',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Tem certeza de que deseja deletar o solicitante?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: CustomColors.textSecondary),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.user,
                        color: CustomColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Solicitante a ser deletado:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.applicantName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    LucideIcons.creditCard,
                    'CPF:',
                    widget.applicantCpf,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    LucideIcons.mail,
                    'Email:',
                    widget.applicantEmail,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.info,
                        color: CustomColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Atenção:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta ação não pode ser desfeita. Todos os empréstimos e dados relacionados a este solicitante também serão removidos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: CustomColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showFinalConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Deletar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: CustomColors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CustomColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: CustomColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
