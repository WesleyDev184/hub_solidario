import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class DocumentUploader extends StatefulWidget {
  final void Function(File? file, Uint8List? bytes) onFileSelected;
  final List<String> allowedExtensions;
  final String? initialFileName;
  final double? maxFileSizeMB;
  final String uploadText;

  const DocumentUploader({
    super.key,
    required this.onFileSelected,
    required this.allowedExtensions,
    this.initialFileName,
    this.maxFileSizeMB = 10.0,
    this.uploadText = 'Toque para selecionar um arquivo',
  });

  @override
  State<DocumentUploader> createState() => _DocumentUploaderState();
}

class _DocumentUploaderState extends State<DocumentUploader> {
  File? _selectedFile;
  Uint8List? _webBytes;
  String? _fileName;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFileName != null) {
      _fileName = widget.initialFileName;
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null) {
        final pickedFile = result.files.single;

        // Verificar tamanho do arquivo
        if (widget.maxFileSizeMB != null &&
            pickedFile.size > (widget.maxFileSizeMB! * 1024 * 1024)) {
          setState(() {
            _error =
                'Arquivo muito grande. Tamanho máximo: ${widget.maxFileSizeMB}MB';
          });
          return;
        }

        setState(() {
          _fileName = pickedFile.name;
          if (kIsWeb) {
            _webBytes = pickedFile.bytes;
            _selectedFile = null;
          } else {
            _selectedFile = File(pickedFile.path!);
            _webBytes = null;
          }
        });

        widget.onFileSelected(_selectedFile, _webBytes);
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao selecionar arquivo: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _webBytes = null;
      _fileName = null;
      _error = null;
    });
    widget.onFileSelected(null, null);
  }

  String _getFileSize() {
    if (_selectedFile != null) {
      final sizeInBytes = _selectedFile!.lengthSync();
      return _formatFileSize(sizeInBytes);
    } else if (_webBytes != null) {
      return _formatFileSize(_webBytes!.length);
    }
    return '';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Icons.upload_file;

    final extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor() {
    if (_fileName == null) return Theme.of(context).primaryColor;

    final extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = _selectedFile != null || _webBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Area
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: _error != null
                  ? Colors.red.shade300
                  : hasFile
                  ? theme.primaryColor.withValues(alpha: 0.5)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: _error != null
                ? Colors.red.shade50
                : hasFile
                ? theme.primaryColor.withValues(alpha: 0.05)
                : Colors.grey.shade50,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              _getFileIcon(),
                              color: _getFileIconColor(),
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _fileName ?? widget.uploadText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasFile
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hasFile
                                  ? theme.primaryColor
                                  : Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasFile) ...[
                            const SizedBox(height: 4),
                            Text(
                              _getFileSize(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasFile && !_isLoading)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _removeFile,
                        tooltip: 'Remover arquivo',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // File Extensions Info
        if (!hasFile && _error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Text(
                  'Formatos aceitos: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                ...widget.allowedExtensions.map(
                  (ext) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ext.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Máx. ${widget.maxFileSizeMB}MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

        // Error Message
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
