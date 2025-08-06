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

class AddDocumentPage extends StatefulWidget {
  final String applicantId;
  const AddDocumentPage({super.key, required this.applicantId});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDependentId;
  File? _selectedFile;
  Uint8List? _webBytes;

  final _docController = Get.find<DocumentsController>();
  final _applicantsController = Get.find<ApplicantsController>();
  final TextEditingController _fileNameController = TextEditingController();

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
      // Limpar erro quando um arquivo é selecionado
      _docController.error = null;
    });
  }

  String? _validateDependent(String? value) {
    return null; // opcional
  }

  Future<void> _submit() async {
    if (_selectedFile == null && _webBytes == null) {
      _docController.error = 'Selecione um arquivo.';
      return;
    }

    // Limpar erro anterior
    _docController.error = null;

    final request = CreateDocumentRequest(
      applicantId: widget.applicantId,
      dependentId: _selectedDependentId,
      documentFile: _selectedFile,
      documentBytes: _webBytes,
      documentFileName: _fileNameController.text.trim().isNotEmpty
          ? '${_fileNameController.text.trim()}.${_selectedFile!.path.split('.').last}'
          : _selectedFile?.path.split('/').last ?? 'documento',
    );

    final result = await _docController.createDocument(request);
    result.fold(
      (doc) {
        Navigator.of(context).pop(doc);
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar documento: $error')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: "Novo Documento",
        path: RoutePaths.ptd.applicantDocuments(widget.applicantId),
      ),
      backgroundColor: const Color(0xFFE8F5E8),
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
                  'Adicionar Documento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para adicionar um novo documento',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Campo Nome do Arquivo
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

                // Exibir erro usando Obx para reagir ao controller
                Obx(() {
                  if (_docController.error != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                  'Salvar Documento',
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
