import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';
import '../../data/repository/discover_repository.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/ooh_unit.dart';

// Events
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class LoadCities extends DiscoverEvent {
  final int? countryId;
  const LoadCities({this.countryId});

  @override
  List<Object?> get props => [countryId];
}

class LoadInventoryUnits extends DiscoverEvent {
  final int? cityId;
  final int? unitTypeId;
  final int? mediaFormatId;
  final int? venueTypeId;
  final String? environment;
  final String? illumination;
  final double? minPrice;
  final double? maxPrice;
  final String? keyword;

  const LoadInventoryUnits({
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

  @override
  List<Object?> get props => [
        cityId,
        unitTypeId,
        mediaFormatId,
        venueTypeId,
        environment,
        illumination,
        minPrice,
        maxPrice,
        keyword,
      ];
}

class SelectCity extends DiscoverEvent {
  final City? city;
  const SelectCity(this.city);

  @override
  List<Object?> get props => [city];
}

class LoadDictionaries extends DiscoverEvent {}

class ApplyFilters extends DiscoverEvent {
  final InventoryFilterParams filters;

  const ApplyFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class ResetFilters extends DiscoverEvent {}

class RefreshRequested extends DiscoverEvent {}

// States
abstract class DiscoverState extends Equatable {
  const DiscoverState();
  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<City> cities;
  final List<OohUnit> units;
  final City? selectedCity;
  final bool isLoadingUnits;

  // Dictionary data for filter dropdowns
  final List<DictionaryRefDto> unitTypes;
  final List<DictionaryRefDto> mediaFormats;
  final List<DictionaryRefDto> venueTypes;

  // Active filters
  final InventoryFilterParams activeFilters;

  const DiscoverLoaded({
    required this.cities,
    required this.units,
    this.selectedCity,
    this.isLoadingUnits = false,
    this.unitTypes = const [],
    this.mediaFormats = const [],
    this.venueTypes = const [],
    this.activeFilters = const InventoryFilterParams(),
  });

  int get activeFilterCount => activeFilters.activeFilterCount;

  @override
  List<Object?> get props => [
        cities,
        units,
        selectedCity,
        isLoadingUnits,
        unitTypes,
        mediaFormats,
        venueTypes,
        activeFilters,
      ];

  DiscoverLoaded copyWith({
    List<City>? cities,
    List<OohUnit>? units,
    City? selectedCity,
    bool? isLoadingUnits,
    bool clearSelectedCity = false,
    List<DictionaryRefDto>? unitTypes,
    List<DictionaryRefDto>? mediaFormats,
    List<DictionaryRefDto>? venueTypes,
    InventoryFilterParams? activeFilters,
  }) {
    return DiscoverLoaded(
      cities: cities ?? this.cities,
      units: units ?? this.units,
      selectedCity: clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      isLoadingUnits: isLoadingUnits ?? this.isLoadingUnits,
      unitTypes: unitTypes ?? this.unitTypes,
      mediaFormats: mediaFormats ?? this.mediaFormats,
      venueTypes: venueTypes ?? this.venueTypes,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class DiscoverFailure extends DiscoverState {
  final String message;

  const DiscoverFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final DiscoverRepository _repository;

  DiscoverBloc({required DiscoverRepository repository})
      : _repository = repository,
        super(DiscoverInitial()) {
    on<LoadCities>(_onLoadCities);
    on<LoadInventoryUnits>(_onLoadInventoryUnits);
    on<SelectCity>(_onSelectCity);
    on<LoadDictionaries>(_onLoadDictionaries);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetFilters>(_onResetFilters);
    on<RefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());

    final result = await _repository.getCities(countryId: event.countryId);

    switch (result) {
      case Success(data: final cities):
        if (cities.isEmpty) {
          emit(const DiscoverLoaded(cities: [], units: []));
          return;
        }

        // Find Belgrade as default city (or first available)
        City? defaultCity;
        try {
          defaultCity = cities.firstWhere(
            (city) => city.name.toLowerCase() == 'belgrade' || city.name.toLowerCase() == 'beograd',
          );
        } catch (_) {
          defaultCity = cities.first;
        }

        emit(DiscoverLoaded(
          cities: cities,
          units: [],
          selectedCity: defaultCity,
        ));

        // Load units for default city
        add(LoadInventoryUnits(cityId: defaultCity.id));

      case Error(failure: final failure):
        emit(DiscoverFailure('Failed to load cities: ${failure.message}'));
    }
  }

  Future<void> _onLoadInventoryUnits(
    LoadInventoryUnits event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;

    if (currentState is DiscoverLoaded) {
      emit(currentState.copyWith(isLoadingUnits: true));
    } else {
      emit(DiscoverLoading());
    }

    final filters = InventoryFilterParams(
      cityId: event.cityId,
      unitTypeId: event.unitTypeId,
      mediaFormatId: event.mediaFormatId,
      venueTypeId: event.venueTypeId,
      environment: event.environment,
      illumination: event.illumination,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      keyword: event.keyword,
    );

    final result = await _repository.getUnits(filters: filters);

    switch (result) {
      case Success(data: final units):
        if (currentState is DiscoverLoaded) {
          emit(currentState.copyWith(
            units: units,
            isLoadingUnits: false,
          ));
        } else {
          emit(DiscoverLoaded(cities: [], units: units));
        }
      case Error(failure: final failure):
        emit(DiscoverFailure('Failed to load inventory: ${failure.message}'));
    }
  }

  Future<void> _onSelectCity(
    SelectCity event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;

    emit(currentState.copyWith(
      selectedCity: event.city,
      isLoadingUnits: true,
      clearSelectedCity: event.city == null,
      activeFilters: const InventoryFilterParams(),
    ));

    if (event.city != null) {
      add(LoadInventoryUnits(cityId: event.city!.id));
    } else {
      emit(currentState.copyWith(
        units: [],
        isLoadingUnits: false,
        clearSelectedCity: true,
        activeFilters: const InventoryFilterParams(),
      ));
    }
  }

  Future<void> _onLoadDictionaries(
    LoadDictionaries event,
    Emitter<DiscoverState> emit,
  ) async {
    final results = await Future.wait([
      _repository.getUnitTypes(),
      _repository.getMediaFormats(),
      _repository.getVenueTypes(),
    ]);

    final currentState = state;
    if (currentState is DiscoverLoaded) {
      List<DictionaryRefDto> unitTypes = [];
      List<DictionaryRefDto> mediaFormats = [];
      List<DictionaryRefDto> venueTypes = [];

      if (results[0] is Success<List<DictionaryRefDto>>) {
        unitTypes = (results[0] as Success<List<DictionaryRefDto>>).data;
      }
      if (results[1] is Success<List<DictionaryRefDto>>) {
        mediaFormats = (results[1] as Success<List<DictionaryRefDto>>).data;
      }
      if (results[2] is Success<List<DictionaryRefDto>>) {
        venueTypes = (results[2] as Success<List<DictionaryRefDto>>).data;
      }

      emit(currentState.copyWith(
        unitTypes: unitTypes,
        mediaFormats: mediaFormats,
        venueTypes: venueTypes,
      ));
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;

    final mergedFilters = event.filters.copyWith(
      cityId: currentState.selectedCity?.id,
    );

    emit(currentState.copyWith(
      activeFilters: mergedFilters,
      isLoadingUnits: true,
    ));

    add(LoadInventoryUnits(
      cityId: currentState.selectedCity?.id,
      unitTypeId: mergedFilters.unitTypeId,
      mediaFormatId: mergedFilters.mediaFormatId,
      venueTypeId: mergedFilters.venueTypeId,
      environment: mergedFilters.environment,
      illumination: mergedFilters.illumination,
      minPrice: mergedFilters.minPrice,
      maxPrice: mergedFilters.maxPrice,
      keyword: mergedFilters.keyword,
    ));
  }

  Future<void> _onResetFilters(
    ResetFilters event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;

    emit(currentState.copyWith(
      activeFilters: const InventoryFilterParams(),
      isLoadingUnits: true,
    ));

    add(LoadInventoryUnits(cityId: currentState.selectedCity?.id));
  }

  Future<void> _onRefreshRequested(
    RefreshRequested event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is DiscoverLoaded && currentState.selectedCity != null) {
      add(LoadInventoryUnits(cityId: currentState.selectedCity!.id));
    } else {
      add(const LoadCities());
    }
  }
}
