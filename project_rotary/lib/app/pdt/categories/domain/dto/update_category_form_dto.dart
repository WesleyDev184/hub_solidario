import 'dart:io';
import 'dart:typed_data';

class UpdateCategoryFormDTO {
  final String? title;
  final int? maintenanceQtd;
  final int? availableQtd;
  final int? borrowedQtd;
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? fileName;

  const UpdateCategoryFormDTO({
    this.title,
    this.maintenanceQtd,
    this.availableQtd,
    this.borrowedQtd,
    this.imageFile,
    this.imageBytes,
    this.fileName,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {};

    if (title != null) formData['title'] = title;
    if (maintenanceQtd != null)
      formData['maintenanceQtd'] = maintenanceQtd.toString();
    if (availableQtd != null)
      formData['availableQtd'] = availableQtd.toString();
    if (borrowedQtd != null) formData['borrowedQtd'] = borrowedQtd.toString();

    return formData;
  }

  bool get isEmpty =>
      title == null &&
      maintenanceQtd == null &&
      availableQtd == null &&
      borrowedQtd == null &&
      imageFile == null &&
      imageBytes == null;

  bool get hasImage => imageFile != null || imageBytes != null;

  @override
  String toString() {
    return 'UpdateCategoryFormDTO(title: $title, maintenanceQtd: $maintenanceQtd, availableQtd: $availableQtd, borrowedQtd: $borrowedQtd, hasImage: $hasImage)';
  }
}
