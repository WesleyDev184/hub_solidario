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
