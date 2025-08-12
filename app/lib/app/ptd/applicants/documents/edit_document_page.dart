import 'dart:io';
import 'dart:typed_data';

import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/api/documents/controllers/documents_controller.dart';
import 'package:app/core/api/documents/models/documents_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/document_uploader.dart';
import 'package:app/core/widgets/select_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class EditDocumentPage extends StatefulWidget {
  final String applicantId;
  final String documentId;

  const EditDocumentPage({
    super.key,
    required this.applicantId,
    required this.documentId,
  });

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDependentId;
  File? _selectedFile;
  Uint8List? _webBytes;
  Document? document;

  final _docController = Get.find<DocumentsController>();
  final _applicantsController = Get.find<ApplicantsController>();
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDocument();
    });
  }

  void loadDocument() async {
    final result = await _docController.loadDocument(
      widget.documentId,
      widget.applicantId,
    );
    result.fold(
      (doc) {
        setState(() {
          document = doc;
          _fileNameController.text = doc.originalFileName.split('.').first;
          _selectedDependentId = doc.dependentId;
          _selectedFile = null; // Reset selected file
          _webBytes = null; // Reset web bytes
          _docController.error = null; // Clear any previous error
        });
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar documento: $error')),
        );
      },
    );
  }

  List<Map<String, String>> get _dependents {
    final applicant = _applicantsController.allApplicants.firstWhereOrNull(
      (a) => a.id == widget.applicantId,
    );
    if (applicant?.dependents == null) return [];
    return applicant!.dependents!
        .map((d) => {'id': d.id, 'name': d.name ?? d.id})
        .toList();
  }

  void _onFileSelected(File? file, Uint8List? bytes) {
    setState(() {
      _selectedFile = file;
      _webBytes = bytes;
      _docController.error = null;
    });
  }

  String? _validateDependent(String? value) {
    return null;
  }

  Future<void> _submit() async {
    if (_selectedFile == null && _webBytes == null) {
      _docController.error = 'Selecione um arquivo.';
      return;
    }

    _docController.error = null;

    final request = UpdateDocumentRequest(
      dependentId: _selectedDependentId,
      documentFile: _selectedFile,
      documentBytes: _webBytes,
      documentFileName: _fileNameController.text.trim().isNotEmpty
          ? '${_fileNameController.text.trim()}.${_selectedFile?.path.split('.').last ?? document?.originalFileName.split('.').last}'
          : _selectedFile?.path.split('/').last ?? document?.originalFileName,
    );

    final result = await _docController.updateDocument(
      widget.applicantId,
      widget.documentId,
      request,
    );
    result.fold(
      (doc) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Documento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(RoutePaths.ptd.applicantDocuments(widget.applicantId));
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar documento: $error')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: "Editar Documento",
        path: RoutePaths.ptd.applicantDocuments(widget.applicantId),
      ),
      backgroundColor: CustomColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Editar Documento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atualize os dados do documento',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Nome do documento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fileNameController,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do documento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CustomColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CustomColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: CustomColors.success,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Arquivo do documento *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DocumentUploader(
                  onFileSelected: _onFileSelected,
                  allowedExtensions: [
                    'pdf',
                    'jpg',
                    'jpeg',
                    'png',
                    'doc',
                    'docx',
                  ],
                  maxFileSizeMB: 10.0,
                  uploadText: 'Selecione um arquivo',
                ),

                const SizedBox(height: 16),

                if (_dependents.isNotEmpty) ...[
                  const Text(
                    'Dependente (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione um dependente apenas se o documento for relacionado a ele.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectField<String>(
                    value: _selectedDependentId,
                    hint: 'Selecione um dependente',
                    icon: Icons.person,
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Nenhum'),
                      ),
                      ..._dependents.map(
                        (d) => DropdownMenuItem<String>(
                          value: d['id'] ?? '',
                          child: Text(d['name'] ?? d['id'] ?? ''),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDependentId = value == '' ? null : value;
                      });
                    },
                    validator: _validateDependent,
                  ),
                ],

                Obx(() {
                  if (_docController.error != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16, top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _docController.error!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => OutlinedButton(
                          onPressed: _docController.isLoading
                              ? null
                              : () => context.go(
                                  RoutePaths.ptd.applicantDocuments(
                                    widget.applicantId,
                                  ),
                                ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: CustomColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: _docController.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _docController.isLoading
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
                                  'Salvar Alterações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.white,
                                  ),
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
        ),
      ),
    );
  }
}
