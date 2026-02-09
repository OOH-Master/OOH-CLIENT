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
  final String? environment;
  final String? illumination;
  final double? minPrice;
  final double? maxPrice;
  final String? keyword;

  const InventoryFilterParams({
    this.countryId,
    this.cityId,
    this.unitTypeId,
    this.mediaFormatId,
    this.venueTypeId,
    this.environment,
    this.illumination,
    this.minPrice,
    this.maxPrice,
    this.keyword,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (countryId != null) params['countryId'] = countryId;
    if (cityId != null) params['cityId'] = cityId;
    if (unitTypeId != null) params['unitTypeId'] = unitTypeId;
    if (mediaFormatId != null) params['mediaFormatId'] = mediaFormatId;
    if (venueTypeId != null) params['venueTypeId'] = venueTypeId;
    if (environment != null) params['environment'] = environment;
    if (illumination != null) params['illumination'] = illumination;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword;
    return params;
  }

  /// Count of active filters (excludes cityId/countryId as those are primary selectors)
  int get activeFilterCount {
    int count = 0;
    if (unitTypeId != null) count++;
    if (mediaFormatId != null) count++;
    if (venueTypeId != null) count++;
    if (environment != null) count++;
    if (illumination != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (keyword != null && keyword!.isNotEmpty) count++;
    return count;
  }

  bool get isEmpty =>
      countryId == null &&
      cityId == null &&
      unitTypeId == null &&
      mediaFormatId == null &&
      venueTypeId == null &&
      environment == null &&
      illumination == null &&
      minPrice == null &&
      maxPrice == null &&
      (keyword == null || keyword!.isEmpty);

  InventoryFilterParams copyWith({
    int? countryId,
    int? cityId,
    int? unitTypeId,
    int? mediaFormatId,
    int? venueTypeId,
    String? environment,
    String? illumination,
    double? minPrice,
    double? maxPrice,
    String? keyword,
    bool clearCountryId = false,
    bool clearCityId = false,
    bool clearUnitTypeId = false,
    bool clearMediaFormatId = false,
    bool clearVenueTypeId = false,
    bool clearEnvironment = false,
    bool clearIllumination = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearKeyword = false,
  }) {
    return InventoryFilterParams(
      countryId: clearCountryId ? null : (countryId ?? this.countryId),
      cityId: clearCityId ? null : (cityId ?? this.cityId),
      unitTypeId: clearUnitTypeId ? null : (unitTypeId ?? this.unitTypeId),
      mediaFormatId: clearMediaFormatId ? null : (mediaFormatId ?? this.mediaFormatId),
      venueTypeId: clearVenueTypeId ? null : (venueTypeId ?? this.venueTypeId),
      environment: clearEnvironment ? null : (environment ?? this.environment),
      illumination: clearIllumination ? null : (illumination ?? this.illumination),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
    );
  }
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
