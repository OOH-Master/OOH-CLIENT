import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';
import '../../data/repository/discover_repository.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/ooh_unit.dart';

// View mode enum
enum ViewMode { grid, list, mapOnly }

// Sort option enum
enum SortOption { priceAsc, priceDesc, newest }

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

class ChangeViewMode extends DiscoverEvent {
  final ViewMode viewMode;
  const ChangeViewMode(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

class ChangeSort extends DiscoverEvent {
  final SortOption sortOption;
  const ChangeSort(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class LoadMore extends DiscoverEvent {}

class ToggleUnitSelection extends DiscoverEvent {
  final int unitId;
  const ToggleUnitSelection(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class ClearSelection extends DiscoverEvent {}

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

  // View & sort
  final ViewMode viewMode;
  final SortOption sortOption;

  // Pagination
  final int currentPage;
  final bool hasMore;
  final int pageSize;

  // Multi-select for inquiry
  final List<int> selectedUnitsForInquiry;

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
    this.viewMode = ViewMode.grid,
    this.sortOption = SortOption.newest,
    this.currentPage = 1,
    this.hasMore = false,
    this.pageSize = 20,
    this.selectedUnitsForInquiry = const [],
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
        viewMode,
        sortOption,
        currentPage,
        hasMore,
        selectedUnitsForInquiry,
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
    ViewMode? viewMode,
    SortOption? sortOption,
    int? currentPage,
    bool? hasMore,
    List<int>? selectedUnitsForInquiry,
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
      viewMode: viewMode ?? this.viewMode,
      sortOption: sortOption ?? this.sortOption,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedUnitsForInquiry: selectedUnitsForInquiry ?? this.selectedUnitsForInquiry,
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
    on<ChangeViewMode>(_onChangeViewMode);
    on<ChangeSort>(_onChangeSort);
    on<LoadMore>(_onLoadMore);
    on<ToggleUnitSelection>(_onToggleUnitSelection);
    on<ClearSelection>(_onClearSelection);
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
      selectedUnitsForInquiry: const [],
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
            viewMode: prevState?.viewMode ?? ViewMode.grid,
            sortOption: prevState?.sortOption ?? SortOption.newest,
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
          viewMode: prevState?.viewMode ?? ViewMode.grid,
          sortOption: prevState?.sortOption ?? SortOption.newest,
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
        final loadedState = state is DiscoverLoaded ? state as DiscoverLoaded : null;
        final sortedUnits = _sortUnits(units, loadedState?.sortOption ?? SortOption.newest);
        if (currentState is DiscoverLoaded) {
          emit(currentState.copyWith(
            units: sortedUnits,
            isLoadingUnits: false,
            currentPage: 1,
            hasMore: units.length >= 20,
          ));
        } else {
          emit(DiscoverLoaded(cities: const [], units: sortedUnits));
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
      selectedUnitsForInquiry: const [],
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

  void _onChangeViewMode(
    ChangeViewMode event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;
    emit(currentState.copyWith(viewMode: event.viewMode));
  }

  void _onChangeSort(
    ChangeSort event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;
    final sortedUnits = _sortUnits(currentState.units, event.sortOption);
    emit(currentState.copyWith(
      sortOption: event.sortOption,
      units: sortedUnits,
    ));
  }

  void _onLoadMore(
    LoadMore event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingUnits) return;
    // In a real scenario, this would load the next page from the API.
    // For now, we just increment the page counter.
    emit(currentState.copyWith(
      currentPage: currentState.currentPage + 1,
    ));
  }

  void _onToggleUnitSelection(
    ToggleUnitSelection event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;

    final selected = List<int>.from(currentState.selectedUnitsForInquiry);
    if (selected.contains(event.unitId)) {
      selected.remove(event.unitId);
    } else {
      selected.add(event.unitId);
    }
    emit(currentState.copyWith(selectedUnitsForInquiry: selected));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<DiscoverState> emit,
  ) {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;
    emit(currentState.copyWith(selectedUnitsForInquiry: const []));
  }

  List<OohUnit> _sortUnits(List<OohUnit> units, SortOption sortOption) {
    final sorted = List<OohUnit>.from(units);
    switch (sortOption) {
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.newest:
        // Keep original order (newest first from API)
        break;
    }
    return sorted;
  }
}
