import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../discover/data/dto/dto.dart';
import '../dto/inventory_image_dto.dart';

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

  // === Inventory Images ===

  Future<List<InventoryImageDto>> listImages(int itemId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.inventoryImages(itemId),
    );
    return (response.data ?? [])
        .map((json) => InventoryImageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryImageDto> uploadImage(int itemId, XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      ),
    });
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.inventoryImages(itemId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return InventoryImageDto.fromJson(response.data!);
  }

  Future<void> deleteImage(int imageId) async {
    await _apiClient.delete(ApiConfig.inventoryImageDelete(imageId));
  }
}
