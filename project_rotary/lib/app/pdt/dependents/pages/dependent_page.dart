import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/dependents/pages/delete_dependent_page.dart';
import 'package:project_rotary/app/pdt/dependents/pages/edit_dependent_page.dart';
import 'package:project_rotary/app/pdt/dependents/widgets/action_menu_dependent.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/avatar.dart';
import 'package:project_rotary/core/components/info_row.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class DependentPage extends StatefulWidget {
  final String dependentId;
  final String name;
  final String? imageUrl;
  final String cpf;
  final String phone;
  final String email;
  final String? address;
  final String applicantName;
  final String applicantId;
  final String? isDeleted;
  final Function(bool)? onDependentDeleted;

  const DependentPage({
    super.key,
    required this.dependentId,
    required this.name,
    this.imageUrl,
    required this.cpf,
    required this.phone,
    required this.email,
    this.address,
    required this.applicantName,
    required this.applicantId,
    this.isDeleted,
    this.onDependentDeleted,
  });

  @override
  State<DependentPage> createState() => _DependentPageState();
}

class _DependentPageState extends State<DependentPage> {
  late bool _isDeleted;

  @override
  void initState() {
    super.initState();
    _isDeleted = widget.isDeleted == 'true';
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuDependent(
          onEditPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => EditDependentPage(
                      dependentId: widget.dependentId,
                      currentName: widget.name,
                      currentCpf: widget.cpf,
                      currentEmail: widget.email,
                      currentPhoneNumber: widget.phone,
                      currentAddress: widget.address,
                      applicantName: widget.applicantName,
                    ),
              ),
            );
          },
          onDeletePressed: () async {
            final res = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => DeleteDependentPage(
                      dependentId: widget.dependentId,
                      dependentName: widget.name,
                      dependentCpf: widget.cpf,
                      dependentEmail: widget.email,
                      applicantName: widget.applicantName,
                      applicantId: widget.applicantId,
                    ),
              ),
            );

            if (res == true) {
              setState(() {
                _isDeleted = true;
              });

              // Notificar a tela anterior se houver callback
              if (widget.onDependentDeleted != null) {
                widget.onDependentDeleted!(true);
              }

              // Voltar para a tela anterior
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se o dependent foi deletado, exibir mensagem e botão de voltar
    if (_isDeleted) {
      return Scaffold(
        appBar: AppBarCustom(title: widget.name),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.userX, size: 80, color: Colors.red[400]),
                const SizedBox(height: 24),
                Text(
                  'Dependente Removido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'O dependente ${widget.name} foi removido com sucesso.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                    foregroundColor: CustomColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarCustom(title: widget.name),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Avatar(imageUrl: widget.imageUrl, size: 150),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informações
            InfoRow(icon: LucideIcons.idCard, label: widget.cpf),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.phone, label: widget.phone),
            const SizedBox(height: 5),
            InfoRow(icon: LucideIcons.mail, label: widget.email),

            const SizedBox(height: 24),
            const Text(
              'Endereço:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            InfoRow(
              icon: LucideIcons.house,
              label: 'Residência de ${widget.name}',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.address != null && widget.address!.isNotEmpty)
                    ...widget.address!
                        .split(',')
                        .map((section) => Text('${section.trim()},'))
                  else
                    const Text('Endereço não informado'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "dependent_detail_fab",
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: CustomColors.white),
      ),
    );
  }
}
