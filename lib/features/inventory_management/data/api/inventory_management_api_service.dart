import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../discover/data/dto/dto.dart';

class InventoryManagementApiService {
  final ApiClient _apiClient;

  InventoryManagementApiService(this._apiClient);

  Future<List<InventoryItemDto>> getMyInventory() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.ownerInventory);
    return (response.data ?? [])
        .map((json) => InventoryItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryItemDto> createInventory(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.inventory,
      data: data,
    );
    return InventoryItemDto.fromJson(response.data!);
  }

  Future<InventoryItemDto> updateInventory(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.inventory}/$id',
      data: data,
    );
    return InventoryItemDto.fromJson(response.data!);
  }

  Future<void> deleteInventory(int id) async {
    await _apiClient.delete('${ApiConfig.inventory}/$id');
  }
}
