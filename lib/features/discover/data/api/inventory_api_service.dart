import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/dto.dart';

/// Filter parameters for inventory search
class InventoryFilterParams {
  final int? countryId;
  final int? cityId;
  final int? unitTypeId;
  final int? mediaFormatId;
  final int? venueTypeId;
  final double? minPrice;
  final double? maxPrice;

  const InventoryFilterParams({
    this.countryId,
    this.cityId,
    this.unitTypeId,
    this.mediaFormatId,
    this.venueTypeId,
    this.minPrice,
    this.maxPrice,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (countryId != null) params['countryId'] = countryId;
    if (cityId != null) params['cityId'] = cityId;
    if (unitTypeId != null) params['unitTypeId'] = unitTypeId;
    if (mediaFormatId != null) params['mediaFormatId'] = mediaFormatId;
    if (venueTypeId != null) params['venueTypeId'] = venueTypeId;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    return params;
  }

  bool get isEmpty => countryId == null && 
                       cityId == null && 
                       unitTypeId == null && 
                       mediaFormatId == null && 
                       venueTypeId == null && 
                       minPrice == null && 
                       maxPrice == null;
}

/// API service for public inventory endpoints
class InventoryApiService {
  final ApiClient _apiClient;

  InventoryApiService(this._apiClient);

  /// Get all inventory units with optional filters
  Future<List<InventoryItemDto>> getUnits({InventoryFilterParams? filters}) async {
    final queryParams = filters?.toQueryParams();
    
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.publicUnits,
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
    return (response.data ?? [])
        .map((json) => InventoryItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single inventory unit by ID
  Future<InventoryItemDto> getUnitById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.publicUnits}/$id',
    );
    return InventoryItemDto.fromJson(response.data!);
  }
}
