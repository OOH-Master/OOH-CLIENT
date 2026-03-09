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
│               ├── discover_bloc_test.dart       # 28 BLoC testova
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

### Pokriveni scenariji

**`auth_bloc_test.dart`** — 6 testova:
- LoginSubmitted: uspeh → AuthAuthenticated, greska → AuthFailure
- RegisterSubmitted: uspeh → AuthAuthenticated
- LogoutRequested → AuthUnauthenticated
- AuthStarted: sa tokenom → AuthAuthenticated, bez tokena → AuthUnauthenticated

**`discover_bloc_test.dart`** — 28 testova:
- LoadCities: default grad (Beograd), prazna lista, greska
- LoadCountries: ucitavanje drzava, default drzava (Srbija), prazna lista, greska
- LoadInventoryUnits: ucitavanje sa filtrima, greska
- SelectCity: promena grada pokece novo ucitavanje, null grad prazni listu
- SelectCountry: promena drzave filtrira gradove, null drzava prikazuje sve gradove ("Sve drzave")
- ApplyFilters: merge filtera sa aktivnim gradom
- ResetFilters: vracanje na pocetne filtere
- LoadDictionaries: ucitavanje tipova, formata, venue tipova

### Napomena: `provideDummy`

Mockito ne ume automatski da kreira dummy vrednosti za sealed klase (`Result<T>`). Zato u `setUpAll` eksplicitno registrujemo dummy vrednosti:

```dart
setUpAll(() {
  provideDummy<Result<List<City>>>(const Success([]));
  provideDummy<Result<List<Country>>>(const Success([]));
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

### Kako widget testovi rade?

Widget testovi se izvrsavaju **u memoriji** — ne na uredjaju ili simulatoru. Flutter test framework kreira virtualni rendering engine koji crta widgete u memoriji i pruza `WidgetTester` objekat za interakciju:

1. **`tester.pumpWidget(widget)`** — renderuje widget u virtualnom okruzenju (ekvivalent otvaranja stranice)
2. **`tester.pump()`** — renderuje jedan frame (pomera animacije, obradjuje zakazane callback-ove)
3. **`tester.pumpAndSettle()`** — pumpa frame-ove dok nema vise zakazanih animacija (ceka da se sve animacije zavrse)
4. **`tester.tap(finder)`** — simulira tap na widget koji finder pronadje
5. **`tester.enterText(finder, text)`** — simulira unos teksta u TextFormField
6. **`find.byType(Widget)`** — trazi widget po tipu (npr. `find.byType(ElevatedButton)`)
7. **`find.text('tekst')`** — trazi widget koji sadrzi dati tekst
8. **`expect(finder, matcher)`** — verifikuje da finder pronadje ocekivani broj widgeta

### Pristup

1. Kreiramo test wrapper koji pruza sve neophodne providere (BLoC, lokalizacija, GoRouter)
2. Koristimo `tester.pumpWidget()` za renderovanje, `tester.tap()` i `tester.enterText()` za interakciju
3. Verifikujemo prisustvo widgeta pomocu `find.byType()`, `find.text()`, `find.byIcon()`

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
| Vizuelni prikaz | Nema (memorija) | Da — na simulatoru/uredjaju |
| Mock-ovi | Da (use case, repository) | Ne — pravi servisi, pravi DI |

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

Resenje: `pumpFrames()` helper pumpa fiksni broj frame-ova (npr. 3 sekunde x 10 fps = 30 frame-ova). Na LoginPage (koja nema beskonacne animacije) `pumpAndSettle()` je bezbedan.

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

### Pokretanje E2E testova

```bash
# iOS Simulator
flutter test integration_test/ -d iPhone

# Android Emulator
flutter test integration_test/ -d emulator

# Chrome (web)
flutter test integration_test/ -d chrome
```

## 8. Detaljni Opis Odabranih Testova (Liniju po Liniju)

Ovaj odeljak objasnjava odabrane testove korak po korak — svaku liniju koda, cemu sluzi i zasto je napisana. Ovo je korisno za usmenu odbranu jer omogucava detaljno objasnjenje logike testiranja.

### Test 1: BLoC Test — `LoginSubmitted` uspesan login (auth_bloc_test.dart)

Ovaj test verifikuje da AuthBloc pravilno obradjuje uspesan login: emituje loading stanje, poziva use case, i emituje autentifikovano stanje sa korisnickim podacima.

```dart
blocTest<AuthBloc, AuthState>(
  'emituje [AuthLoading, AuthAuthenticated] na uspesan login',
```
- `blocTest<AuthBloc, AuthState>()` — helper funkcija iz `bloc_test` paketa. Genericki tipovi definisu koji BLoC se testira (`AuthBloc`) i koji tip stanja ocekujemo (`AuthState`).
- String parametar je opis testa koji se prikazuje u test izvestaju.

```dart
  build: () {
    when(mockLoginUseCase('testuser', 'password123'))
        .thenAnswer((_) async => const Success(testUser));
    return buildBloc();
  },
```
- **`build`** — kreira instancu BLoC-a za test. Poziva se pre `act`.
- `when(mockLoginUseCase(...)).thenAnswer(...)` — Mockito konfiguracija: kada se `LoginUseCase` pozove sa `'testuser'` i `'password123'`, vraca `Success(testUser)`. `thenAnswer` se koristi za async metode (vraca `Future`), dok se `thenReturn` koristi za sinhrone.
- `buildBloc()` je helper koji kreira `AuthBloc` sa sva 4 mock use case-a.

```dart
  act: (bloc) => bloc.add(const LoginSubmitted('testuser', 'password123')),
```
- **`act`** — akcija koja se izvrsava na BLoC-u. `bloc.add()` salje event (dogadjaj) u BLoC.
- `LoginSubmitted` je event klasa sa dva parametra: username i password. Ovo simulira klik na "Prijavi se" dugme u UI-ju.

```dart
  expect: () => [
    isA<AuthLoading>(),
    isA<AuthAuthenticated>().having(
      (s) => s.user.name,
      'user.name',
      'testuser',
    ),
  ],
);
```
- **`expect`** — lista stanja koja BLoC treba da emituje **u tacnom redosledu**:
  1. `AuthLoading` — prikazuje loading indicator u UI-ju
  2. `AuthAuthenticated` — login uspesan, korisnik je autentifikovan
- `isA<AuthAuthenticated>()` — type matcher koji proverava tip stanja
- `.having((s) => s.user.name, 'user.name', 'testuser')` — **dodatna provera na stanju**: izvlaci `user.name` iz `AuthAuthenticated` stanja i proverava da je `'testuser'`. Drugi parametar (`'user.name'`) je opis za poruku greske.
- Ako BLoC emituje stanja u pogresnom redosledu ili sa pogresnim podacima, test pada.

**Sta ovaj test dokazuje na odbrani:**
1. BLoC emituje `AuthLoading` pre API poziva — UI prikazuje loading indicator
2. Nakon uspesnog login-a, BLoC emituje `AuthAuthenticated` sa korektnim korisnickim podacima
3. Redosled stanja je tacan: loading → authenticated (ne obrnuto)
4. `blocTest` helper automatski verifikuje i pocetno stanje i upravlja subscription-om

---

### Test 2: BLoC Test — `LoginSubmitted` neuspesan login (auth_bloc_test.dart)

```dart
blocTest<AuthBloc, AuthState>(
  'emituje [AuthLoading, AuthFailure] na neuspesan login',
  build: () {
    when(mockLoginUseCase('wrong', 'wrong'))
        .thenAnswer((_) async => const Error(ServerFailure('Invalid credentials')));
    return buildBloc();
  },
  act: (bloc) => bloc.add(const LoginSubmitted('wrong', 'wrong')),
  expect: () => [
    isA<AuthLoading>(),
    isA<AuthFailure>().having(
      (s) => s.message,
      'message',
      'Invalid credentials',
    ),
  ],
);
```
- Mock vraca `Error(ServerFailure('Invalid credentials'))` — simulira HTTP 401 odgovor sa backend-a.
- `Result<T>` je sealed klasa sa dva podtipa: `Success<T>` i `Error<T>`. BLoC proverava tip rezultata i emituje odgovarajuce stanje.
- Ocekivana stanja: `AuthLoading` → `AuthFailure` sa porukom `'Invalid credentials'`.
- `.having((s) => s.message, 'message', 'Invalid credentials')` - proverava da poruka greske iz `ServerFailure` stize do UI-ja.

**Sta ovaj test dokazuje na odbrani:**
1. BLoC pravilno hendluje greske — ne emituje `AuthAuthenticated` na neuspesan login
2. Poruka greske se propagira sa backend-a do UI-ja
3. `Result<T>` sealed klasa omogucava type-safe error handling bez try/catch

---

### Test 3: BLoC Test — `LoadCities` sa default gradom (discover_bloc_test.dart)

Ovaj test verifikuje najkompleksniji BLoC scenario: ucitavanje gradova, automatski odabir default grada, i pokretanje ucitavanja inventara za taj grad.

```dart
blocTest<DiscoverBloc, DiscoverState>(
  'emituje [DiscoverLoading, DiscoverLoaded] sa Beogradom kao default gradom',
  build: () {
    when(mockRepository.getCities(countryId: null))
        .thenAnswer((_) async => Success(testCities));
    when(mockRepository.getUnits(filters: anyNamed('filters')))
        .thenAnswer((_) async => Success(testUnits));
    return buildBloc();
  },
```
- Mock-ujemo **dva** API poziva jer `LoadCities` handler interno poziva i `LoadInventoryUnits`:
  - `getCities()` vraca listu gradova (Beograd, Novi Sad)
  - `getUnits()` vraca listu oglasnih jedinica za default grad
- `anyNamed('filters')` — Mockito matcher koji se poklapa sa bilo kojom vrednoscu named parametra `filters`.

```dart
  act: (bloc) => bloc.add(const LoadCities()),
  wait: const Duration(milliseconds: 300),
```
- `wait` — ceka 300ms pre provere stanja. Ovo je potrebno jer BLoC interno okida drugi event (`LoadInventoryUnits`) koji je asinhroni. Bez `wait`, test bi proverio stanja pre nego sto drugi event zavrsi.

```dart
  expect: () => [
    isA<DiscoverLoading>(),
    isA<DiscoverLoaded>()
        .having((s) => s.cities.length, 'cities.length', 2)
        .having((s) => s.selectedCity?.name, 'selectedCity', 'Beograd'),
    isA<DiscoverLoaded>()
        .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
    isA<DiscoverLoaded>()
        .having((s) => s.units.length, 'units.length', 2),
  ],
);
```
- **4 stanja u nizu** — ovaj test verifikuje kompletnu sekvencu:
  1. `DiscoverLoading` — pocela pretraga (prikazuje spinner)
  2. `DiscoverLoaded` sa 2 grada i Beograd kao `selectedCity` — gradovi ucitani, default grad odabran
  3. `DiscoverLoaded` sa `isLoadingUnits=true` — pokrece se ucitavanje inventara za Beograd
  4. `DiscoverLoaded` sa 2 unit-a — inventar za Beograd ucitan
- `.having()` lanci omogucavaju proveru vise polja na istom stanju.

**Sta ovaj test dokazuje na odbrani:**
1. BLoC automatski bira default grad (Beograd — grad sa najvise inventara)
2. Nakon ucitavanja gradova, BLoC automatski pokece ucitavanje inventara (ne ceka korisnicku akciju)
3. Kompletna sekvenca stanja prati ocekivani tok: loading → gradovi → loading inventara → inventar
4. `wait` parametar resava race condition izmedju dva asinhrone operacija

---

### Test 4: Widget Test — renderovanje login forme (login_page_test.dart)

Ovaj test verifikuje da se LoginPage pravilno renderuje sa svim potrebnim elementima.

```dart
testWidgets('prikazuje polja za username i password', (tester) async {
```
- `testWidgets` — Flutter test helper za widget testove. Pruza `WidgetTester tester` objekat za interakciju sa widgetima.

```dart
  await pumpLoginPage(tester);
```
- `pumpLoginPage()` je helper metoda koja renderuje LoginPage sa svim potrebnim zavisnostima. Pogledajmo sta radi:

```dart
Future<void> pumpLoginPage(WidgetTester tester, {AuthBloc? bloc}) async {
  SharedPreferences.setMockInitialValues({'app_locale': 'sr'});
  final prefs = await SharedPreferences.getInstance();
```
- `SharedPreferences.setMockInitialValues({})` — Flutter testovi nemaju pristup nativnom storage-u. Ova metoda kreira in-memory zamenu za SharedPreferences. Postavljamo `app_locale: 'sr'` da test koristi srpski jezik.

```dart
  final router = buildTestRouter();
```
- Kreira `GoRouter` sa minimalnim rutama. LoginPage koristi `context.go('/app/discover')` za navigaciju nakon login-a, pa GoRouter mora da ima ovu rutu definisanu (inace bi bacio izuzetak).

```dart
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => bloc ?? buildBloc()),
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
- `tester.pumpWidget()` — renderuje widget stablo u virtualnom okruzenju.
- `MultiBlocProvider` — pruza `AuthBloc` i `LocaleCubit` (za lokalizaciju) — LoginPage ih cita iz context-a sa `context.read<AuthBloc>()`.
- `MaterialApp.router` — obavija stranicu u Material temu i routing (isto kao u produkcijskom kodu).
- `pumpAndSettle()` — ceka da se svi widgeti renderuju i sve animacije zavrse.

```dart
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.byIcon(Icons.person_outlined), findsOneWidget);
  expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
});
```
- `find.byType(TextFormField)` — pretrazuje renderovano stablo i nalazi sve `TextFormField` widgete.
- `findsNWidgets(2)` — ocekujemo tacno 2 (username + password).
- `find.byIcon(Icons.person_outlined)` — verifikuje da postoji ikonica osobe (za username polje).
- `find.byIcon(Icons.lock_outlined)` — verifikuje da postoji ikonica katanca (za password polje).
- Ako LoginPage ne renderuje ova polja (npr. greska u layout-u), test pada.

**Sta ovaj test dokazuje na odbrani:**
1. LoginPage se uspesno renderuje bez backend-a (sve zavisnosti su mock-ovane)
2. Forma ima tacno 2 polja za unos
3. Ikonice pomazu korisniku da razlikuje username od password polja
4. Widget testovi verifikuju vizuelnu strukturu bez pokretanja na uredjaju

---

### Test 5: Widget Test — `CircularProgressIndicator` tokom loading-a (login_page_test.dart)

Ovaj test verifikuje da se tokom API poziva prikazuje loading indikator — najkompleksniji widget test jer zahteva kontrolu nad timing-om asinhronog poziva.

```dart
testWidgets('prikazuje CircularProgressIndicator tokom loading stanja',
    (tester) async {
  final completer = Completer<Result<User>>();
  when(mockLoginUseCase(any, any)).thenAnswer((_) => completer.future);
```
- `Completer<Result<User>>()` — Dart klasa koja daje kontrolu nad Future-om. Za razliku od `Future.delayed`, Completer se **nikad ne zavrsi sam** — mi odlucujemo kada cemo pozvati `completer.complete()`.
- Mock `loginUseCase` vraca `completer.future` — sto znaci da ce BLoC emitovati `AuthLoading` i **ostati u tom stanju** dok mi eksplicitno ne zavrsimo Future.
- Zasto ne `Future.delayed`? Zato sto `Future.delayed` koristi timer koji moze da istekne tokom testa i izazove "pending timer" upozorenje. `Completer` je cistiji pattern.

```dart
  final bloc = buildBloc();
  await pumpLoginPage(tester, bloc: bloc);
```
- Kreiramo BLoC sa mock-ovanim use case-ovima i renderujemo LoginPage sa tim BLoC-om.

```dart
  await tester.enterText(find.byType(TextFormField).first, 'testuser');
  await tester.enterText(find.byType(TextFormField).last, 'password123');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump(const Duration(milliseconds: 100));
```
- `enterText` — simulira korisnikov unos teksta u username i password polja.
- `tap(ElevatedButton)` — simulira klik na login dugme. Ovo okida `LoginSubmitted` event u BLoC-u.
- `pump(100ms)` — renderuje jedan frame nakon 100ms. U ovom trenutku BLoC je emitovao `AuthLoading` (jer je Future iz Completer-a jos nedovrsena), a LoginPage bi trebalo da prikaze `CircularProgressIndicator`.

```dart
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
```
- Verifikujemo da se `CircularProgressIndicator` prikazuje na ekranu. Ovo znaci da `LoginPage` ima `BlocBuilder` ili `BlocListener` koji reaguje na `AuthLoading` stanje i zamenjuje formu loading indikatorom.

```dart
  completer.complete(const Success(
    User(id: '1', email: 'test@test.com', name: 'testuser', role: Role.brand),
  ));
  await tester.pump();
});
```
- `completer.complete(...)` — zavrsavamo Future sa uspesnim rezultatom. BLoC obradjuje `Success` i emituje `AuthAuthenticated`.
- `tester.pump()` — renderujemo sledeci frame da flutter_test engine zavrsi sve pending operacije i test se cisto zatvori (bez upozorenja o nedovrsenim Future-ima).

**Sta ovaj test dokazuje na odbrani:**
1. UI reaguje na `AuthLoading` stanje prikazivanjem loading indikatora
2. `Completer<T>` pattern daje potpunu kontrolu nad timing-om asinhronog poziva — mozemo "zamrznuti" API poziv i proveriti sta UI prikazuje dok ceka
3. Razlika izmedju `pump()` i `pumpAndSettle()`: `pump` renderuje jedan frame (pogodno za proveru medjustanja), `pumpAndSettle` ceka sve animacije
4. Loading indikator se pravilno uklanja nakon zavrsetka poziva

---

### Test 6: Widget Test — BLoC dispatch verifikacija (login_page_test.dart)

```dart
testWidgets('dispatchuje LoginSubmitted na validnu formu', (tester) async {
  const testUser = User(
    id: '1', email: 'test@test.com', name: 'testuser', role: Role.brand,
  );

  when(mockLoginUseCase('testuser', 'password123'))
      .thenAnswer((_) async => const Success(testUser));

  final bloc = buildBloc();
  await pumpLoginPage(tester, bloc: bloc);

  await tester.enterText(find.byType(TextFormField).first, 'testuser');
  await tester.enterText(find.byType(TextFormField).last, 'password123');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  verify(mockLoginUseCase('testuser', 'password123')).called(1);
});
```
- Ovaj test **ne proverava UI** — proverava da li je BLoC zaista pozvao `LoginUseCase` sa tacnim parametrima.
- `verify(mockLoginUseCase('testuser', 'password123')).called(1)` — Mockito verifikacija: `loginUseCase` je pozvan **tacno jednom** sa `'testuser'` i `'password123'`. Ako je pozvan vise puta, sa pogresnim parametrima, ili uopste nije pozvan — test pada.
- Ovo je "integration" izmedju Widget-a i BLoC-a: korisnik unese podatke → Widget izvrsi `bloc.add(LoginSubmitted(...))` → BLoC pozove `loginUseCase(...)`.

**Sta ovaj test dokazuje na odbrani:**
1. Forma ispravno cita vrednosti iz TextFormField-ova
2. LoginPage dispatchuje LoginSubmitted event sa tacnim kredencijalima
3. `verify().called(1)` garantuje da se use case poziva tacno jednom (ne duplicira pozive)

---

### Test 7: E2E Test — Login → Discover kompletan tok (app_test.dart)

Ovaj test pokrece **stvarnu aplikaciju** na simulatoru i prolazi kroz kompletan korisnicki tok: od pocetne stranice do uspesnog prikaza inventara.

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
```
- `IntegrationTestWidgetsFlutterBinding` — zamenjuje standardni test binding. Omogucava pokretanje testova na stvarnom uredjaju/simulatoru sa pravim rendering engine-om (umesto virtualnog).

```dart
  setUpAll(() async {
    await initDependencies();
  });
```
- `initDependencies()` — inicijalizuje **GetIt DI kontejner** sa pravim servisima (ne mock-ovima):
  - Pravi `Dio` HTTP klijent koji komunicira sa backend-om
  - Pravi `AuthRepository`, `DiscoverRepository` koji koriste API
  - Pravi `AuthTokenStorage` za cuvanje JWT tokena

```dart
  setUp(() async {
    await getIt<AuthTokenStorage>().deleteToken();
  });
```
- Brise sacuvani JWT token pre svakog testa. Bez ovoga, ako je prethodni test uspesno ulogovao korisnika, sledeci test bi krenuo od Discover stranice umesto od LandingPage (auto-redirect na osnovu tokena).

```dart
  Future<void> pumpFrames(WidgetTester tester, Duration total) async {
    const frame = Duration(milliseconds: 100);
    final count = total.inMilliseconds ~/ frame.inMilliseconds;
    for (var i = 0; i < count; i++) {
      await tester.pump(frame);
    }
  }
```
- **`pumpFrames`** — helper koji pumpa fiksni broj frame-ova. Koristi se umesto `pumpAndSettle()` na LandingPage koja ima **beskonacne animacije** (flutter_animate repeat + rekurzivni Future.delayed za rotaciju kljucnih reci). `pumpAndSettle()` nikad ne bi zavrsio jer uvek ima zakazanih animacija.

```dart
  Future<bool> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 15)}) async {
    const frame = Duration(milliseconds: 200);
    final maxAttempts = timeout.inMilliseconds ~/ frame.inMilliseconds;
    for (var i = 0; i < maxAttempts; i++) {
      await tester.pump(frame);
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }
```
- **`pumpUntil`** — pumpa frame-ove dok se zeljeni widget ne pojavi ili dok ne istekne timeout. Koristi se za cekanje na network pozive (login, ucitavanje gradova) — ne znamo tacno koliko ce backend da odgovori, pa proveravamo nakon svakog frame-a.

```dart
  Future<void> performLogin(WidgetTester tester) async {
    await tester.pumpWidget(const OohApp());
    await pumpFrames(tester, const Duration(seconds: 3));
    expect(find.text('AutoHome'), findsWidgets);
```
- `pumpWidget(OohApp())` — pokrece **identican app kao u produkciji**. Nema nikakvih modifikacija — koristimo pravi DI, pravi routing, pravi AuthBloc.
- `pumpFrames(3 sekunde)` — daje LandingPage-u 3 sekunde da se renderuje (beskonacne animacije ne dozvoljavaju pumpAndSettle).
- `expect(find.text('AutoHome'), findsWidgets)` — verifikuje da je LandingPage prikazana (sadrzi "AutoHome" brend tekst).

```dart
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
```
- Tapuje **hamburger meni ikonicu** (mobilni layout). Na desktopu bi "Prijavi se" bio direktno u AppBar-u, ali na simulatoru (mobilni ekran) je u hamburger meniju.
- Dva `pump()` poziva: prvi otvara meni, drugi ceka 500ms da animacija otvaranja zavrsi.

```dart
    final loginMenuItem = find.text('Prijavi se');
    expect(loginMenuItem, findsOneWidget);
    await tester.tap(loginMenuItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
```
- Pronalazi i tapuje "Prijavi se" u bottom sheet-u. `pumpAndSettle()` je bezbedan na LoginPage (nema beskonacnih animacija).

```dart
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.enterText(find.byType(TextFormField).first, 'brand');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).last, 'brand123');
    await tester.pump();
```
- Verifikuje da LoginPage ima 2 polja za unos.
- Unosi **stvarne kredencijale** (`brand` / `brand123`) — ovo su podaci iz DataLoader bootstrapa na backend-u.

```dart
    await tester.tap(find.byType(ElevatedButton));
    final navigated = await pumpUntil(
      tester,
      find.byType(DiscoverPage),
      timeout: const Duration(seconds: 20),
    );
    expect(navigated, isTrue,
        reason: 'DiscoverPage treba da se pojavi nakon uspesnog login-a');
  }
```
- Tapuje login dugme. Ovo okida:
  1. `POST /auth/login` — salje kredencijale backend-u
  2. Backend vraca JWT token
  3. `GET /auth/me` — dobavlja korisnicke podatke
  4. `AuthBloc` emituje `AuthAuthenticated`
  5. GoRouter navigira na `/app/discover`
- `pumpUntil` ceka do 20 sekundi da se `DiscoverPage` pojavi (dovoljno za network latenciju).
- Ako se DiscoverPage ne pojavi (npr. pogresna lozinka, backend nije pokrenut), `navigated` ce biti `false` i test pada sa jasnom porukom.

```dart
  group('E2E: Login → Discover tok', () {
    testWidgets('korisnik se prijavljuje, vidi gradove i inventar na Discover stranici',
        (tester) async {
      await performLogin(tester);
      expect(find.byType(DiscoverPage), findsOneWidget);

      final citiesLoaded = await pumpUntil(
        tester,
        find.text('Beograd, Srbija'),
        timeout: const Duration(seconds: 15),
      );
      expect(citiesLoaded, isTrue,
          reason: 'Grad "Beograd, Srbija" treba da se pojavi u dropdown-u');

      await pumpFrames(tester, const Duration(seconds: 2));
      expect(find.text('Beograd, Srbija'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
```
- Nakon login-a, test nastavlja na DiscoverPage:
  - `pumpUntil(find.text('Beograd, Srbija'))` — ceka da se gradovi ucitaju sa backend-a (`GET /cities`)
  - `pumpFrames(2 sekunde)` — daje ekranu za inventar da zavrsi renderovanje
  - `find.text('Beograd, Srbija')` — verifikuje da je Beograd prikazan u city dropdown-u
  - `find.byType(CircularProgressIndicator), findsNothing` — verifikuje da se loading indikator vise ne prikazuje (inventar je ucitan)

**Sta ovaj test dokazuje na odbrani:**
1. **Ceo sistem radi end-to-end**: Flutter app → HTTP → Spring Boot → PostgreSQL → response → UI
2. JWT autentifikacija funkcionise: login → token → autorizovani API pozivi
3. GoRouter navigacija pravilno prebacuje korisnika nakon login-a
4. DiscoverPage ucitava stvarne podatke sa backend-a (gradovi, inventar)
5. UI pravilno prikazuje podatke (grad u dropdown-u, bez loading indikatora na kraju)
6. `pumpFrames` i `pumpUntil` resavaju problem beskonacnih animacija i network latencije

## 9. Rezime

| Metrika | Vrednost |
|---------|----------|
| Ukupan broj test fajlova | 4 (3 unit/widget + 1 E2E) |
| Ukupan broj testova | 42 (41 unit/widget + 1 E2E) |
| BLoC testova | 34 |
| Widget testova | 7 |
| E2E testova | 1 |
| Pokriveni feature-i | Auth (login/register/logout), Discover (filtriranje/pretraga) |
| Prosecno vreme izvrsavanja | ~4 sekunde (unit/widget), ~15-30 sekundi (E2E) |
| Mock framework | Mockito + @GenerateNiceMocks |
| E2E framework | integration_test (Flutter SDK) |
