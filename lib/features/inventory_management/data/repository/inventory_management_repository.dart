import 'package:image_picker/image_picker.dart';

import '../../../discover/data/dto/dto.dart';
import '../api/inventory_management_api_service.dart';
import '../dto/inventory_image_dto.dart';

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

  Future<List<InventoryImageDto>> listImages(int itemId) async {
    return _apiService.listImages(itemId);
  }

  Future<InventoryImageDto> uploadImage(int itemId, XFile file) async {
    return _apiService.uploadImage(itemId, file);
  }

  Future<void> deleteImage(int imageId) async {
    await _apiService.deleteImage(imageId);
  }
}
