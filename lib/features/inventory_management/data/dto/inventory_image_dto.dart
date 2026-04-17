class InventoryImageDto {
  final int id;
  final int inventoryItemId;
  final String fileName;
  final String? originalName;
  final String? contentType;
  final int? fileSize;
  final int? sortOrder;
  final String? imageUrl;

  const InventoryImageDto({
    required this.id,
    required this.inventoryItemId,
    required this.fileName,
    this.originalName,
    this.contentType,
    this.fileSize,
    this.sortOrder,
    this.imageUrl,
  });

  factory InventoryImageDto.fromJson(Map<String, dynamic> json) {
    return InventoryImageDto(
      id: json['id'] as int,
      inventoryItemId: json['inventoryItemId'] as int,
      fileName: json['fileName'] as String,
      originalName: json['originalName'] as String?,
      contentType: json['contentType'] as String?,
      fileSize: json['fileSize'] as int?,
      sortOrder: json['sortOrder'] as int?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
