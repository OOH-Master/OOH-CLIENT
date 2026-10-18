import 'package:dio/dio.dart';

/// Poruke o greškama na srpskom. BLoC prosleđuje tekst izuzetka (Dio, poruke
/// servera na engleskom), a korisnik vidi samo kratko objašnjenje.
class InquiryErrors {
  InquiryErrors._();

  static String describe(Object? error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code != null) return _forStatus(code);
      return _network;
    }
    final text = (error ?? '').toString().toLowerCase();
    final code = RegExp(r'status code of (\d{3})').firstMatch(text)?.group(1);
    if (code != null) return _forStatus(int.parse(code));
    if (text.contains('only brands') || text.contains('nije dostupan')) {
      return 'Ova radnja nije dostupna za vašu ulogu.';
    }
    if (text.contains('connection') ||
        text.contains('socket') ||
        text.contains('xmlhttprequest') ||
        text.contains('timeout') ||
        text.contains('network')) {
      return _network;
    }
    return 'Došlo je do greške. Pokušajte ponovo.';
  }

  static const _network =
      'Server trenutno nije dostupan. Proverite vezu i pokušajte ponovo.';

  static String _forStatus(int code) {
    if (code == 401) return 'Sesija je istekla. Prijavite se ponovo.';
    if (code == 403) return 'Nemate pristup ovom podatku.';
    if (code == 404) return 'Traženi podatak nije pronađen.';
    if (code == 409) {
      return 'Podatak je u međuvremenu promenjen. Osvežite prikaz.';
    }
    if (code >= 500) {
      return 'Greška na serveru. Pokušajte ponovo za nekoliko trenutaka.';
    }
    return 'Zahtev nije prihvaćen. Proverite podatke i pokušajte ponovo.';
  }
}
