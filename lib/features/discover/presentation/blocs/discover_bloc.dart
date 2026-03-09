import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';
import '../../data/repository/discover_repository.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/ooh_unit.dart';

// Events
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class LoadCountries extends DiscoverEvent {}

class SelectCountry extends DiscoverEvent {
  final Country? country;
  const SelectCountry(this.country);

  @override
  List<Object?> get props => [country];
}

class LoadCities extends DiscoverEvent {
  final int? countryId;
  const LoadCities({this.countryId});

  @override
  List<Object?> get props => [countryId];
}

class LoadInventoryUnits extends DiscoverEvent {
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

  const LoadInventoryUnits({
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

  @override
  List<Object?> get props => [
        countryId,
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
  final List<Country> countries;
  final Country? selectedCountry;
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
    this.countries = const [],
    this.selectedCountry,
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
        countries,
        selectedCountry,
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
    List<Country>? countries,
    Country? selectedCountry,
    bool clearSelectedCountry = false,
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
      countries: countries ?? this.countries,
      selectedCountry: clearSelectedCountry ? null : (selectedCountry ?? this.selectedCountry),
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
    on<LoadCountries>(_onLoadCountries);
    on<SelectCountry>(_onSelectCountry);
    on<LoadCities>(_onLoadCities);
    on<LoadInventoryUnits>(_onLoadInventoryUnits);
    on<SelectCity>(_onSelectCity);
    on<LoadDictionaries>(_onLoadDictionaries);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetFilters>(_onResetFilters);
    on<RefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());

    final result = await _repository.getCountries();

    switch (result) {
      case Success(data: final countries):
        // Default to Serbia
        Country? defaultCountry;
        try {
          defaultCountry = countries.firstWhere(
            (c) => c.code?.toUpperCase() == 'RS' ||
                c.name.toLowerCase().contains('serb'),
          );
        } catch (_) {
          if (countries.isNotEmpty) defaultCountry = countries.first;
        }

        emit(DiscoverLoaded(
          countries: countries,
          selectedCountry: defaultCountry,
          cities: const [],
          units: const [],
        ));

        // Load cities for default country
        add(LoadCities(countryId: defaultCountry?.id));

      case Error(failure: final failure):
        emit(DiscoverFailure('Failed to load countries: ${failure.message}'));
    }
  }

  Future<void> _onSelectCountry(
    SelectCountry event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;

    emit(currentState.copyWith(
      selectedCountry: event.country,
      clearSelectedCountry: event.country == null,
      clearSelectedCity: true,
      cities: const [],
      units: const [],
      isLoadingUnits: true,
      activeFilters: const InventoryFilterParams(),
    ));

    // Load cities for the selected country (null = all countries)
    add(LoadCities(countryId: event.country?.id));
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DiscoverLoaded) {
      emit(DiscoverLoading());
    }

    final result = await _repository.getCities(countryId: event.countryId);

    switch (result) {
      case Success(data: final cities):
        final prevState = state is DiscoverLoaded ? state as DiscoverLoaded : null;

        if (cities.isEmpty) {
          emit(DiscoverLoaded(
            countries: prevState?.countries ?? const [],
            selectedCountry: prevState?.selectedCountry,
            cities: const [],
            units: const [],
            unitTypes: prevState?.unitTypes ?? const [],
            mediaFormats: prevState?.mediaFormats ?? const [],
            venueTypes: prevState?.venueTypes ?? const [],
          ));
          // When "all countries" with no city selected, load all units
          if (event.countryId == null) {
            add(const LoadInventoryUnits());
          }
          return;
        }

        // Find Belgrade or first city as default
        City? defaultCity;
        try {
          defaultCity = cities.firstWhere(
            (city) => city.name.toLowerCase() == 'belgrade' ||
                city.name.toLowerCase() == 'beograd',
          );
        } catch (_) {
          defaultCity = cities.first;
        }

        emit(DiscoverLoaded(
          countries: prevState?.countries ?? const [],
          selectedCountry: prevState?.selectedCountry,
          cities: cities,
          units: const [],
          selectedCity: defaultCity,
          unitTypes: prevState?.unitTypes ?? const [],
          mediaFormats: prevState?.mediaFormats ?? const [],
          venueTypes: prevState?.venueTypes ?? const [],
        ));

        // Load units for default city
        if (defaultCity != null) {
          add(LoadInventoryUnits(cityId: defaultCity.id));
        }

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
      countryId: event.countryId,
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
          emit(DiscoverLoaded(cities: const [], units: units));
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
      // "All cities" — load all units for the selected country (or all units)
      add(LoadInventoryUnits(countryId: currentState.selectedCountry?.id));
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
      countryId: currentState.selectedCountry?.id,
    );

    emit(currentState.copyWith(
      activeFilters: mergedFilters,
      isLoadingUnits: true,
    ));

    add(LoadInventoryUnits(
      countryId: currentState.selectedCountry?.id,
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

    add(LoadInventoryUnits(
      countryId: currentState.selectedCountry?.id,
      cityId: currentState.selectedCity?.id,
    ));
  }

  Future<void> _onRefreshRequested(
    RefreshRequested event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is DiscoverLoaded && currentState.selectedCity != null) {
      add(LoadInventoryUnits(cityId: currentState.selectedCity!.id));
    } else {
      add(LoadCountries());
    }
  }
}
