import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../api/analytics_api_service.dart';

class AnalyticsRepository {
  final AnalyticsApiService _apiService;

  AnalyticsRepository(this._apiService);

  Future<Result<Map<String, dynamic>>> getAdminOverview() async {
    try {
      final data = await _apiService.getAdminOverview();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> getAdminInquiryAnalytics() async {
    try {
      final data = await _apiService.getAdminInquiryAnalytics();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> getMediaOwnerAnalytics() async {
    try {
      final data = await _apiService.getMediaOwnerAnalytics();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> getBrandAnalytics() async {
    try {
      final data = await _apiService.getBrandAnalytics();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> getAgencyAnalytics() async {
    try {
      final data = await _apiService.getAgencyAnalytics();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
