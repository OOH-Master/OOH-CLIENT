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

  /// `false` kada je poznat samo broj nepročitanih (zvonce), a lista još nije
  /// učitana; stranica tada prikazuje učitavanje umesto praznog stanja.
  final bool listLoaded;

  NotificationsLoaded(this.notifications, this.unreadCount,
      {this.listLoaded = true});
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

  bool get _hasList {
    final s = state;
    return s is NotificationsLoaded && s.listLoaded;
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Kada je lista već prikazana, osvežava se bez ekrana za učitavanje.
    if (!_hasList) emit(NotificationLoading());
    final result = await _repository.getNotifications();
    switch (result) {
      case Success(data: final notifications):
        _lastUnreadCount = notifications.where((n) => !n.read).length;
        emit(NotificationsLoaded(notifications, _lastUnreadCount));
      case Error(failure: final failure):
        if (!_hasList) emit(NotificationError(failure.message));
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
          emit(NotificationsLoaded(currentState.notifications, count,
              listLoaded: currentState.listLoaded));
        } else if (currentState is! NotificationLoading) {
          emit(NotificationsLoaded([], count, listLoaded: false));
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
    // Odmah označi u listi, pa potvrdi sa servera.
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final wasUnread =
          currentState.notifications.any((n) => n.id == event.id && !n.read);
      final updated = currentState.notifications
          .map((n) => n.id == event.id ? n.copyWith(read: true) : n)
          .toList();
      final reduced = currentState.unreadCount - 1;
      final count =
          wasUnread ? (reduced < 0 ? 0 : reduced) : currentState.unreadCount;
      _lastUnreadCount = count;
      emit(NotificationsLoaded(updated, count,
          listLoaded: currentState.listLoaded));
    }
    final result = await _repository.markRead(event.id);
    switch (result) {
      case Success():
        add(const LoadNotifications());
      case Error(failure: final failure):
        if (_hasList) {
          add(const LoadNotifications());
        } else {
          emit(NotificationError(failure.message));
        }
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      _lastUnreadCount = 0;
      emit(NotificationsLoaded(
        currentState.notifications.map((n) => n.copyWith(read: true)).toList(),
        0,
        listLoaded: currentState.listLoaded,
      ));
    }
    final result = await _repository.markAllRead();
    switch (result) {
      case Success():
        add(const LoadNotifications());
      case Error(failure: final failure):
        if (_hasList) {
          add(const LoadNotifications());
        } else {
          emit(NotificationError(failure.message));
        }
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
          listLoaded: currentState.listLoaded,
        ));
      } catch (_) {
        emit(NotificationsLoaded(currentState.notifications, newCount,
            listLoaded: currentState.listLoaded));
      }
    } else {
      emit(NotificationsLoaded([], newCount, listLoaded: false));
    }
  }
}
