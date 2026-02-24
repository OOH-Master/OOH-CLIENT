# Testiranje (Frontend — Flutter)

## 1. Pregled

Flutter frontend koristi cetiri nivoa testiranja:

| Nivo | Alat | Namena |
|------|------|--------|
| **BLoC testovi** | `bloc_test` + `mockito` | Testiranje poslovne logike (state tranzicije) |
| **Widget testovi** | `flutter_test` + `mockito` | Testiranje UI komponenti i interakcija |
| **Unit testovi** | `flutter_test` | Testiranje cistih Dart klasa i utility funkcija |
| **Integration (E2E) testovi** | `integration_test` | Testiranje celih korisnickih tokova sa stvarnim backend-om |

### Zavisnosti (dev_dependencies)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4          # Mock framework
  bloc_test: ^10.0.0        # BLoC test helper (blocTest)
  build_runner: ^2.4.17     # Generisanje mock klasa
  integration_test:
    sdk: flutter             # E2E integration testovi
```

## 2. Struktura Test Foldera

```
test/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   ├── auth_bloc_test.dart          # 6 BLoC testova
│   │       │   └── auth_bloc_test.mocks.dart    # Generisan
│   │       └── pages/
│   │           ├── login_page_test.dart          # 7 widget testova
│   │           └── login_page_test.mocks.dart   # Generisan
│   └── discover/
│       └── presentation/
│           └── blocs/
│               ├── discover_bloc_test.dart       # 16 BLoC testova
│               └── discover_bloc_test.mocks.dart # Generisan
└── widget_test.dart                              # Smoke test

integration_test/
└── app_test.dart                                 # 1 E2E test (Login → Discover tok)
```

## 3. BLoC Testovi

BLoC testovi verifikuju **state tranzicije** — kako BLoC reaguje na dogadjaje (events) i koje stanja (states) emituje. Ovo je srz biznis logike u Flutter aplikaciji jer BLoC razdvaja prezentacioni sloj od poslovne logike.

### Zasto BLoC testovi?

BLoC pattern je jedini sloj izmedju UI-ja i API poziva. Svaka korisnicka akcija (login, pretraga, filtriranje) prolazi kroz BLoC. Testiranjem state tranzicija osiguravamo da:
- UI prima ispravna stanja (loading → loaded, loading → error)
- Greske sa API-ja se pravilno propagiraju do korisnika
- State se ispravno azurira pri promeni filtera, gradova, itd.

### Pristup

1. Mock-ujemo zavisnosti (use case / repository) pomocu `@GenerateNiceMocks`
2. Koristimo `blocTest<Bloc, State>()` helper za deklarativan test setup
3. Svaki test definise: `build` (kreiranje BLoC-a), `act` (slanje dogadjaja), `expect` (ocekivana stanja)
4. `seed` parametar omogucava postavljanje pocetnog stanja (npr. `DiscoverLoaded` pre `SelectCity`)

### Primer: auth_bloc_test.dart

```dart
@GenerateNiceMocks([
  MockSpec<LoginUseCase>(),
  MockSpec<RegisterUseCase>(),
  MockSpec<GetCurrentUserUseCase>(),
  MockSpec<LogoutUseCase>(),
])
import 'auth_bloc_test.mocks.dart';

void main() {
  setUpAll(() {
    // Mockito zahteva dummy vrednosti za sealed Result<T> tipove
    provideDummy<Result<User>>(const Success(testUser));
    provideDummy<Result<User?>>(const Success<User?>(null));
    provideDummy<Result<void>>(const Success(null));
  });

  blocTest<AuthBloc, AuthState>(
    'emituje [AuthLoading, AuthAuthenticated] na uspesan login',
    build: () {
      when(mockLoginUseCase('testuser', 'password123'))
          .thenAnswer((_) async => const Success(testUser));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoginSubmitted('testuser', 'password123')),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthAuthenticated>()
          .having((s) => s.user.name, 'user.name', 'testuser'),
    ],
  );
}
```

### Pokriveni scenariji

**`auth_bloc_test.dart`** — 6 testova:
- LoginSubmitted: uspeh → AuthAuthenticated, greska → AuthFailure
- RegisterSubmitted: uspeh → AuthAuthenticated
- LogoutRequested → AuthUnauthenticated
- AuthStarted: sa tokenom → AuthAuthenticated, bez tokena → AuthUnauthenticated

**`discover_bloc_test.dart`** — 16 testova:
- LoadCities: default grad (Beograd), prazna lista, greska
- LoadInventoryUnits: ucitavanje sa filtrima, greska
- SelectCity: promena grada pokece novo ucitavanje, null grad prazni listu
- ApplyFilters: merge filtera sa aktivnim gradom
- ResetFilters: vracanje na pocetne filtere
- LoadDictionaries: ucitavanje tipova, formata, venue tipova

### Napomena: `provideDummy`

Mockito ne ume automatski da kreira dummy vrednosti za sealed klase (`Result<T>`). Zato u `setUpAll` eksplicitno registrujemo dummy vrednosti:

```dart
setUpAll(() {
  provideDummy<Result<List<City>>>(const Success([]));
  provideDummy<Result<List<OohUnit>>>(const Success([]));
});
```

## 4. Widget Testovi

Widget testovi verifikuju **UI renderovanje i korisnicku interakciju** — da li se ispravni elementi prikazuju na ekranu i da li reaguju na korisnicke akcije (tap, unos teksta, validacija forme).

### Zasto widget testovi?

Widget testovi dopunjuju BLoC testove — dok BLoC testovi verifikuju logiku, widget testovi verifikuju da UI korektno prikazuje stanja i reaguje na interakciju. Konkretno:
- Da li se login forma renderuje sa svim potrebnim elementima (polja, dugmad, ikonice)
- Da li validacija forme radi (prazna polja → greska)
- Da li form submission dispatchuje ispravan BLoC event
- Da li se loading indicator prikazuje tokom API poziva

### Pristup

1. Kreiramo test wrapper koji pruza sve neophodne providere (BLoC, lokalizacija, GoRouter)
2. Koristimo `tester.pumpWidget()` za renderovanje, `tester.tap()` i `tester.enterText()` za interakciju
3. Verifikujemo prisustvo widgeta pomocu `find.byType()`, `find.text()`, `find.byIcon()`

### Primer: login_page_test.dart

```dart
setUpAll(() {
  GoogleFonts.config.allowRuntimeFetching = false;
  provideDummy<Result<User>>(...);
});

Future<void> pumpLoginPage(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'app_locale': 'sr'});
  final prefs = await SharedPreferences.getInstance();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/app/discover', builder: (_, __) => const Scaffold()),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => buildBloc()),
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit(prefs)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('sr'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
```

### Pokriveni scenariji

**`login_page_test.dart`** — 7 testova:

| Grupa | Test | Opis |
|-------|------|------|
| Rendering | username i password polja | Verifikuje 2 TextFormField-a i ikonice |
| Rendering | login dugme | Verifikuje ElevatedButton |
| Rendering | logo tekst | Verifikuje "AutoHome" tekst |
| Validation | prazna polja | Klik na login sa praznim poljima — forma ostaje |
| Validation | popunjena polja | Unos podataka ne pokazuje gresku |
| BLoC interaction | LoginSubmitted dispatch | Popuni formu + klikni → verifikuj poziv use case-a |
| BLoC interaction | Loading indicator | Tokom login-a prikazuje CircularProgressIndicator |

### Napomene za widget testove

- **Google Fonts**: U testovima se iskljucuje runtime fetching sa `GoogleFonts.config.allowRuntimeFetching = false`
- **GoRouter**: LoginPage koristi `context.go()`, pa test mora da pruzi GoRouter sa definisanim rutama
- **Lokalizacija**: Test wrapper mora da sadrzi `localizationsDelegates` i `supportedLocales`
- **SharedPreferences**: Koristimo `SharedPreferences.setMockInitialValues({})` za mock storage
- **Pending timers**: Za simulaciju loading stanja koristimo `Completer<T>` umesto `Future.delayed`

## 5. Generisanje Mock Klasa

Mock klase se generisu pomocu `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Svaki test fajl sa `@GenerateNiceMocks` anotacijom generise odgovarajuci `.mocks.dart` fajl.

## 6. Pokretanje Testova

### Svi testovi

```bash
flutter test
```

### Samo feature testovi (preporuceno)

```bash
flutter test test/features/
```

### Specifican test fajl

```bash
flutter test test/features/auth/presentation/blocs/auth_bloc_test.dart
```

### Sa verbose izlazom

```bash
flutter test --reporter expanded
```

## 7. Integration (E2E) Testovi

Integration testovi pokrecu **stvarnu aplikaciju** sa **stvarnim backend-om** i testiraju kompletne korisnicke tokove (end-to-end). Svaka akcija (tap, unos teksta, navigacija) se vizuelno desava na ekranu uredjaja/simulatora u realnom vremenu.

### Zasto E2E testovi?

Unit i widget testovi koriste mock-ove — ne testiraju stvarnu komunikaciju sa backend-om, serijalizaciju/deserijalizaciju JSON-a, routing izmedju stranica, niti vizuelno ponasanje na uredjaju. E2E test potvrduje da **ceo sistem radi end-to-end**: Flutter app → HTTP poziv → Spring Boot API → PostgreSQL baza → response → UI prikaz.

### Razlika od unit/widget testova

| Karakteristika | Unit/Widget testovi | Integration (E2E) testovi |
|----------------|--------------------|----|
| Backend | Mock-ovan | Stvarni (localhost:8080) |
| Baza | Nema | Stvarna (H2/Postgres) |
| Network pozivi | Nema | Da |
| Brzina | ~4 sekunde | ~15-30 sekundi |
| Pouzdanost | Deterministicka | Zavisi od backend-a |

### Preduslovi

1. **Backend pokrenut** na `localhost:8080`:
   ```bash
   cd ooh-backend && ./gradlew bootRun
   ```

2. **DataLoader podaci** ucitani u bazu (automatski pri pokretanju backend-a)

3. **Test korisnik** postoji: `brand` / `brand123` (BRAND rola)

### Pristup

1. `IntegrationTestWidgetsFlutterBinding` — specijalni binding za E2E koji omogucava pokretanje na stvarnom uredjaju
2. `initDependencies()` — inicijalizacija GetIt DI kontejnera sa pravim API servisima (Dio HTTP klijent, repozitorijumi)
3. `AuthTokenStorage.deleteToken()` u `setUp` — brise sacuvani JWT token da test pocinje od LandingPage
4. `OohApp()` widget — identican produkcioni app bez modifikacija
5. Prava UI interakcija: `tester.tap()`, `tester.enterText()`, `find.byIcon()` — svaka akcija je vidljiva na ekranu
6. `pump()` umesto `pumpAndSettle()` za stranice sa beskonacnim animacijama

### Vazne tehnicke odluke

#### pump() vs pumpAndSettle()

`pumpAndSettle()` pumpa frame-ove dok nema vise zakazanih animacija. Problem: LandingPage ima **beskonacne animacije** (`flutter_animate` sa `controller.repeat()` i rekurzivni `Future.delayed` za rotaciju kljucnih reci). Na takvoj stranici `pumpAndSettle` nikada ne zavrsi i test se zamrzne.

Resenje: `pumpFrames()` helper pumpa fiksni broj frame-ova (npr. 3 sekunde × 10 fps = 30 frame-ova). Na LoginPage (koja nema beskonacne animacije) `pumpAndSettle()` je bezbedan.

**Bitno:** prvi parametar `pumpAndSettle([Duration])` je interval izmedju frame-ova, NE timeout. `pumpAndSettle(Duration(seconds: 5))` bi pumpao 1 frame na svakih 5 sekundi — zamrzavajuci prikaz.

#### Vizuelna interakcija vs programska navigacija

Test koristi **prave UI akcije** — tapne hamburger meni, bira opciju iz bottom sheet-a, unosi tekst u polja forme. Ovo je svesna odluka:
- Testira isti tok koji bi korisnik prosao rucno
- Vizuelno je vidljiv na simulatoru (korisno za demonstraciju na odbrani)
- Pokriva UI elemente koje programska navigacija preskace (meni, bottom sheet, forme, animacije)

### Pokriveni scenariji

**`integration_test/app_test.dart`** — 1 test (kompletan Login → Discover tok):

| Test | Opis |
|------|------|
| Login → Discover tok | Pokrece app → navigira na login → unosi kredencijale (brand/brand123) → verifikuje Discover stranicu → ucitavanje gradova (Beograd) → prikaz inventara |

### Primer: Login E2E test

```dart
/// Pumpa frame-ove umesto pumpAndSettle (Landing ima beskonacne animacije)
Future<void> pumpFrames(WidgetTester tester, Duration total) async {
  const frame = Duration(milliseconds: 100);
  for (var i = 0; i < total.inMilliseconds ~/ frame.inMilliseconds; i++) {
    await tester.pump(frame);
  }
}

testWidgets('korisnik se prijavljuje i vidi Discover stranicu', (tester) async {
  // 1. Pokreni aplikaciju
  await tester.pumpWidget(const OohApp());
  await pumpFrames(tester, const Duration(seconds: 3));

  // 2. Verifikuj LandingPage
  expect(find.text('AutoHome'), findsWidgets);

  // 3. Otvori hamburger meni (mobilni layout)
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));

  // 4. Tapuj "Prijavi se" u bottom sheet-u
  await tester.tap(find.text('Prijavi se'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle(); // LoginPage nema beskonacne animacije

  // 5. Unesi kredencijale
  await tester.enterText(find.byType(TextFormField).first, 'brand');
  await tester.enterText(find.byType(TextFormField).last, 'brand123');

  // 6. Klikni login
  await tester.tap(find.byType(ElevatedButton));

  // 7. Sacekaj navigaciju na Discover (pump petlja za network pozive)
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.byType(DiscoverPage).evaluate().isNotEmpty) break;
  }

  // 8. Verifikuj Discover stranicu
  expect(find.byType(DiscoverPage), findsOneWidget);
});
```

### Pokretanje E2E testova

```bash
# iOS Simulator
flutter test integration_test/ -d iPhone

# Android Emulator
flutter test integration_test/ -d emulator

# Chrome (web)
flutter test integration_test/ -d chrome
```

## 8. Rezime

| Metrika | Vrednost |
|---------|----------|
| Ukupan broj test fajlova | 4 (3 unit/widget + 1 E2E) |
| Ukupan broj testova | 30 (29 unit/widget + 1 E2E) |
| BLoC testova | 22 |
| Widget testova | 7 |
| E2E testova | 1 |
| Pokriveni feature-i | Auth (login/register/logout), Discover (filtriranje/pretraga) |
| Prosecno vreme izvrsavanja | ~4 sekunde (unit/widget), ~15-30 sekundi (E2E) |
| Mock framework | Mockito + @GenerateNiceMocks |
| E2E framework | integration_test (Flutter SDK) |
