import 'package:app/core/api/documents/controllers/documents_controller.dart';
import 'package:app/core/api/documents/models/documents_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/input_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'widgets/document_card.dart';
import 'widgets/download_widget.dart';

class DocumentsPage extends StatefulWidget {
  final String applicantId;

  const DocumentsPage({super.key, required this.applicantId});

  @override
  State<DocumentsPage> createState() => DocumentsPageState();
}

class DocumentsPageState extends State<DocumentsPage> {
  final TextEditingController _filterController = TextEditingController();

  List<Document> _allDocuments = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDocuments();
    });
  }

  Future<void> _fetchDocuments() async {
    final docController = Get.find<DocumentsController>();
    final result = await docController.loadDocuments(widget.applicantId);
    result.fold(
      (docs) {
        if (mounted) {
          setState(() {
            _allDocuments = docs;
          });
        }
      },
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar documentos: $error')),
          );
        }
      },
    );
  }

  List<Document> get _filteredDocuments {
    if (_filter.isEmpty) return _allDocuments;
    return _allDocuments
        .where(
          (doc) => doc.originalFileName.toLowerCase().contains(
            _filter.toLowerCase(),
          ),
        )
        .toList();
  }

  void _onFilterChanged(String value) {
    setState(() {
      _filter = value;
    });
    if (_filterController.text != value) {
      _filterController.text = value;
      _filterController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    }
  }

  void _downloadDocument(Document doc) {
    DownloadUtils.showDownloadConfirmation(
      context: context,
      url: doc.storageUrl,
      originalFileName: doc.originalFileName,
    );
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
        onPressed: () {
          context.go(RoutePaths.ptd.addDocument(widget.applicantId));
        },
        child: const Icon(LucideIcons.plus),
      ),
      backgroundColor: CustomColors.background,
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
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredDocuments[index];
                        return DocumentCard(
                          name: doc.originalFileName,
                          createdAt:
                              DateTime.tryParse(doc.createdAt) ??
                              DateTime.now(),
                          isDependentDoc: doc.dependentId != null,
                          onDownload: () => _downloadDocument(doc),
                          onEdit: () {
                            context.go(
                              RoutePaths.ptd.documentEdit(
                                widget.applicantId,
                                doc.id,
                              ),
                            );
                          },
                          onDelete: () {
                            context.go(
                              RoutePaths.ptd.documentDelete(
                                widget.applicantId,
                                doc.id,
                              ),
                            );
                          },
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
