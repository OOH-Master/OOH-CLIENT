import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ooh_unit.dart';
import '../../domain/entities/ooh_filters.dart';
import '../../domain/usecases/get_ooh_units_usecase.dart';
import '../../../../core/utils/result.dart';

// Events
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class DiscoverStarted extends DiscoverEvent {}

class FiltersChanged extends DiscoverEvent {
  final OohFilters filters;
  const FiltersChanged(this.filters);
  @override
  List<Object?> get props => [filters];
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
  final List<OohUnit> units;
  final OohFilters filters;

  const DiscoverLoaded({
    required this.units,
    this.filters = const OohFilters(),
  });

  @override
  List<Object?> get props => [units, filters];
}

class DiscoverFailure extends DiscoverState {
  final String message;
  const DiscoverFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetOohUnitsUseCase _getOohUnitsUseCase;

  DiscoverBloc({required GetOohUnitsUseCase getOohUnitsUseCase})
    : _getOohUnitsUseCase = getOohUnitsUseCase,
      super(DiscoverInitial()) {
    on<DiscoverStarted>(_onStarted);
    on<FiltersChanged>(_onFiltersChanged);
    on<RefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onStarted(
    DiscoverStarted event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    await _loadUnits(emit, const OohFilters());
  }

  Future<void> _onFiltersChanged(
    FiltersChanged event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    await _loadUnits(emit, event.filters);
  }

  Future<void> _onRefreshRequested(
    RefreshRequested event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentFilters = state is DiscoverLoaded
        ? (state as DiscoverLoaded).filters
        : const OohFilters();
    // Keep loading state or just refresh? Usually show loading indicator.
    // If using RefreshIndicator, we might not want to clear the list.
    // But for simplicity, emit loading.
    emit(DiscoverLoading());
    await _loadUnits(emit, currentFilters);
  }

  Future<void> _loadUnits(
    Emitter<DiscoverState> emit,
    OohFilters filters,
  ) async {
    final result = await _getOohUnitsUseCase(filters: filters);
    switch (result) {
      case Success(data: final units):
        emit(DiscoverLoaded(units: units, filters: filters));
      case Error(failure: final failure):
        emit(DiscoverFailure(failure.message));
    }
  }
}
