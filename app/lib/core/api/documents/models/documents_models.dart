import 'dart:io';
import 'dart:typed_data';

class Document {
  final String id;
  final String originalFileName;
  final String applicantId;
  final String? dependentId;
  final String storageUrl;
  final String createdAt;

  Document({
    required this.id,
    required this.originalFileName,
    required this.applicantId,
    this.dependentId,
    required this.storageUrl,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      originalFileName: json['originalFileName'] as String,
      applicantId: json['applicantId'] as String,
      dependentId: json['dependentId'] as String?,
      storageUrl: json['storageUrl'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalFileName': originalFileName,
      'applicantId': applicantId,
      'dependentId': dependentId,
      'storageUrl': storageUrl,
      'createdAt': createdAt,
    };
  }
}

/// Request para criar um novo documento
class CreateDocumentRequest {
  final String applicantId;
  final String? dependentId;
  final File? documentFile;
  final Uint8List? documentBytes;
  final String? documentFileName;

  const CreateDocumentRequest({
    required this.applicantId,
    this.dependentId,
    this.documentFile,
    this.documentBytes,
    this.documentFileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      if (dependentId != null) 'dependentId': dependentId,
    };
  }

  @override
  String toString() {
    return 'CreateDocumentRequest(applicantId: $applicantId, dependentId: $dependentId)';
  }
}

/// Request para atualizar um documento existente
class UpdateDocumentRequest {
  final String? dependentId;
  final File? documentFile;
  final Uint8List? documentBytes;
  final String? documentFileName;

  const UpdateDocumentRequest({
    this.dependentId,
    this.documentFile,
    this.documentBytes,
    this.documentFileName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (dependentId != null) data['dependentId'] = dependentId;
    return data;
  }

  bool get hasFile => documentFile != null || documentBytes != null;

  @override
  String toString() {
    return 'UpdateDocumentRequest(dependentId: $dependentId)';
  }
}

class DocumentResponse {
  final bool success;
  final Document? data;
  final String? message;

  DocumentResponse({required this.success, this.data, this.message});

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      success: json['success'] ?? true,
      data: json['data'] != null ? Document.fromJson(json['data']) : null,
      message: json['message'] as String?,
    );
  }
}

class DocumentListResponse {
  final bool success;
  final List<Document> data;
  final String? message;

  DocumentListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) {
    return DocumentListResponse(
      success: json['success'] ?? true,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
