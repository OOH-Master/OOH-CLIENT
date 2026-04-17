import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../discover/data/dto/dto.dart';

class FavoriteApiService {
  final ApiClient _apiClient;

  FavoriteApiService(this._apiClient);

  Future<List<InventoryItemDto>> listFavorites({int page = 0, int size = 50}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.favorites,
      queryParameters: {'page': page, 'size': size},
    );
    final content = (response.data?['content'] as List<dynamic>?) ?? [];
    return content
        .map((json) => InventoryItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Toggles favorite state. Returns the NEW state (true = favorited).
  Future<bool> toggleFavorite(int itemId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.favoriteToggle(itemId),
    );
    return response.data?['favorited'] as bool? ?? false;
  }
}
