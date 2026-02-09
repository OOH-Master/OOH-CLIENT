import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../discover/data/dto/dto.dart';
import '../../data/repository/agency_repository.dart';

// Events
abstract class AgencyEvent {}

class LoadBrands extends AgencyEvent {}

class CreateBrand extends AgencyEvent {
  final String name;
  CreateBrand(this.name);
}

// States
abstract class AgencyState {}

class AgencyInitial extends AgencyState {}

class AgencyLoading extends AgencyState {}

class BrandsLoaded extends AgencyState {
  final List<DictionaryRefDto> brands;
  BrandsLoaded(this.brands);
}

class BrandCreateSuccess extends AgencyState {
  final String message;
  BrandCreateSuccess(this.message);
}

class AgencyError extends AgencyState {
  final String message;
  AgencyError(this.message);
}

// Bloc
class AgencyBloc extends Bloc<AgencyEvent, AgencyState> {
  final AgencyRepository _repository;

  AgencyBloc(this._repository) : super(AgencyInitial()) {
    on<LoadBrands>(_onLoadBrands);
    on<CreateBrand>(_onCreateBrand);
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<AgencyState> emit,
  ) async {
    emit(AgencyLoading());
    try {
      final brands = await _repository.getBrands();
      emit(BrandsLoaded(brands));
    } catch (e) {
      emit(AgencyError(e.toString()));
    }
  }

  Future<void> _onCreateBrand(
    CreateBrand event,
    Emitter<AgencyState> emit,
  ) async {
    try {
      await _repository.createBrand(event.name);
      emit(BrandCreateSuccess('Brand created'));
      add(LoadBrands());
    } catch (e) {
      emit(AgencyError(e.toString()));
    }
  }
}
