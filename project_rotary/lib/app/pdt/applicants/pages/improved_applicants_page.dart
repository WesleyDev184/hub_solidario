import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/delete_applicant_page.dart';
import 'package:project_rotary/app/pdt/applicants/pages/edit_applicant_page.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';

class ImprovedApplicantsPage extends StatefulWidget {
  const ImprovedApplicantsPage({super.key});

  @override
  State<ImprovedApplicantsPage> createState() => _ImprovedApplicantsPageState();
}

class _ImprovedApplicantsPageState extends State<ImprovedApplicantsPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredApplicants = [];

  // Mock data for applicants
  final List<Map<String, dynamic>> _mockApplicants = [
    {
      'id': '1',
      'name': 'João Silva',
      'cpf': '123.456.789-00',
      'email': 'joao@email.com',
      'phone': '(11) 99999-9999',
      'status': 'Ativo',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '2',
      'name': 'Maria Santos',
      'cpf': '987.654.321-00',
      'email': 'maria@email.com',
      'phone': '(11) 88888-8888',
      'status': 'Ativo',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': '3',
      'name': 'Pedro Costa',
      'cpf': '456.789.123-00',
      'email': 'pedro@email.com',
      'phone': '(11) 77777-7777',
      'status': 'Inativo',
      'createdAt': DateTime.now().subtract(const Duration(days: 60)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterApplicants);
    _filteredApplicants = List.from(_mockApplicants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApplicants);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _filteredApplicants = List.from(_mockApplicants);
    });
  }

  void _filterApplicants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApplicants = List.from(_mockApplicants);
      } else {
        _filteredApplicants =
            _mockApplicants.where((applicant) {
              return applicant['name'].toString().toLowerCase().contains(
                    query,
                  ) ||
                  applicant['cpf'].toString().toLowerCase().contains(query) ||
                  applicant['email'].toString().toLowerCase().contains(query) ||
                  applicant['phone'].toString().toLowerCase().contains(query);
            }).toList();
      }
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
              child: Builder(
                builder: (context) {
                  if (_isLoading && _filteredApplicants.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
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
    final totalApplicants = _mockApplicants.length;
    final beneficiaries =
        _mockApplicants.where((a) => a['status'] == 'Ativo').length;

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
          'Ativos',
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

  Widget _buildApplicantCard(Map<String, dynamic> applicant, int index) {
    final isActive = applicant['status'] == 'Ativo';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: Text(
            applicant['name'].toString().substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          applicant['name'].toString(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: ${applicant['cpf']}'),
            Text('Email: ${applicant['email']}'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                applicant['status'].toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.green : Colors.grey,
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

  void _handleMenuAction(String action, Map<String, dynamic> applicant) {
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

  void _navigateToApplicantDetails(Map<String, dynamic> applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ApplicantPage(
              applicantId: applicant['id'].toString(),
              name: applicant['name'].toString(),
              cpf: applicant['cpf'].toString(),
              phone: applicant['phone'].toString(),
              email: applicant['email'].toString(),
              address: '',
              beneficiaryStatus: applicant['status'] == 'Ativo',
            ),
      ),
    );
  }

  void _navigateToEditApplicant(Map<String, dynamic> applicant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditApplicantPage(
              applicantId: applicant['id'].toString(),
              currentName: applicant['name'].toString(),
              currentCpf: applicant['cpf'].toString(),
              currentEmail: applicant['email'].toString(),
              currentPhoneNumber: applicant['phone'].toString(),
              currentAddress: '',
              currentIsBeneficiary: applicant['status'] == 'Ativo',
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

  void _showDeleteConfirmation(Map<String, dynamic> applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DeleteApplicantPage(
              applicantId: applicant['id'].toString(),
              applicantName: applicant['name'].toString(),
              applicantCpf: applicant['cpf'].toString(),
              applicantEmail: applicant['email'].toString(),
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
