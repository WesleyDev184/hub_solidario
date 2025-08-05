import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'widgets/document_card.dart';

class DocumentsPage extends StatefulWidget {
  final String applicantId;

  const DocumentsPage({super.key, required this.applicantId});

  @override
  State<DocumentsPage> createState() => DocumentsPageState();
}

class DocumentsPageState extends State<DocumentsPage> {
  final TextEditingController _filterController = TextEditingController();

  final List<_DocumentMock> _allDocuments = [
    _DocumentMock('RG.pdf', DateTime(2025, 8, 1)),
    _DocumentMock('CPF.pdf', DateTime(2025, 7, 28)),
    _DocumentMock('Comprovante de Endereço.pdf', DateTime(2025, 7, 15)),
    _DocumentMock('Certidão de Nascimento.pdf', DateTime(2025, 6, 30)),
    _DocumentMock('Histórico Escolar.pdf', DateTime(2025, 5, 20)),
    _DocumentMock(
      'Autorização dependente.pdf',
      DateTime(2025, 7, 10),
      isDependent: true,
    ),
    _DocumentMock('RG dependente.pdf', DateTime(2025, 6, 5), isDependent: true),
  ];

  String _filter = '';

  List<_DocumentMock> get _filteredDocuments {
    if (_filter.isEmpty) return _allDocuments;
    return _allDocuments
        .where((doc) => doc.name.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
  }

  void _onFilterChanged(String value) {
    setState(() {
      _filter = value;
    });
    // Mantém o texto do controller sincronizado
    if (_filterController.text != value) {
      _filterController.text = value;
      _filterController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Documentos',
        path: RoutePaths.ptd.applicantId(widget.applicantId),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "documents_applicants_list_fab",
        onPressed: () {},
        child: const Icon(LucideIcons.plus),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputField(
              controller: _filterController,
              hint: 'Filtrar por nome',
              icon: Icons.search,
              onChanged: _onFilterChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredDocuments.isEmpty
                  ? const Center(child: Text('Nenhum documento encontrado'))
                  : ListView.builder(
                      itemCount: _filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredDocuments[index];
                        return DocumentCard(
                          name: doc.name,
                          createdAt: doc.createdAt,
                          isDependentDoc: doc.isDependent,
                          onDownload: () {},
                          onEdit: () {},
                          onDelete: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentMock {
  final String name;
  final DateTime createdAt;
  final bool isDependent;
  _DocumentMock(this.name, this.createdAt, {this.isDependent = false});
}
