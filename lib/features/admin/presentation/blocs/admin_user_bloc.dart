import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/repository/admin_user_repository.dart';

// Events
abstract class AdminUserEvent {}

class LoadUsers extends AdminUserEvent {
  final String? role;
  final bool? enabled;
  final String? search;
  LoadUsers({this.role, this.enabled, this.search});
}

class UpdateUser extends AdminUserEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateUser(this.id, this.data);
}

class DisableUser extends AdminUserEvent {
  final int id;
  DisableUser(this.id);
}

class EnableUser extends AdminUserEvent {
  final int id;
  EnableUser(this.id);
}

// States
abstract class AdminUserState {}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUsersLoaded extends AdminUserState {
  final List<Map<String, dynamic>> users;
  AdminUsersLoaded(this.users);
}

class AdminUserActionSuccess extends AdminUserState {
  final String message;
  AdminUserActionSuccess(this.message);
}

class AdminUserError extends AdminUserState {
  final String message;
  AdminUserError(this.message);
}

// Bloc
class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final AdminUserRepository _repository;
  String? _lastRole;
  bool? _lastEnabled;
  String? _lastSearch;

  AdminUserBloc(this._repository) : super(AdminUserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<UpdateUser>(_onUpdateUser);
    on<DisableUser>(_onDisableUser);
    on<EnableUser>(_onEnableUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(AdminUserLoading());
    _lastRole = event.role;
    _lastEnabled = event.enabled;
    _lastSearch = event.search;
    final result = await _repository.getUsers(
      role: event.role,
      enabled: event.enabled,
      search: event.search,
    );
    switch (result) {
      case Success(data: final users):
        emit(AdminUsersLoaded(users));
      case Error(failure: final failure):
        emit(AdminUserError(failure.message));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<AdminUserState> emit,
  ) async {
    final result = await _repository.updateUser(event.id, event.data);
    switch (result) {
      case Success():
        emit(AdminUserActionSuccess('Korisnik azuriran'));
        add(LoadUsers(role: _lastRole, enabled: _lastEnabled, search: _lastSearch));
      case Error(failure: final failure):
        emit(AdminUserError(failure.message));
    }
  }

  Future<void> _onDisableUser(
    DisableUser event,
    Emitter<AdminUserState> emit,
  ) async {
    final result = await _repository.disableUser(event.id);
    switch (result) {
      case Success():
        emit(AdminUserActionSuccess('Korisnik deaktiviran'));
        add(LoadUsers(role: _lastRole, enabled: _lastEnabled, search: _lastSearch));
      case Error(failure: final failure):
        emit(AdminUserError(failure.message));
    }
  }

  Future<void> _onEnableUser(
    EnableUser event,
    Emitter<AdminUserState> emit,
  ) async {
    final result = await _repository.enableUser(event.id);
    switch (result) {
      case Success():
        emit(AdminUserActionSuccess('Korisnik aktiviran'));
        add(LoadUsers(role: _lastRole, enabled: _lastEnabled, search: _lastSearch));
      case Error(failure: final failure):
        emit(AdminUserError(failure.message));
    }
  }
}
