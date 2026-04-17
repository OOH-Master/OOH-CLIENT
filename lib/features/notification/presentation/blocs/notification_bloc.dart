import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../data/dto/notification_dto.dart';
import '../../data/repository/notification_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

class MarkRead extends NotificationEvent {
  final int id;
  const MarkRead(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllRead extends NotificationEvent {
  const MarkAllRead();
}

class NewNotificationPush extends NotificationEvent {
  final Map<String, dynamic> payload;
  const NewNotificationPush(this.payload);
  @override
  List<Object?> get props => [payload];
}

// States
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationDto> notifications;
  final int unreadCount;
  NotificationsLoaded(this.notifications, this.unreadCount);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkRead>(_onMarkRead);
    on<MarkAllRead>(_onMarkAllRead);
    on<NewNotificationPush>(_onNewNotificationPush);
  }

  int _lastUnreadCount = 0;

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await _repository.getNotifications();
    switch (result) {
      case Success(data: final notifications):
        _lastUnreadCount = notifications.where((n) => !n.read).length;
        emit(NotificationsLoaded(notifications, _lastUnreadCount));
      case Error(failure: final failure):
        emit(NotificationError(failure.message));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getUnreadCount();
    switch (result) {
      case Success(data: final count):
        _lastUnreadCount = count;
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          emit(NotificationsLoaded(currentState.notifications, count));
        } else {
          emit(NotificationsLoaded([], count));
        }
      case Error():
        // Silently ignore - unread count is supplementary
        break;
    }
  }

  Future<void> _onMarkRead(
    MarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markRead(event.id);
    switch (result) {
      case Success():
        add(LoadNotifications());
      case Error(failure: final failure):
        emit(NotificationError(failure.message));
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAllRead();
    switch (result) {
      case Success():
        add(LoadNotifications());
      case Error(failure: final failure):
        emit(NotificationError(failure.message));
    }
  }

  Future<void> _onNewNotificationPush(
    NewNotificationPush event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    final newCount = currentState is NotificationsLoaded
        ? currentState.unreadCount + 1
        : _lastUnreadCount + 1;
    _lastUnreadCount = newCount;

    if (currentState is NotificationsLoaded) {
      try {
        final newNotification = NotificationDto.fromJson(event.payload);
        emit(NotificationsLoaded(
          [newNotification, ...currentState.notifications],
          newCount,
        ));
      } catch (_) {
        emit(NotificationsLoaded(currentState.notifications, newCount));
      }
    } else {
      emit(NotificationsLoaded([], newCount));
    }
  }
}
