import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/notification_dto.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService(this._apiClient);

  /// Server vraća Spring `Page` (`{content: [...], totalElements, ...}`);
  /// prihvata se i obična lista, za slučaj da se odgovor promeni.
  Future<List<NotificationDto>> getNotifications({int size = 50}) async {
    final response = await _apiClient.get<dynamic>(
      ApiConfig.notifications,
      queryParameters: {'size': size},
    );
    final data = response.data;
    final List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map && data['content'] is List) {
      raw = data['content'] as List<dynamic>;
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map>()
        .map(
            (json) => NotificationDto.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Server ima PUT /{id}/read i PUT /read-all (POST je vraćao 405).
  Future<void> markRead(int id) async {
    await _apiClient.put('${ApiConfig.notifications}/$id/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.put('${ApiConfig.notifications}/read-all');
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get<dynamic>(
      ApiConfig.notificationsUnreadCount,
    );
    final data = response.data;
    if (data is Map) return (data['count'] as num?)?.toInt() ?? 0;
    if (data is num) return data.toInt();
    return 0;
  }
}
