import 'package:app/app/ptd/loans/widgets/action_menu_loan.dart';
import 'package:app/core/api/api.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/utils.dart' as utils;
import 'package:app/core/widgets/accordion_section.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/info_row.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoanPage extends StatefulWidget {
  final String loanId;

  const LoanPage({super.key, required this.loanId});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final loansController = Get.find<LoansController>();
  LoanListItem? _currentLoan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLoanDetails();
    });
  }

  Future<void> _loadLoanDetails() async {
    final res = await loansController.loadLoanById(widget.loanId);
    res.fold(
      (result) {
        setState(() {
          _currentLoan = result;
        });
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar empréstimo: $error'),
            backgroundColor: CustomColors.error,
          ),
        );
      },
    );
  }

  void _showActionsMenu(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuLoan(
          onEditPressed: () {
            context.go(RoutePaths.ptd.editLoan(widget.loanId));
          },
          onFinishPressed: () {
            context.go(RoutePaths.ptd.loanFinalize(widget.loanId));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Detalhes do Empréstimo',
        path: RoutePaths.ptd.loans,
      ),
      backgroundColor: CustomColors.background,
      body: Container(
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Imagem principal
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: false,
              automaticallyImplyLeading: false,
              backgroundColor: CustomColors.primary.withOpacity(0.03),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _currentLoan != null
                    ? _buildImageSection(_currentLoan!.imageUrl ?? '')
                    : Container(
                        color: CustomColors.primary.withOpacity(0.05),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CustomColors.primary,
                            ),
                          ),
                        ),
                      ),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            // Barrinha decorativa no início do corpo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 2),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CustomColors.textSecondary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            // Header do empréstimo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: _buildHeader(),
              ),
            ),
            // Conteúdo principal como SliverList com padding lateral
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AccordionSection(
                    title: 'Pessoas Envolvidas',
                    icon: LucideIcons.users,
                    children: [
                      InfoRow(
                        icon: LucideIcons.userCheck,
                        label: 'Responsável',
                        value: _currentLoan?.responsible ?? '',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: LucideIcons.user,
                        label: 'Solicitante',
                        value: _currentLoan?.applicant ?? '',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: LucideIcons.heart,
                        label: 'Beneficiado',
                        value: _currentLoan?.applicant ?? '',
                      ),
                    ],
                  ),
                  AccordionSection(
                    title: 'Cronograma',
                    icon: LucideIcons.calendar,
                    children: [
                      InfoRow(
                        icon: LucideIcons.calendarDays,
                        label: 'Data do Empréstimo',
                        value: utils.DateUtils.formatDateBR(
                          _currentLoan?.createdAt ?? DateTime.now(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: LucideIcons.calendarClock,
                        label: 'Data de Devolução',
                        value: utils.DateUtils.formatDateBR(
                          _currentLoan?.returnDate ?? DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                  AccordionSection(
                    title: 'Detalhes',
                    icon: LucideIcons.fileText,
                    children: [
                      InfoRow(
                        icon: LucideIcons.messageSquare,
                        label: 'Motivo',
                        value:
                            _currentLoan?.reason ?? 'Nenhum motivo informado',
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
            // Espaço extra para scroll bounce
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: Colors.white),
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
                      'Código: ${_currentLoan?.formattedSerialCode ?? 'N/A'}',
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
                  (_currentLoan != null && _currentLoan!.isActive)
                      ? 'Ativo'
                      : 'Finalizado',
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
            // Use widget.loanId for data that doesn't change
            'ID: #${widget.loanId}',
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
    return (_currentLoan != null && _currentLoan!.isActive)
        ? CustomColors.success
        : CustomColors.error;
  }

  // ...existing code...

  Widget _buildImageSection(String imageUrl) {
    final isAsset = !imageUrl.startsWith('http');
    return isAsset
        ? Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: 220,
          )
        : Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: 220,
            cacheWidth: 412,
            cacheHeight: 220,
          );
  }
}
