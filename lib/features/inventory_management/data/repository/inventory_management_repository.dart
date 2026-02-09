import '../../../discover/data/dto/dto.dart';
import '../api/inventory_management_api_service.dart';

class InventoryManagementRepository {
  final InventoryManagementApiService _apiService;

  InventoryManagementRepository(this._apiService);

  Future<List<InventoryItemDto>> getMyInventory() async {
    return _apiService.getMyInventory();
  }

  Future<InventoryItemDto> createInventory(Map<String, dynamic> data) async {
    return _apiService.createInventory(data);
  }

  Future<InventoryItemDto> updateInventory(int id, Map<String, dynamic> data) async {
    return _apiService.updateInventory(id, data);
  }

  Future<void> deleteInventory(int id) async {
    await _apiService.deleteInventory(id);
  }
}
