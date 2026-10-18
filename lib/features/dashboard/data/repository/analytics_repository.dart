import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../api/analytics_api_service.dart';
import '../models/dashboard_models.dart';

class AnalyticsRepository {
  final AnalyticsApiService _apiService;

  AnalyticsRepository(this._apiService);

  Future<Result<Map<String, dynamic>>> getAdminOverview() =>
      _guard(_apiService.getAdminOverview);

  Future<Result<Map<String, dynamic>>> getAdminInquiryAnalytics() =>
      _guard(_apiService.getAdminInquiryAnalytics);

  Future<Result<Map<String, dynamic>>> getAdminInventoryAnalytics() =>
      _guard(_apiService.getAdminInventoryAnalytics);

  Future<Result<Map<String, dynamic>>> getMediaOwnerAnalytics() =>
      _guard(_apiService.getMediaOwnerAnalytics);

  Future<Result<Map<String, dynamic>>> getBrandAnalytics() =>
      _guard(_apiService.getBrandAnalytics);

  Future<Result<Map<String, dynamic>>> getAgencyAnalytics() =>
      _guard(_apiService.getAgencyAnalytics);

  /// Zahtevi za ponude vlasnika medija sa kontekstom upita i površinama.
  Future<Result<List<OwnerQuoteSummary>>> getMediaOwnerQuotes() async {
    try {
      final rows = await _apiService.getMediaOwnerQuotes();
      return Success(rows.map(OwnerQuoteSummary.fromJson).toList());
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  /// Vrednost prihvaćenih ponuda po valutama za navedene upite klijenta.
  /// Ponuda koja ne može da se učita se preskače.
  Future<Map<String, double>> getAcceptedOfferTotals(
      {required bool agency, required List<int> inquiryIds}) async {
    final sum = CurrencySum();
    final offers = await Future.wait(inquiryIds.map((id) => _apiService
        .getClientOffer(agency: agency, inquiryId: id)
        .then<Map<String, dynamic>?>((o) => o)
        .catchError((Object _) => null)));
    for (final offer in offers) {
      if (offer != null) sum.addAll(offerTotals(offer));
    }
    return sum.totals;
  }

  Future<Result<Map<String, dynamic>>> _guard(
      Future<Map<String, dynamic>> Function() call) async {
    try {
      return Success(await call());
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
