import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ooh_mobile/app/app.dart';
import 'package:ooh_mobile/app/di.dart';
import 'package:ooh_mobile/features/auth/data/datasources/auth_token_storage.dart';
import 'package:ooh_mobile/features/discover/presentation/pages/discover_page.dart';

/// Integration (E2E) testovi za OOH Mobile aplikaciju.
///
/// VIZUELNI testovi — svaka akcija (tap, unos teksta, navigacija)
/// se desava na ekranu uredjaja/simulatora u realnom vremenu.
///
/// Preduslovi:
///   - Backend pokrenut na localhost:8080
///   - Baza sadrzi DataLoader bootstrap podatke
///   - Korisnik: brand / brand123
///
/// Pokretanje:
///   flutter test integration_test/app_test.dart -d <device_id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initDependencies();
  });

  setUp(() async {
    // Obrisi sacuvani token pre svakog testa
    // — sprecava auto-redirect na dashboard ako je korisnik
    //   bio prethodno ulogovan na uredjaju
    await getIt<AuthTokenStorage>().deleteToken();
  });

  // ─── Pomocne funkcije ──────────────────────────────────────────────

  /// Pumpa [total] milisekundi u koracima od 100ms.
  ///
  /// LandingPage ima beskonacne animacije (flutter_animate repeat,
  /// rekurzivni Future.delayed za kljucne reci u hero sekciji),
  /// pa pumpAndSettle() nikad ne zavrsi. Umesto toga eksplicitno
  /// pumpamo frame-ove sa kratkim intervalom — svaki frame renderuje
  /// sledecu slicicu na ekranu uredjaja.
  Future<void> pumpFrames(WidgetTester tester, Duration total) async {
    const frame = Duration(milliseconds: 100);
    final count = total.inMilliseconds ~/ frame.inMilliseconds;
    for (var i = 0; i < count; i++) {
      await tester.pump(frame);
    }
  }

  /// Pumpa frame-ove dok [finder] ne pronadje widget ili istekne [timeout].
  /// Vraca `true` ako je widget pronadjen.
  Future<bool> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    const frame = Duration(milliseconds: 200);
    final maxAttempts = timeout.inMilliseconds ~/ frame.inMilliseconds;
    for (var i = 0; i < maxAttempts; i++) {
      await tester.pump(frame);
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  // ─── Helper: Login ─────────────────────────────────────────────────

  /// Pumpa OohApp, otvara hamburger meni, tapuje "Prijavi se",
  /// unosi kredencijale i loguje se.
  ///
  /// Svaka akcija je prava UI interakcija vidljiva na simulatoru.
  Future<void> performLogin(WidgetTester tester) async {
    await tester.pumpWidget(const OohApp());

    // pump() umesto pumpAndSettle() — LandingPage ima beskonacne animacije
    await pumpFrames(tester, const Duration(seconds: 3));
    expect(find.text('AutoHome'), findsWidgets);

    // Mobilni layout: hamburger meni → bottom sheet
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final loginMenuItem = find.text('Prijavi se');
    expect(loginMenuItem, findsOneWidget);
    await tester.tap(loginMenuItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // LoginPage nema beskonacne animacije — pumpAndSettle je bezbedan
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'brand');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).last, 'brand123');
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));

    // Sacekaj POST /auth/login + GET /auth/me + navigaciju na /app/discover
    final navigated = await pumpUntil(
      tester,
      find.byType(DiscoverPage),
      timeout: const Duration(seconds: 20),
    );
    expect(navigated, isTrue,
        reason: 'DiscoverPage treba da se pojavi nakon uspesnog login-a');
  }

  // ─── Test: Login → Discover ───────────────────────────────────────

  group('E2E: Login → Discover tok', () {
    testWidgets(
        'korisnik se prijavljuje, vidi gradove i inventar na Discover stranici',
        (tester) async {
      // ── 1. Login ──────────────────────────────────────────────
      await performLogin(tester);

      // Verifikuj da smo na Discover stranici
      expect(find.byType(DiscoverPage), findsOneWidget);

      // ── 2. Discover: gradovi i inventar ───────────────────────
      // Sacekaj ucitavanje gradova iz API-ja
      // DiscoverPage u initState poziva LoadCities() i LoadDictionaries()
      final citiesLoaded = await pumpUntil(
        tester,
        find.text('Beograd, Srbija'),
        timeout: const Duration(seconds: 15),
      );
      expect(citiesLoaded, isTrue,
          reason: 'Grad "Beograd, Srbija" treba da se pojavi u dropdown-u');

      // Pumpaj jos koji frame da se inventar ucita
      await pumpFrames(tester, const Duration(seconds: 2));

      // Verifikuj da je grad ucitan
      expect(find.text('Beograd, Srbija'), findsOneWidget);

      // Verifikuj da je inventar ucitan — nema vise loading indikatora
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );
    });
  });
}
