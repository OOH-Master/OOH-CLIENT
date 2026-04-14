import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/notification_dto.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService(this._apiClient);

  Future<List<NotificationDto>> getNotifications() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.notifications);
    return (response.data ?? [])
        .map((json) => NotificationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    await _apiClient.post('${ApiConfig.notifications}/$id/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.post('${ApiConfig.notifications}/read-all');
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.notificationsUnreadCount,
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }
}
