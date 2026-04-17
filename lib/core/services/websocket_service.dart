import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../config/api_config.dart';
import '../../features/auth/data/datasources/auth_token_storage.dart';
import '../../features/notification/presentation/blocs/notification_bloc.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _client;
  NotificationBloc? _notificationBloc;
  AuthTokenStorage? _tokenStorage;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  static String get _wsUrl {
    final base = ApiConfig.baseUrl.replaceFirst('/api/v1', '');
    // SockJS endpoint
    return '$base/ws';
  }

  void init(AuthTokenStorage tokenStorage, NotificationBloc notificationBloc) {
    _tokenStorage = tokenStorage;
    _notificationBloc = notificationBloc;
  }

  Future<void> connect() async {
    if (_isConnected || _tokenStorage == null) return;

    final token = await _tokenStorage!.getToken();
    if (token == null) return;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: _wsUrl,
        onConnect: (frame) => _onConnected(frame, token),
        onDisconnect: (_) => _onDisconnected(),
        onStompError: (frame) => debugPrint('[WS] STOMP error: ${frame.body}'),
        onWebSocketError: (error) => debugPrint('[WS] WS error: $error'),
        onWebSocketDone: () => _onDisconnected(),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void _onConnected(StompFrame frame, String token) {
    _isConnected = true;
    _reconnectTimer?.cancel();
    debugPrint('[WS] Connected');

    _client!.subscribe(
      destination: '/user/notifications',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!) as Map<String, dynamic>;
            debugPrint('[WS] Notification received: ${json['title']}');
            _notificationBloc?.add(NewNotificationPush(json));
          } catch (e) {
            debugPrint('[WS] Failed to parse notification: $e');
          }
        }
      },
    );
  }

  void _onDisconnected() {
    _isConnected = false;
    debugPrint('[WS] Disconnected');
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}
