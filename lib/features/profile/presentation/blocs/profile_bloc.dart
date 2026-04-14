import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../data/repository/profile_repository.dart';

// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> data;
  UpdateProfile(this.data);
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  ChangePassword({required this.currentPassword, required this.newPassword});
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  final Map<String, dynamic> profile;
  ProfileUpdateSuccess(this.message, this.profile);
}

class PasswordChangeSuccess extends ProfileState {
  final String message;
  PasswordChangeSuccess(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _repository.getProfile();
    switch (result) {
      case Success(data: final data):
        emit(ProfileLoaded(data));
      case Error(failure: final failure):
        emit(ProfileError(failure.message));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _repository.updateProfile(event.data);
    switch (result) {
      case Success(data: final data):
        emit(ProfileUpdateSuccess('Profil azuriran', data));
        emit(ProfileLoaded(data));
      case Error(failure: final failure):
        emit(ProfileError(failure.message));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _repository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    switch (result) {
      case Success():
        emit(PasswordChangeSuccess('Lozinka uspesno promenjena'));
      case Error(failure: final failure):
        emit(ProfileError(failure.message));
    }
  }
}
