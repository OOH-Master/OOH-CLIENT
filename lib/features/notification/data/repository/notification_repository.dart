import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../api/notification_api_service.dart';
import '../dto/notification_dto.dart';

class NotificationRepository {
  final NotificationApiService _apiService;

  NotificationRepository(this._apiService);

  Future<Result<List<NotificationDto>>> getNotifications() async {
    try {
      final notifications = await _apiService.getNotifications();
      return Success(notifications);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> markRead(int id) async {
    try {
      await _apiService.markRead(id);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> markAllRead() async {
    try {
      await _apiService.markAllRead();
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<int>> getUnreadCount() async {
    try {
      final count = await _apiService.getUnreadCount();
      return Success(count);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
