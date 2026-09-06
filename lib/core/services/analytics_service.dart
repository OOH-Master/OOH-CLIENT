import 'package:logger/logger.dart';

/// Ugovor za analitiku upotrebe: događaji koje aplikacija emituje na
/// ključnim koracima korisničkog toka. Implementacija se bira pri
/// pokretanju (GetIt), pa se Firebase Analytics ili drugi provajder dodaje
/// kao adapter ovog ugovora, bez izmena u BLoC klasama koje događaje šalju.
abstract class AnalyticsService {
  void track(String event, [Map<String, Object?> params = const {}]);
}

/// Podrazumevana implementacija: događaji se beleže u dnevnik aplikacije.
class LogAnalyticsService implements AnalyticsService {
  LogAnalyticsService(this._logger);

  final Logger _logger;

  @override
  void track(String event, [Map<String, Object?> params = const {}]) {
    _logger.i('[analytics] $event${params.isEmpty ? '' : ' $params'}');
  }
}

/// Statička pristupna tačka, da BLoC klase ne zavise od DI kontejnera.
/// Dok implementacija nije registrovana (npr. u testovima), pozivi su no-op.
class Analytics {
  Analytics._();

  static AnalyticsService? _service;

  static void use(AnalyticsService service) => _service = service;

  static void track(String event, [Map<String, Object?> params = const {}]) =>
      _service?.track(event, params);
}

/// Imena događaja na jednom mestu, usklađena sa izveštajima.
class AnalyticsEvents {
  AnalyticsEvents._();

  static const searchCitySelected = 'search_city_selected';
  static const searchFiltersApplied = 'search_filters_applied';
  static const searchMoreLoaded = 'search_more_loaded';
  static const unitAddedToInquiry = 'unit_added_to_inquiry';
  static const unitRemovedFromInquiry = 'unit_removed_from_inquiry';
  static const inquirySubmitted = 'inquiry_submitted';
  static const offerAccepted = 'offer_accepted';
  static const offerRejected = 'offer_rejected';
}
