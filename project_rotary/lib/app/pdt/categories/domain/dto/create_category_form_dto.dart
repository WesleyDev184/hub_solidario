import 'dart:io';
import 'dart:typed_data';

class CreateCategoryFormDTO {
  final String title;
  final String orthopedicBankId;
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? fileName;

  const CreateCategoryFormDTO({
    required this.title,
    required this.orthopedicBankId,
    this.imageFile,
    this.imageBytes,
    this.fileName,
  });

  Map<String, dynamic> toFormData() {
    return {'title': title, 'orthopedicBankId': orthopedicBankId};
  }

  bool get isValid =>
      title.trim().isNotEmpty && orthopedicBankId.trim().isNotEmpty && hasImage;

  bool get hasImage => imageFile != null || imageBytes != null;

  @override
  String toString() {
    return 'CreateCategoryFormDTO(title: $title, orthopedicBankId: $orthopedicBankId, hasImage: $hasImage)';
  }
}
