import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/availability_repository.dart';

// Events
abstract class AvailabilityEvent {}

class LoadSlots extends AvailabilityEvent {
  final int? inventoryItemId;
  LoadSlots({this.inventoryItemId});
}

class CreateSlot extends AvailabilityEvent {
  final Map<String, dynamic> data;
  CreateSlot(this.data);
}

class UpdateSlot extends AvailabilityEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateSlot(this.id, this.data);
}

class DeleteSlot extends AvailabilityEvent {
  final int id;
  final int? inventoryItemId;
  DeleteSlot(this.id, {this.inventoryItemId});
}

// States
abstract class AvailabilityState {}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final List<AvailabilitySlot> slots;
  AvailabilityLoaded(this.slots);
}

class AvailabilityActionSuccess extends AvailabilityState {
  final String message;
  AvailabilityActionSuccess(this.message);
}

class AvailabilityError extends AvailabilityState {
  final String message;
  AvailabilityError(this.message);
}

// Bloc
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final AvailabilityRepository _repository;

  AvailabilityBloc(this._repository) : super(AvailabilityInitial()) {
    on<LoadSlots>(_onLoadSlots);
    on<CreateSlot>(_onCreateSlot);
    on<UpdateSlot>(_onUpdateSlot);
    on<DeleteSlot>(_onDeleteSlot);
  }

  Future<void> _onLoadSlots(
    LoadSlots event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading());
    try {
      final slots = await _repository.getSlots(inventoryItemId: event.inventoryItemId);
      emit(AvailabilityLoaded(slots));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> _onCreateSlot(
    CreateSlot event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      await _repository.createSlot(event.data);
      emit(AvailabilityActionSuccess('Slot kreiran'));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> _onUpdateSlot(
    UpdateSlot event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      await _repository.updateSlot(event.id, event.data);
      emit(AvailabilityActionSuccess('Slot azuriran'));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> _onDeleteSlot(
    DeleteSlot event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      await _repository.deleteSlot(event.id);
      emit(AvailabilityActionSuccess('Slot obrisan'));
      add(LoadSlots(inventoryItemId: event.inventoryItemId));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }
}
