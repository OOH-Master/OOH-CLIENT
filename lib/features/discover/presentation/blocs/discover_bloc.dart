import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/result.dart';
import '../../data/api/inventory_api_service.dart';
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
  final double? minPrice;
  final double? maxPrice;

  const LoadInventoryUnits({
    this.cityId,
    this.unitTypeId,
    this.mediaFormatId,
    this.venueTypeId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [cityId, unitTypeId, mediaFormatId, venueTypeId, minPrice, maxPrice];
}

class SelectCity extends DiscoverEvent {
  final City? city;
  const SelectCity(this.city);
  
  @override
  List<Object?> get props => [city];
}

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

  const DiscoverLoaded({
    required this.cities,
    required this.units,
    this.selectedCity,
    this.isLoadingUnits = false,
  });

  @override
  List<Object?> get props => [cities, units, selectedCity, isLoadingUnits];

  DiscoverLoaded copyWith({
    List<City>? cities,
    List<OohUnit>? units,
    City? selectedCity,
    bool? isLoadingUnits,
    bool clearSelectedCity = false,
  }) {
    return DiscoverLoaded(
      cities: cities ?? this.cities,
      units: units ?? this.units,
      selectedCity: clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      isLoadingUnits: isLoadingUnits ?? this.isLoadingUnits,
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
        // Find Belgrade as default city
        final belgrade = cities.firstWhere(
          (city) => city.name.toLowerCase() == 'belgrade' || city.name.toLowerCase() == 'beograd',
          orElse: () => cities.isNotEmpty ? cities.first : throw Exception('No cities found'),
        );
        
        emit(DiscoverLoaded(
          cities: cities,
          units: [],
          selectedCity: belgrade,
        ));
        
        // Load units for Belgrade
        add(LoadInventoryUnits(cityId: belgrade.id));
        
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
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
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
          emit(DiscoverLoaded(
            cities: [],
            units: units,
          ));
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
    ));
    
    // Load units for selected city
    if (event.city != null) {
      add(LoadInventoryUnits(cityId: event.city!.id));
    } else {
      // Clear units if no city selected
      emit(currentState.copyWith(
        units: [],
        isLoadingUnits: false,
        clearSelectedCity: true,
      ));
    }
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
