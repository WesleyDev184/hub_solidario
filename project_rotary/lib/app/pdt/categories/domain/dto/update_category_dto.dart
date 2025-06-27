class UpdateCategoryDTO {
  final String? title;
  final int? maintenanceQtd;
  final int? availableQtd;
  final int? borrowedQtd;

  UpdateCategoryDTO({
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
}
