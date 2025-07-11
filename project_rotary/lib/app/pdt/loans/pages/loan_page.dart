import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/loans/pages/edit_loan_page.dart';
import 'package:project_rotary/app/pdt/loans/pages/finalize_loan_page.dart';
import 'package:project_rotary/app/pdt/loans/widgets/action_menu_loan.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class LoanPage extends StatelessWidget {
  final String loanId;
  final String loanSerialCode;
  final String loanResponsible;
  final String loanApplicant;
  final String loanBeneficiary;
  final String loanDate;
  final String loanReturnDate;
  final String loanStatus;
  final String loanReason;

  const LoanPage({
    super.key,
    required this.loanId,
    required this.loanSerialCode,
    required this.loanResponsible,
    required this.loanApplicant,
    required this.loanBeneficiary,
    required this.loanDate,
    required this.loanReturnDate,
    required this.loanStatus,
    required this.loanReason,
  });

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuLoan(
          onEditPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => EditLoanPage(
                      loanId: loanId,
                      currentReason: loanReason,
                      currentIsActive: loanStatus.toLowerCase() == 'ativo',
                      currentReturnDate: loanReturnDate,
                    ),
              ),
            );
          },
          onFinishPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => FinalizeLoanPage(
                      loanId: loanId,
                      loanSerialCode: loanSerialCode,
                      loanApplicant: loanApplicant,
                      loanDate: loanDate,
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
      appBar: AppBarCustom(title: 'Detalhes do Empréstimo'),
      backgroundColor: CustomColors.primary.withOpacity(0.03),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: 1.2,
                colors: [
                  CustomColors.primary.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // SliverAppBar melhorado
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagem principal
                      Image.asset('assets/images/cr.jpg', fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sheet melhorado
          DraggableScrollableSheet(
            initialChildSize: 0.756,
            minChildSize: 0.756,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: CustomColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle indicator
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CustomColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        children: [
                          // Header com código do empréstimo
                          _buildHeader(),
                          const SizedBox(height: 24),

                          // Seção de Pessoas
                          _buildSectionCard(
                            'Pessoas Envolvidas',
                            LucideIcons.users,
                            [
                              _buildInfoRow(
                                LucideIcons.userCheck,
                                'Responsável',
                                loanResponsible,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.user,
                                'Solicitante',
                                loanApplicant,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.heart,
                                'Beneficiado',
                                loanBeneficiary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Seção de Datas
                          _buildSectionCard(
                            'Cronograma',
                            LucideIcons.calendar,
                            [
                              _buildInfoRow(
                                LucideIcons.calendarDays,
                                'Data do Empréstimo',
                                loanDate,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                LucideIcons.calendarClock,
                                'Data de Devolução',
                                loanReturnDate,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Seção de Detalhes
                          _buildSectionCard('Detalhes', LucideIcons.fileText, [
                            _buildInfoRow(
                              LucideIcons.messageSquare,
                              'Motivo',
                              loanReason,
                            ),
                          ]),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        foregroundColor: CustomColors.white,
        icon: const Icon(LucideIcons.menu),
        label: const Text('Ações'),
        elevation: 4,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.textSecondary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.primary.withOpacity(0.12),
                  CustomColors.primary.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CustomColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CustomColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomColors.primary.withOpacity(0.9), CustomColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empréstimo',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loanSerialCode,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  loanStatus,
                  style: const TextStyle(
                    color: CustomColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: #${loanId}',
            style: TextStyle(
              fontSize: 13,
              color: CustomColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (loanStatus.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'finalizado':
        return Colors.blue;
      case 'atrasado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionCard(
    String title,
    IconData titleIcon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.textSecondary.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: CustomColors.primary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.primary.withOpacity(0.06),
                  CustomColors.primary.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CustomColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(titleIcon, color: CustomColors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
