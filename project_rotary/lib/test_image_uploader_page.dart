import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/image_uploader.dart';

class ImageUploaderTestPage extends StatefulWidget {
  const ImageUploaderTestPage({super.key});

  @override
  State<ImageUploaderTestPage> createState() => _ImageUploaderTestPageState();
}

class _ImageUploaderTestPageState extends State<ImageUploaderTestPage> {
  File? _selectedFile;
  Uint8List? _selectedBytes;
  String? _fileName;

  void _onImageSelected(File? file, Uint8List? bytes) {
    setState(() {
      _selectedFile = file;
      _selectedBytes = bytes;
      _fileName = file?.path.split('/').last ?? 'image.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imagem selecionada: $_fileName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onImageRemoved() {
    setState(() {
      _selectedFile = null;
      _selectedBytes = null;
      _fileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagem removida'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Image Uploader'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Teste do Componente ImageUploader',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              'Selecione uma imagem:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ImageUploader(
              height: 200,
              hint: 'Toque aqui para testar o seletor de imagem',
              onImageSelected: _onImageSelected,
              onImageRemoved: _onImageRemoved,
            ),

            const SizedBox(height: 20),

            if (_selectedFile != null || _selectedBytes != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagem Selecionada:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Nome: $_fileName'),
                      if (!kIsWeb && _selectedFile != null)
                        Text('Tamanho: ${_selectedFile!.lengthSync()} bytes'),
                      if (kIsWeb && _selectedBytes != null)
                        Text('Tamanho: ${_selectedBytes!.length} bytes'),
                      Text('Plataforma: ${kIsWeb ? "Web" : "Mobile"}'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_selectedFile != null || _selectedBytes != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Imagem pronta para upload!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecione uma imagem primeiro'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Simular Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
