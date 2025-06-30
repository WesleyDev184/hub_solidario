import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/di/applicant_dependency_factory.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/controller/applicant_controller.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/edit_applicant_page.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class ImprovedApplicantsPage extends StatefulWidget {
  const ImprovedApplicantsPage({super.key});

  @override
  State<ImprovedApplicantsPage> createState() => _ImprovedApplicantsPageState();
}

class _ImprovedApplicantsPageState extends State<ImprovedApplicantsPage> {
  final TextEditingController _searchController = TextEditingController();
  late final ApplicantController _applicantController;

  List<Applicant> _filteredApplicants = [];

  @override
  void initState() {
    super.initState();
    _applicantController = ApplicantDependencyFactory.applicantController;
    _searchController.addListener(_filterApplicants);
    _loadApplicants();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApplicants);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    final result = await _applicantController.getAllApplicants();
    result.fold(
      (applicants) => _filterApplicants(),
      (error) => _showErrorSnackBar('Erro ao carregar solicitantes'),
    );
  }

  void _filterApplicants() {
    final query = _searchController.text;
    setState(() {
      _filteredApplicants = _applicantController.searchApplicants(query);
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: Colors.white,
            onPressed: _loadApplicants,
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Solicitantes"),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Barra de pesquisa
            InputField(
              controller: _searchController,
              hint: "Buscar por nome, CPF, email ou telefone",
              icon: LucideIcons.search,
            ),

            const SizedBox(height: 16),

            // Header com contadores
            _buildHeader(),

            const SizedBox(height: 16),

            // Lista de solicitantes
            Expanded(
              child: ListenableBuilder(
                listenable: _applicantController,
                builder: (context, child) {
                  if (_applicantController.isLoading &&
                      _filteredApplicants.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_applicantController.error != null &&
                      _filteredApplicants.isEmpty) {
                    return _buildErrorWidget();
                  }

                  if (_filteredApplicants.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return RefreshIndicator(
                    onRefresh: _loadApplicants,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredApplicants.length,
                        itemBuilder: (context, index) {
                          final applicant = _filteredApplicants[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildApplicantCard(applicant, index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateApplicant,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: _applicantController,
      builder: (context, child) {
        final totalApplicants = _applicantController.applicants.length;
        final beneficiaries =
            _applicantController.applicants
                .where((a) => a.isBeneficiary)
                .length;

        return Row(
          children: [
            _buildStatCard(
              'Total',
              totalApplicants.toString(),
              LucideIcons.users,
              Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Beneficiários',
              beneficiaries.toString(),
              LucideIcons.heart,
              Colors.green,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Resultados',
              _filteredApplicants.length.toString(),
              LucideIcons.search,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(Applicant applicant, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: applicant.isBeneficiary ? Colors.green : Colors.blue,
          child: Text(
            applicant.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          applicant.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: ${applicant.cpf}'),
            Text('Email: ${applicant.email}'),
            if (applicant.isBeneficiary)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Beneficiário',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _navigateToApplicantDetails(applicant),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(LucideIcons.eye),
                    title: Text('Visualizar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(LucideIcons.pen),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(LucideIcons.trash, color: Colors.red),
                    title: Text('Excluir', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
          onSelected: (value) => _handleMenuAction(value, applicant),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar solicitantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _applicantController.error ?? 'Erro desconhecido',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadApplicants,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.users, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhum solicitante encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Adicione o primeiro solicitante'
                : 'Tente buscar com termos diferentes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isEmpty)
            ElevatedButton.icon(
              onPressed: _navigateToCreateApplicant,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Adicionar solicitante'),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Applicant applicant) {
    switch (action) {
      case 'view':
        _navigateToApplicantDetails(applicant);
        break;
      case 'edit':
        _navigateToEditApplicant(applicant);
        break;
      case 'delete':
        _showDeleteConfirmation(applicant);
        break;
    }
  }

  void _navigateToApplicantDetails(Applicant applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ApplicantPage(
              applicantId: applicant.id,
              name: applicant.name,
              cpf: applicant.cpf,
              phone: applicant.phoneNumber,
              email: applicant.email,
              address: applicant.address ?? '',
              beneficiaryStatus: applicant.isBeneficiary,
            ),
      ),
    );
  }

  void _navigateToEditApplicant(Applicant applicant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditApplicantPage(
              applicantId: applicant.id,
              currentName: applicant.name,
              currentCpf: applicant.cpf,
              currentEmail: applicant.email,
              currentPhoneNumber: applicant.phoneNumber,
              currentAddress: applicant.address,
              currentIsBeneficiary: applicant.isBeneficiary,
            ),
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('Solicitante atualizado com sucesso!');
      _filterApplicants();
    }
  }

  void _navigateToCreateApplicant() {
    // TODO: Implementar página de criação
    _showErrorSnackBar('Página de criação ainda não implementada');
  }

  void _showDeleteConfirmation(Applicant applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DeleteApplicantPage(
              applicantId: applicant.id,
              applicantName: applicant.name,
              applicantCpf: applicant.cpf,
              applicantEmail: applicant.email,
            ),
      ),
    ).then((result) {
      if (result == true) {
        _showSuccessSnackBar('Solicitante excluído com sucesso!');
        _loadApplicants();
      }
    });
  }
}
