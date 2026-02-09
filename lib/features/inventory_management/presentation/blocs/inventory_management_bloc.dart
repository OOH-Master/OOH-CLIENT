import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../discover/data/dto/dto.dart';
import '../../data/repository/inventory_management_repository.dart';

// Events
abstract class InventoryManagementEvent {}

class LoadMyInventory extends InventoryManagementEvent {}

class CreateInventoryItem extends InventoryManagementEvent {
  final Map<String, dynamic> data;
  CreateInventoryItem(this.data);
}

class UpdateInventoryItem extends InventoryManagementEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateInventoryItem(this.id, this.data);
}

class DeleteInventoryItem extends InventoryManagementEvent {
  final int id;
  DeleteInventoryItem(this.id);
}

// States
abstract class InventoryManagementState {}

class InventoryManagementInitial extends InventoryManagementState {}

class InventoryManagementLoading extends InventoryManagementState {}

class InventoryManagementLoaded extends InventoryManagementState {
  final List<InventoryItemDto> items;
  InventoryManagementLoaded(this.items);
}

class InventoryFormSuccess extends InventoryManagementState {
  final String message;
  InventoryFormSuccess(this.message);
}

class InventoryManagementError extends InventoryManagementState {
  final String message;
  InventoryManagementError(this.message);
}

// Bloc
class InventoryManagementBloc
    extends Bloc<InventoryManagementEvent, InventoryManagementState> {
  final InventoryManagementRepository _repository;

  InventoryManagementBloc(this._repository) : super(InventoryManagementInitial()) {
    on<LoadMyInventory>(_onLoadMyInventory);
    on<CreateInventoryItem>(_onCreateInventory);
    on<UpdateInventoryItem>(_onUpdateInventory);
    on<DeleteInventoryItem>(_onDeleteInventory);
  }

  Future<void> _onLoadMyInventory(
    LoadMyInventory event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      final items = await _repository.getMyInventory();
      emit(InventoryManagementLoaded(items));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onCreateInventory(
    CreateInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      await _repository.createInventory(event.data);
      emit(InventoryFormSuccess('Inventory item created'));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateInventory(
    UpdateInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      await _repository.updateInventory(event.id, event.data);
      emit(InventoryFormSuccess('Inventory item updated'));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteInventory(
    DeleteInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    try {
      await _repository.deleteInventory(event.id);
      emit(InventoryFormSuccess('Inventory item deleted'));
      add(LoadMyInventory());
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }
}
