import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImageUploader extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File? file, Uint8List? bytes)? onImageSelected;
  final Function()? onImageRemoved;
  final String? hint;
  final bool isRequired;
  final double? height;
  final double? width;

  const ImageUploader({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.onImageRemoved,
    this.hint,
    this.isRequired = false,
    this.height,
    this.width,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _selectedFile;
  Uint8List? _webBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 200,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Se tem imagem selecionada
    if (_selectedFile != null || _webBytes != null) {
      return _buildImagePreview();
    }

    // Se tem URL inicial
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return _buildNetworkImagePreview();
    }

    // Estado vazio
    return _buildEmptyState();
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              image:
                  kIsWeb
                      ? MemoryImage(_webBytes!)
                      : FileImage(_selectedFile!) as ImageProvider,
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildNetworkImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.initialImageUrl!),
              onError:
                  (error, stackTrace) =>
                      const Icon(Icons.error, size: 50, color: Colors.red),
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.image, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                widget.hint ?? 'Toque para selecionar uma imagem',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isRequired ? 'Obrigatório' : 'Opcional',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      widget.isRequired
                          ? Colors.red.shade600
                          : Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.edit,
            onTap: _pickImage,
            backgroundColor: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete,
            onTap: _removeImage,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webBytes = bytes;
            _selectedFile = null;
          });
          widget.onImageSelected?.call(null, bytes);
        } else {
          final file = File(pickedFile.path);
          setState(() {
            _selectedFile = file;
            _webBytes = null;
          });
          widget.onImageSelected?.call(file, null);
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem. Tente novamente.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _webBytes = null;
    });
    widget.onImageRemoved?.call();
  }

  // Métodos públicos para controle externo
  void clearImage() {
    _removeImage();
  }

  bool get hasImage => _selectedFile != null || _webBytes != null;

  File? get selectedFile => _selectedFile;
  Uint8List? get webBytes => _webBytes;
}
