import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/repository/analytics_repository.dart';

// Events
abstract class AnalyticsEvent {}

class LoadAdminAnalytics extends AnalyticsEvent {}

class LoadMediaOwnerAnalytics extends AnalyticsEvent {}

class LoadBrandAnalytics extends AnalyticsEvent {}

class LoadAgencyAnalytics extends AnalyticsEvent {}

// States
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final Map<String, dynamic> data;
  AnalyticsLoaded(this.data);
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}

// Bloc
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<LoadAdminAnalytics>(_onLoadAdminAnalytics);
    on<LoadMediaOwnerAnalytics>(_onLoadMediaOwnerAnalytics);
    on<LoadBrandAnalytics>(_onLoadBrandAnalytics);
    on<LoadAgencyAnalytics>(_onLoadAgencyAnalytics);
  }

  Future<void> _onLoadAdminAnalytics(
    LoadAdminAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final overviewResult = await _repository.getAdminOverview();
    switch (overviewResult) {
      case Success(data: final data):
        emit(AnalyticsLoaded(data));
      case Error(failure: final failure):
        // Return empty data instead of error - analytics are supplementary
        emit(AnalyticsLoaded({'error': failure.message}));
    }
  }

  Future<void> _onLoadMediaOwnerAnalytics(
    LoadMediaOwnerAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _repository.getMediaOwnerAnalytics();
    switch (result) {
      case Success(data: final data):
        emit(AnalyticsLoaded(data));
      case Error(failure: final failure):
        emit(AnalyticsLoaded({'error': failure.message}));
    }
  }

  Future<void> _onLoadBrandAnalytics(
    LoadBrandAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _repository.getBrandAnalytics();
    switch (result) {
      case Success(data: final data):
        emit(AnalyticsLoaded(data));
      case Error(failure: final failure):
        emit(AnalyticsLoaded({'error': failure.message}));
    }
  }

  Future<void> _onLoadAgencyAnalytics(
    LoadAgencyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _repository.getAgencyAnalytics();
    switch (result) {
      case Success(data: final data):
        emit(AnalyticsLoaded(data));
      case Error(failure: final failure):
        emit(AnalyticsLoaded({'error': failure.message}));
    }
  }
}
