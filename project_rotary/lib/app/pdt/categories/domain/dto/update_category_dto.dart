class UpdateCategoryDTO {
  final String? title;
  final int? maintenanceQtd;
  final int? availableQtd;
  final int? borrowedQtd;

  const UpdateCategoryDTO({
    this.title,
    this.maintenanceQtd,
    this.availableQtd,
    this.borrowedQtd,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (title != null) json['title'] = title;
    if (maintenanceQtd != null) json['maintenanceQtd'] = maintenanceQtd;
    if (availableQtd != null) json['availableQtd'] = availableQtd;
    if (borrowedQtd != null) json['borrowedQtd'] = borrowedQtd;

    return json;
  }

  bool get isEmpty =>
      title == null &&
      maintenanceQtd == null &&
      availableQtd == null &&
      borrowedQtd == null;

  @override
  String toString() {
    return 'UpdateCategoryDTO(${toJson()})';
  }
}
