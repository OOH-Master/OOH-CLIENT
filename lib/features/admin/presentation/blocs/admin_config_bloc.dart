import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../discover/data/dto/dto.dart';
import '../../data/repository/admin_config_repository.dart';

// Events
abstract class AdminConfigEvent {}

class LoadConfigTab extends AdminConfigEvent {
  final String type;
  LoadConfigTab(this.type);
}

class CreateConfigItem extends AdminConfigEvent {
  final String type;
  final String name;
  final int? countryId;
  CreateConfigItem(this.type, this.name, {this.countryId});
}

class UpdateConfigItem extends AdminConfigEvent {
  final String type;
  final int id;
  final String name;
  final int? countryId;
  UpdateConfigItem(this.type, this.id, this.name, {this.countryId});
}

class DeleteConfigItem extends AdminConfigEvent {
  final String type;
  final int id;
  DeleteConfigItem(this.type, this.id);
}

// States
abstract class AdminConfigState {}

class AdminConfigInitial extends AdminConfigState {}

class AdminConfigLoading extends AdminConfigState {}

class AdminConfigLoaded extends AdminConfigState {
  final List<DictionaryRefDto> items;
  final String type;
  AdminConfigLoaded(this.items, this.type);
}

class AdminConfigCreateSuccess extends AdminConfigState {
  final String message;
  final String type;
  AdminConfigCreateSuccess(this.message, this.type);
}

class AdminConfigError extends AdminConfigState {
  final String message;
  AdminConfigError(this.message);
}

// Bloc
class AdminConfigBloc extends Bloc<AdminConfigEvent, AdminConfigState> {
  final AdminConfigRepository _repository;

  AdminConfigBloc(this._repository) : super(AdminConfigInitial()) {
    on<LoadConfigTab>(_onLoadConfigTab);
    on<CreateConfigItem>(_onCreateConfigItem);
    on<UpdateConfigItem>(_onUpdateConfigItem);
    on<DeleteConfigItem>(_onDeleteConfigItem);
  }

  Future<void> _onLoadConfigTab(
    LoadConfigTab event,
    Emitter<AdminConfigState> emit,
  ) async {
    emit(AdminConfigLoading());
    try {
      final items = await _repository.getItems(event.type);
      emit(AdminConfigLoaded(items, event.type));
    } catch (e) {
      emit(AdminConfigError(e.toString()));
    }
  }

  Future<void> _onCreateConfigItem(
    CreateConfigItem event,
    Emitter<AdminConfigState> emit,
  ) async {
    try {
      await _repository.createItem(event.type, event.name,
          countryId: event.countryId);
      emit(AdminConfigCreateSuccess('Item created', event.type));
      add(LoadConfigTab(event.type));
    } catch (e) {
      emit(AdminConfigError(e.toString()));
    }
  }

  Future<void> _onUpdateConfigItem(
    UpdateConfigItem event,
    Emitter<AdminConfigState> emit,
  ) async {
    try {
      await _repository.updateItem(event.type, event.id, event.name,
          countryId: event.countryId);
      emit(AdminConfigCreateSuccess('Item updated', event.type));
      add(LoadConfigTab(event.type));
    } catch (e) {
      emit(AdminConfigError(e.toString()));
    }
  }

  Future<void> _onDeleteConfigItem(
    DeleteConfigItem event,
    Emitter<AdminConfigState> emit,
  ) async {
    try {
      await _repository.deleteItem(event.type, event.id);
      emit(AdminConfigCreateSuccess('Item deleted', event.type));
      add(LoadConfigTab(event.type));
    } catch (e) {
      emit(AdminConfigError(e.toString()));
    }
  }
}
