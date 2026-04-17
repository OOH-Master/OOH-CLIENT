import '../../../discover/data/dto/dto.dart';
import '../api/favorite_api_service.dart';

class FavoriteRepository {
  final FavoriteApiService _api;

  FavoriteRepository(this._api);

  Future<List<InventoryItemDto>> listFavorites() => _api.listFavorites();

  Future<bool> toggleFavorite(int itemId) => _api.toggleFavorite(itemId);
}
