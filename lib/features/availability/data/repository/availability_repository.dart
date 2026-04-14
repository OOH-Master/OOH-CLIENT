import '../api/availability_api_service.dart';

class AvailabilitySlot {
  final int id;
  final int inventoryItemId;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? notes;

  const AvailabilitySlot({
    required this.id,
    required this.inventoryItemId,
    this.startDate,
    this.endDate,
    required this.status,
    this.notes,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'] as int? ?? 0,
      inventoryItemId: json['inventoryItemId'] as int? ?? 0,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String? ?? 'AVAILABLE',
      notes: json['notes'] as String?,
    );
  }
}

class AvailabilityRepository {
  final AvailabilityApiService _apiService;

  AvailabilityRepository(this._apiService);

  Future<List<AvailabilitySlot>> getSlots({int? inventoryItemId}) async {
    final data = await _apiService.getSlots(inventoryItemId: inventoryItemId);
    return data.map((e) => AvailabilitySlot.fromJson(e)).toList();
  }

  Future<void> createSlot(Map<String, dynamic> data) async {
    await _apiService.createSlot(data);
  }

  Future<void> updateSlot(int id, Map<String, dynamic> data) async {
    await _apiService.updateSlot(id, data);
  }

  Future<void> deleteSlot(int id) async {
    await _apiService.deleteSlot(id);
  }

  Future<List<AvailabilitySlot>> getPublicAvailability(int inventoryItemId) async {
    final data = await _apiService.getPublicAvailability(inventoryItemId);
    return data.map((e) => AvailabilitySlot.fromJson(e)).toList();
  }
}
