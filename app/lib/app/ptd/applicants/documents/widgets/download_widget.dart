import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadUtils {
  /// Solicita permissões de armazenamento no início do app (similar ao ensureNotificationPermission)
  static Future<void> ensureStoragePermission() async {
    if (!Platform.isAndroid) return;

    try {
      // Para Android, focar apenas em permissões de armazenamento
      // Verificar se já temos permissão
      var storageStatus = await Permission.storage.status;
      var manageExternalStorageStatus =
          await Permission.manageExternalStorage.status;

      // Android 11+ (API 30+) - Verificar se precisa de Manage External Storage
      if (manageExternalStorageStatus.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      // Fallback para permissão de storage tradicional
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }

      // NÃO solicitar permissões de photos/videos para evitar abrir seletor de mídia
    } catch (e) {
      debugPrint('Erro ao solicitar permissões iniciais: $e');
    }
  }

  static Future<void> downloadFile({
    required BuildContext context,
    required String url,
    required String originalFileName,
  }) async {
    try {
      if (kIsWeb) {
        // Para web, apenas abrir a URL em uma nova aba
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Baixando: $originalFileName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw 'Não foi possível abrir o link';
        }
      } else {
        // Para mobile/desktop
        await _downloadForMobile(context, url, originalFileName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  static Future<void> _downloadForMobile(
    BuildContext context,
    String url,
    String originalFileName,
  ) async {
    try {
      // Fazer download do arquivo primeiro
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw 'Erro no servidor: ${response.statusCode}';
      }

      final bytes = response.bodyBytes;

      if (Platform.isAndroid) {
        // Para Android, tentar múltiplas abordagens
        String? savedPath = await _saveFileAndroid(bytes, originalFileName);
        if (savedPath == null) {
          throw 'Não foi possível salvar o arquivo. Verifique as permissões do app.';
        }

        if (context.mounted) {
          String message;
          if (savedPath.contains('Download')) {
            message = 'Arquivo salvo na pasta Downloads: $originalFileName';
          } else if (savedPath.contains('cache')) {
            message =
                'Arquivo salvo no cache da aplicação: $originalFileName\n(Acesse via gerenciador de arquivos)';
          } else {
            message = 'Arquivo salvo: $originalFileName';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (Platform.isIOS) {
        // Para iOS, usar diretório de documentos da aplicação
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/$originalFileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Arquivo salvo: $originalFileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Para desktop, usar diretório atual
        final file = File(originalFileName);
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Arquivo salvo: $originalFileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Tenta salvar o arquivo no Android usando diferentes estratégias
  /// Retorna o caminho onde o arquivo foi salvo, ou null se falhou
  static Future<String?> _saveFileAndroid(
    List<int> bytes,
    String fileName,
  ) async {
    // Estratégia 1: Tentar salvar na pasta Downloads usando permissões
    try {
      bool hasPermission = await _requestStoragePermission();
      if (hasPermission) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          final file = File('${downloadDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          final savedPath = '${downloadDir.path}/$fileName';
          debugPrint('Arquivo salvo em Downloads: $savedPath');
          return savedPath;
        }
      }
    } catch (e) {
      debugPrint('Erro na estratégia 1: $e');
    }

    // Estratégia 1.5: Tentar pasta Downloads alternativa
    try {
      final downloadDir = Directory('/sdcard/Download');
      if (await downloadDir.exists()) {
        final file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        final savedPath = '${downloadDir.path}/$fileName';
        debugPrint('Arquivo salvo em Downloads alternativo: $savedPath');
        return savedPath;
      }
    } catch (e) {
      debugPrint('Erro na estratégia 1.5: $e');
    }

    // Estratégia 2: Tentar salvar no diretório de cache da aplicação (não requer permissões)
    try {
      final cacheDir = Directory('/data/data/com.example.app/cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      final savedPath = '${cacheDir.path}/$fileName';
      debugPrint('Arquivo salvo no cache: $savedPath');
      return savedPath;
    } catch (e) {
      debugPrint('Erro na estratégia 2: $e');
    }

    // Estratégia 3: Usar diretório temporário do sistema
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      final savedPath = '${tempDir.path}/$fileName';
      debugPrint('Arquivo salvo no temp: $savedPath');
      return savedPath;
    } catch (e) {
      debugPrint('Erro na estratégia 3: $e');
    }

    // Estratégia 4: Tentar pasta externa genérica
    try {
      final externalDir = Directory('/storage/emulated/0');
      if (await externalDir.exists()) {
        final file = File('${externalDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        final savedPath = '${externalDir.path}/$fileName';
        debugPrint('Arquivo salvo em storage externo: $savedPath');
        return savedPath;
      }
    } catch (e) {
      debugPrint('Erro na estratégia 4: $e');
    }

    return null;
  }

  /// Solicita permissões de armazenamento considerando diferentes versões do Android
  static Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Para Android 13+ (API 33+), precisamos de permissões específicas de mídia
      // Para versões anteriores, usamos a permissão de storage

      // Verificar se já temos permissão
      var storageStatus = await Permission.storage.status;
      var manageExternalStorageStatus =
          await Permission.manageExternalStorage.status;

      // Android 11+ (API 30+) - Verificar se precisa de Manage External Storage
      if (manageExternalStorageStatus.isDenied) {
        manageExternalStorageStatus = await Permission.manageExternalStorage
            .request();
        if (manageExternalStorageStatus.isGranted) {
          return true;
        }
      } else if (manageExternalStorageStatus.isGranted) {
        return true;
      }

      // Fallback para permissão de storage tradicional
      if (storageStatus.isDenied) {
        storageStatus = await Permission.storage.request();
      }

      // Se ainda não temos permissão, retornar o status atual
      // NÃO solicitar permissões de photos/videos para evitar abrir seletor de mídia
      return storageStatus.isGranted || manageExternalStorageStatus.isGranted;
    } catch (e) {
      debugPrint('Erro ao solicitar permissões: $e');
      return false;
    }
  }

  static void showDownloadConfirmation({
    required BuildContext context,
    required String url,
    required String originalFileName,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deseja baixar este arquivo?'),
            const SizedBox(height: 8),
            Text(
              'Arquivo: $originalFileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (Platform.isAndroid)
              const Text(
                'Nota: Se não conseguir salvar na pasta Downloads, o arquivo será salvo no cache da aplicação.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              downloadFile(
                context: context,
                url: url,
                originalFileName: originalFileName,
              );
            },
            child: const Text('Baixar'),
          ),
          if (Platform.isAndroid)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showPermissionHelp(context);
              },
              child: const Text('Ajuda'),
            ),
        ],
      ),
    );
  }

  /// Mostra ajuda sobre permissões
  static void _showPermissionHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Configurar Permissões'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para salvar arquivos na pasta Downloads:'),
            SizedBox(height: 8),
            Text('1. Vá para Configurações do dispositivo'),
            Text('2. Encontre este aplicativo'),
            Text('3. Toque em "Permissões"'),
            Text('4. Ative "Armazenamento" ou "Arquivos e mídia"'),
            SizedBox(height: 8),
            Text('Depois, tente baixar novamente.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings(); // Abre as configurações do app
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
}

class DownloadWidget extends StatefulWidget {
  final String url;
  final String originalFileName;
  final VoidCallback? onDownloadStart;
  final VoidCallback? onDownloadComplete;
  final Function(String)? onDownloadError;

  const DownloadWidget({
    super.key,
    required this.url,
    required this.originalFileName,
    this.onDownloadStart,
    this.onDownloadComplete,
    this.onDownloadError,
  });

  @override
  State<DownloadWidget> createState() => _DownloadWidgetState();
}

class _DownloadWidgetState extends State<DownloadWidget> {
  bool _isDownloading = false;

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
    });

    widget.onDownloadStart?.call();

    try {
      await DownloadUtils.downloadFile(
        context: context,
        url: widget.url,
        originalFileName: widget.originalFileName,
      );
      widget.onDownloadComplete?.call();
    } catch (e) {
      widget.onDownloadError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showDownloadConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deseja baixar este arquivo?'),
            const SizedBox(height: 8),
            Text(
              'Arquivo: ${widget.originalFileName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _downloadFile();
            },
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isDownloading ? null : _showDownloadConfirmation,
      icon: _isDownloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(LucideIcons.download),
      tooltip: 'Baixar ${widget.originalFileName}',
    );
  }
}
