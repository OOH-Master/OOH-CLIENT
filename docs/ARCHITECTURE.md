# 🏗️ OOH Mobile - Arhitektura

## Pregled

OOH Mobile je Flutter aplikacija za Out-of-Home advertising platformu. Koristi **Clean Architecture** sa **Feature-First** organizacijom.

---

## 📁 Struktura Projekta

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp konfiguracija
│   ├── di.dart                  # Dependency Injection (GetIt)
│   └── router.dart              # GoRouter navigacija
├── core/
│   ├── config/
│   │   └── api_client.dart      # Dio HTTP klijent
│   ├── l10n/
│   │   ├── l10n.dart            # Export AppLocalizations
│   │   ├── app_en.arb           # Engleski prevodi
│   │   └── app_sr.arb           # Srpski prevodi (DEFAULT)
│   ├── responsive/
│   │   ├── breakpoints.dart     # mobile < 768 < tablet < 1024 < desktop
│   │   └── responsive_builder.dart
│   ├── theme/
│   │   ├── app_colors.dart      # Boje (Primary: #6366F1)
│   │   ├── app_typography.dart  # Space Grotesk font
│   │   ├── app_constants.dart   # Spacing, radius
│   │   └── app_theme.dart       # Light tema
│   └── widgets/
│       ├── main_app_bar.dart    # Glavni AppBar za sve stranice
│       ├── app_button.dart      # PrimaryButton, SecondaryButton
│       └── app_text_field.dart  # Stilizovana input polja
└── features/
    ├── auth/                    # Autentikacija
    ├── discover/                # Pretraga inventara
    ├── landing/                 # Landing stranica
    ├── map/                     # Mapa (coming soon)
    ├── profile/                 # Korisnički profil
    └── shell/                   # Navigation shell
```

---

## 🎯 Features (Moduli)

### 1. Landing (`/features/landing/`)

**Putanja:** `/`

Javna landing stranica sa sekcijama:
- `HeroSection` - Animirana hero sa pretragom
- `CategoriesSection` - Tipovi medija
- `NewlyAddedSection` - Novi inventari
- `CTASection` - Call-to-action
- `AppFooter` - Footer

**Koristi:** `AppHeader` (poseban header samo za landing)

---

### 2. Auth (`/features/auth/`)

**Putanje:** `/auth/login`, `/auth/register`

**Fajlovi:**
```
auth/
├── data/
│   ├── models/user_model.dart
│   └── repositories/auth_repository.dart
├── domain/
│   └── entities/user.dart       # User sa UserRole enum
└── presentation/
    ├── blocs/auth_bloc.dart     # AuthBloc state management
    └── pages/
        ├── login_page.dart
        └── register_page.dart
```

**AuthBloc Events:**
- `LoginRequested(email, password)`
- `RegisterRequested(name, email, password, role)`
- `LogoutRequested()`

**AuthBloc States:**
- `AuthInitial`
- `AuthLoading`
- `AuthAuthenticated(user)`
- `AuthUnauthenticated`
- `AuthFailure(error)`

**UserRole enum:** `advertiser`, `owner`, `agency`, `admin`

---

### 3. Discover (`/features/discover/`)

**Putanje:** `/discover`, `/discover/:id`

**Ovo je GLAVNI modul aplikacije.**

**Fajlovi:**
```
discover/
├── data/
│   ├── datasources/ooh_remote_datasource.dart
│   └── repositories/ooh_repository.dart
├── domain/
│   └── entities/
│       ├── city.dart            # City(id, name, country, lat, lng)
│       └── ooh_unit.dart        # OohUnit sa priceDisplay getter
└── presentation/
    ├── blocs/discover_bloc.dart
    ├── pages/
    │   ├── discover_page.dart        # Lista + Mapa
    │   └── discover_detail_page.dart # Detalji jedinice
    └── widgets/
        ├── inventory_card.dart
        └── inventory_map.dart
```

**OohUnit Entity:**
```dart
class OohUnit {
  final String id;
  final String name;
  final OohType type;        // billboard, digital, subway, airport, bus, other
  final String address;
  final String cityId, cityName;
  final double latitude, longitude;
  final double price;
  final String currency;     // USD, EUR, RSD, GBP
  final CycleType cycleType; // oneDay, oneWeek, twoWeek, fourWeek, oneMonth
  final OohStatus status;    // available, booked, maintenance
  final List<String> images;
  
  // Formatirana cena: "RSD 150,000/month"
  String get priceDisplay => ...
}
```

**DiscoverBloc Events:**
- `LoadCities()`
- `SelectCity(city)`
- `LoadInventoryUnits(cityId)`

**DiscoverBloc States:**
- `DiscoverLoaded(cities, selectedCity, units, isLoadingUnits)`

**Desktop Layout:**
- Leva strana: 3-kolonski grid (720px)
- Desna strana: Mapa (flutter_map + OpenStreetMap)

**Mobile Layout:**
- Pozadina: Mapa
- DraggableScrollableSheet sa listom inventara
- Snap positions: 15%, 40%, 85%

---

### 4. Shell (`/features/shell/`)

**Putanja:** `/shell/*`

Navigation shell za autentikovane korisnike sa:
- Bottom navigation (Discover, Map, Profile)
- Drawer menu
- AppBar sa naslovom

---

## 🔧 Dependency Injection

**Lokacija:** `lib/app/di.dart`

**GetIt registracije:**
```dart
// Singletons
sl.registerLazySingleton<Dio>(() => createDioClient());
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
sl.registerLazySingleton<OohRepository>(() => OohRepositoryImpl(sl()));

// Factories (Blocs)
sl.registerFactory(() => AuthBloc(sl()));
sl.registerFactory(() => DiscoverBloc(sl()));
```

**Korišćenje:**
```dart
// U widgetu
BlocProvider(create: (_) => sl<AuthBloc>())

// Direktno
final repo = sl<OohRepository>();
```

---

## 🚦 Routing (GoRouter)

**Lokacija:** `lib/app/router.dart`

**Javne rute:**
| Path | Page | Opis |
|------|------|------|
| `/` | LandingPage | Marketing landing |
| `/discover` | DiscoverPage | Pretraga inventara |
| `/discover/:id` | DiscoverDetailPage | Detalji jedinice |
| `/auth/login` | LoginPage | Prijava |
| `/auth/register` | RegisterPage | Registracija |

**Zaštićene rute (StatefulShellRoute):**
| Path | Page |
|------|------|
| `/shell/discover` | DiscoverPage |
| `/shell/map` | MapPage |
| `/shell/profile` | ProfilePage |

---

## 🌍 Lokalizacija (l10n)

**Lokacija:** `lib/core/l10n/`

**Konfiguracija:** `l10n.yaml`
```yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

**Default jezik:** Srpski (`sr`)

**Korišćenje:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.loginButton)  // "Prijavi se"
Text(l10n.results(57))  // "57 rezultata"
```

**Ključevi (~90):**
- UI tekstovi (dugmad, labele, placeholderi)
- Validacione poruke
- Status indikatori (available, booked)
- Hero sekcija tekstovi

---

## 🗺️ Mapa

**Paket:** `flutter_map` + `latlong2`

**Lokacija:** `lib/features/discover/presentation/widgets/inventory_map.dart`

**Tile provider:** OpenStreetMap

**Funkcionalnosti:**
- Cluster markeri za grupisanje
- Highlight selektovanog markera
- Tap na marker → selektuje karticu
- Default centar: Beograd (44.8176, 20.4633)

---

## 🎨 Tema

**Lokacija:** `lib/core/theme/`

### Boje (`app_colors.dart`)
| Ime | Hex | Upotreba |
|-----|-----|----------|
| primary | #6366F1 | Dugmad, linkovi |
| background | #FFFFFF | Pozadina |
| foreground | #111827 | Tekst |
| border | #E5E7EB | Ivice |
| success | #22C55E | Dostupno |
| warning | #F59E0B | Rezervisano |

### Tipografija (`app_typography.dart`)
- **Font:** Space Grotesk (Google Fonts)
- **Display:** 72px → **Body:** 14px → **Caption:** 12px

### Spacing (`app_constants.dart`)
```dart
xs: 4    sm: 8    md: 16    lg: 24    xl: 32    2xl: 48
```

---

## 📱 Responsive Design

**Breakpoints:**
```dart
static const double mobile = 0;
static const double tablet = 768;
static const double desktop = 1024;
```

**Provera:**
```dart
final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;

// Ili sa ResponsiveBuilder
ResponsiveBuilder(
  builder: (context, deviceType) {
    if (deviceType == DeviceType.mobile) return MobileWidget();
    return DesktopWidget();
  },
)
```

---

## 🔌 API Integracija

**Base URL:** `http://localhost:8080/api` (development)

**Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/public/config/cities` | Lista gradova |
| GET | `/public/units?cityId=X` | Inventari po gradu |
| GET | `/public/units/:id` | Detalji jedinice |
| POST | `/auth/login` | Prijava |
| POST | `/auth/register` | Registracija |

**Error handling:**
- Dio interceptor loguje sve requestove
- Repository vraća `Either<Failure, T>` ili baca exception
- Bloc hvata i emituje `FailureState`

---

## 📦 Glavne Zavisnosti

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.9
  equatable: ^2.0.7
  
  # DI
  get_it: ^8.0.3
  
  # Routing
  go_router: ^17.0.0
  
  # HTTP
  dio: ^5.4.0
  
  # UI
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  
  # Maps
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  
  # Utils
  intl: ^0.19.0
```

---

## ✅ TODO / Naredni Koraci

### Prioritet 1 (Sledeći sprint)
- [ ] Implementirati pravu autentikaciju sa JWT
- [ ] Dodati "Add to Proposal" funkcionalnost
- [ ] Booking flow (kalendar, datumi)
- [ ] User dashboard sa mojim bookingima

### Prioritet 2
- [ ] Offline mode (Hive/SQLite cache)
- [ ] Push notifikacije
- [ ] Dark tema
- [ ] Više jezika (nemački, engleski UK)

### Prioritet 3
- [ ] Admin panel u aplikaciji
- [ ] Analytics/statistika
- [ ] Export u PDF/Excel
- [ ] Social sharing

### Tehnički dug
- [ ] Unit testovi za Bloc-ove
- [ ] Widget testovi za ključne komponente
- [ ] Integration testovi
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Error tracking (Sentry/Crashlytics)

---

## 🐛 Poznati Problemi

1. **CORS na webu** - Backend mora imati CORS enabled za localhost
2. **Mapa tile loading** - Ponekad sporo učitavanje OSM tile-ova
3. **Hot reload l10n** - Potreban hot restart za nove ključeve

---

## 💡 Konvencije

### Imenovanje fajlova
- `snake_case.dart` za sve fajlove
- `_page.dart` sufiks za stranice
- `_bloc.dart` sufiks za bloc-ove
- `_widget.dart` ili bez sufiksa za widgete

### Struktura feature-a
```
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/
```

### Commit poruke
```
feat: Nova funkcionalnost
fix: Ispravka buga
refactor: Refaktorisanje koda
style: Stilske izmene (UI)
docs: Dokumentacija
chore: Maintenance
```

---

## 🚀 Build & Deploy

```bash
# Web
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Analiza veličine
flutter build web --analyze-size
```

---

## 📞 Kontakt

- **Backend repo:** OOH-API
- **Web app repo:** OOH-WEB-APP
- **Figma dizajn:** [Link]
