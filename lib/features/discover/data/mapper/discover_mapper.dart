import '../dto/dto.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/ooh_unit.dart';

/// Maps DTOs from API to domain entities
class DiscoverMapper {
  DiscoverMapper._();

  /// Convert CityDto to City domain entity
  static City cityFromDto(CityDto dto, {int inventoryCount = 0}) {
    return City(
      id: dto.id,
      name: dto.name,
      country: dto.countryName ?? '',
      latitude: dto.latitude ?? 0.0,
      longitude: dto.longitude ?? 0.0,
      inventoryCount: inventoryCount,
    );
  }

  /// Convert list of CityDto to list of City
  static List<City> citiesFromDtoList(List<CityDto> dtos) {
    return dtos.map((dto) => cityFromDto(dto)).toList();
  }

  /// Convert InventoryItemDto to OohUnit domain entity
  static OohUnit unitFromDto(InventoryItemDto dto) {
    return OohUnit(
      id: dto.id.toString(),
      name: dto.siteName ?? dto.vendorInventoryId ?? 'Unit #${dto.id}',
      type: _mapUnitType(dto.unitType?.name),
      address: dto.fullAddress ?? '',
      cityId: dto.city?.id.toString() ?? '',
      cityName: dto.city?.name ?? '',
      latitude: dto.lat ?? 0.0,
      longitude: dto.lng ?? 0.0,
      price: dto.pricePerCycle ?? 0.0,
      imageUrl: dto.assetUrl,
      images: dto.assetUrl != null ? [dto.assetUrl!] : [],
      status: _mapStatus(dto.status),
      description: dto.description,
      specifications: _buildSpecifications(dto),
    );
  }

  /// Convert list of InventoryItemDto to list of OohUnit
  static List<OohUnit> unitsFromDtoList(List<InventoryItemDto> dtos) {
    return dtos.map(unitFromDto).toList();
  }

  static OohType _mapUnitType(String? typeName) {
    if (typeName == null) return OohType.other;
    
    final lower = typeName.toLowerCase();
    if (lower.contains('billboard') || lower.contains('bilbord')) {
      return OohType.billboard;
    }
    if (lower.contains('digital') || lower.contains('led')) {
      return OohType.digital;
    }
    if (lower.contains('subway') || lower.contains('metro')) {
      return OohType.subway;
    }
    if (lower.contains('airport') || lower.contains('aerodrom')) {
      return OohType.airport;
    }
    if (lower.contains('bus') || lower.contains('autobus')) {
      return OohType.bus;
    }
    return OohType.other;
  }

  static OohStatus _mapStatus(String? status) {
    if (status == null) return OohStatus.available;
    
    final lower = status.toLowerCase();
    if (lower.contains('book') || lower.contains('reserv')) {
      return OohStatus.booked;
    }
    if (lower.contains('maint') || lower.contains('odrzav')) {
      return OohStatus.maintenance;
    }
    return OohStatus.available;
  }

  static Map<String, dynamic> _buildSpecifications(InventoryItemDto dto) {
    final specs = <String, dynamic>{};
    
    if (dto.physicalWidth != null && dto.physicalHeight != null) {
      specs['dimensions'] = '${dto.physicalWidth}x${dto.physicalHeight} ${dto.sizeUnit ?? 'm'}';
    }
    if (dto.pixelWidth != null && dto.pixelHeight != null) {
      specs['resolution'] = '${dto.pixelWidth}x${dto.pixelHeight}px';
    }
    if (dto.illumination != null) {
      specs['illumination'] = dto.illumination;
    }
    if (dto.mediaFormat != null) {
      specs['format'] = dto.mediaFormat!.name;
    }
    if (dto.venueType != null) {
      specs['venueType'] = dto.venueType!.name;
    }
    if (dto.impressions != null) {
      specs['impressions'] = dto.impressions;
    }
    if (dto.cycleType != null) {
      specs['cycleType'] = dto.cycleType;
    }
    if (dto.currency != null) {
      specs['currency'] = dto.currency;
    }
    
    return specs;
  }
}
