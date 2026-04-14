import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';

class AvailabilityApiService {
  final ApiClient _apiClient;

  AvailabilityApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getSlots({int? inventoryItemId}) async {
    final queryParams = <String, dynamic>{};
    if (inventoryItemId != null) {
      queryParams['inventoryItemId'] = inventoryItemId;
    }
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.mediaOwnerAvailability,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createSlot(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.mediaOwnerAvailability,
      data: data,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateSlot(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.mediaOwnerAvailability}/$id',
      data: data,
    );
    return response.data ?? {};
  }

  Future<void> deleteSlot(int id) async {
    await _apiClient.delete('${ApiConfig.mediaOwnerAvailability}/$id');
  }

  Future<List<Map<String, dynamic>>> getPublicAvailability(int inventoryItemId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.publicAvailability}/$inventoryItemId',
    );
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
