# 🏗️ OOH Mobile - Arhitektura

## Pregled

OOH Mobile je Flutter aplikacija za Out-of-Home advertising platformu. Koristi **Clean Architecture** sa **Feature-First** organizacijom.

---

## 🦋 Flutter Cross-Platform

### Kako Flutter funkcioniše

Flutter je Google-ov UI framework koji omogućava pisanje jednog koda koji radi na **Web-u**, **Android-u**, **iOS-u**, **macOS-u**, **Windows-u** i **Linux-u**.

#### Arhitektura Flutter-a

```
┌─────────────────────────────────────────────────────────┐
│                    DART KOD (naš kod)                    │
│         UI Widgets, Business Logic, State               │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   FLUTTER FRAMEWORK                      │
│     Widgets, Rendering, Animation, Gestures             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER ENGINE                        │
│          Skia (rendering), Dart VM, Platform Channels   │
└─────────────────────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
         ┌────────┐  ┌──────────┐  ┌────────┐
         │  WEB   │  │ ANDROID  │  │  iOS   │
         │ Canvas │  │   NDK    │  │  Metal │
         └────────┘  └──────────┘  └────────┘
```

#### Web Build

Kada pokrenemo `flutter build web`, Flutter:
1. **Kompajlira Dart u JavaScript** - koristi dart2js ili dart2wasm
2. **Renderuje na HTML Canvas** - Skia crta direktno na canvas element
3. **Generiše:** `build/web/` folder sa `index.html`, `main.dart.js`, assets

```bash
flutter build web --release
# Rezultat: build/web/ (deploy na bilo koji web server)
```

#### Android Native Build

Kada pokrenemo `flutter build apk`, Flutter:
1. **Kompajlira Dart u native ARM kod** (AOT - Ahead of Time)
2. **Pakuje Flutter Engine** (C++ Skia renderer)
3. **Generiše:** APK/AAB sa native bibliotekama

```bash
flutter build apk --release
# Rezultat: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS Native Build

Slično Android-u, Flutter kompajlira u native ARM kod, koristi Metal API za rendering.

#### Prednosti ovog pristupa

| Aspekt | Opis |
|--------|------|
| **Jedan codebase** | Isti Dart kod za sve platforme |
| **Native performanse** | AOT kompilacija, ne koristi bridge kao React Native |
| **Konzistentan UI** | Isti pixel-perfect izgled na svim platformama |
| **Hot Reload** | Instant promene tokom razvoja |

#### Naš projekat

```bash
# Development
flutter run -d chrome          # Web (localhost:8080)
flutter run -d android         # Android emulator/device
flutter run -d ios             # iOS simulator/device

# Production
flutter build web --release    # Web deploy
flutter build apk --release    # Android APK
flutter build appbundle        # Google Play (AAB)
flutter build ios --release    # iOS App Store
```

---

## 📁 Struktura Projekta

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp + MultiRepositoryProvider + MultiBlocProvider
│   ├── di.dart                  # Dependency Injection (GetIt)
│   └── router.dart              # GoRouter navigacija
├── core/
│   ├── config/
│   │   ├── api_client.dart      # Dio HTTP klijent sa JWT interceptor-om
│   │   └── api_config.dart      # API endpoint konstante
│   ├── l10n/
│   │   ├── l10n.dart            # Export AppLocalizations
│   │   ├── app_en.arb           # Engleski prevodi
│   │   └── app_sr.arb           # Srpski prevodi (DEFAULT)
│   ├── responsive/
│   │   ├── breakpoints.dart     # mobile < 600 < tablet < 900 < desktop < 1200
│   │   └── responsive_builder.dart  # ResponsiveBuilder + context.isDesktop
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
    ├── admin/                   # Admin konfiguracija (šifarnici)
    ├── agency/                  # Agencija - upravljanje brendovima
    ├── auth/                    # Autentikacija (JWT)
    ├── campaign/                # Kampanje
    ├── dashboard/               # Role-based dashboard
    ├── discover/                # Javna pretraga inventara
    ├── inquiry/                 # Upiti (brand/agency/admin)
    ├── inventory_management/    # Upravljanje inventarom (media owner)
    ├── landing/                 # Landing stranica
    ├── profile/                 # Korisnički profil
    └── shell/                   # Navigation shell (responsive sidebar/bottom nav)
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
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart        # Interface
│   │   ├── auth_remote_datasource_impl.dart   # JWT login/register/me
│   │   ├── auth_local_datasource.dart         # SharedPreferences cache
│   │   └── auth_token_storage.dart            # SharedPreferences JWT storage
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart              # User entitet
│   │   └── role.dart              # Role enum
│   ├── repositories/
│   │   └── auth_repository.dart   # Interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── get_current_user_usecase.dart
│       └── logout_usecase.dart
└── presentation/
    ├── blocs/auth_bloc.dart       # AuthBloc state management
    └── pages/
        ├── login_page.dart
        └── register_page.dart
```

**JWT Autentikacija:**
- Login/Register vraćaju JWT token
- Token se čuva u `SharedPreferences` putem `AuthTokenStorage`
- `ApiClient` (Dio) automatski dodaje `Authorization: Bearer <token>` header
- `CheckAuthRequested` event pri pokretanju aplikacije poziva `/auth/me` za proveru sesije
- Pri odjavi token se briše i korisnik se redirect-uje na login

**AuthBloc Events:**
- `LoginRequested(email, password)`
- `RegisterRequested(name, email, password, role)`
- `CheckAuthRequested()` — proverava postojeći token pri pokretanju
- `LogoutRequested()`

**AuthBloc States:**
- `AuthInitial`
- `AuthLoading`
- `AuthAuthenticated(user)` — sadrži `User` sa `role` poljem
- `AuthUnauthenticated`
- `AuthFailure(error)`

**Role enum:** `brand`, `mediaOwner`, `agency`, `admin`

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

Navigation shell za autentikovane korisnike. Koristi `StatefulShellRoute.indexedStack` sa 3 grane.

**Responsive ponašanje:**

**Mobile (< 900px):**
- `Scaffold` sa `bottomNavigationBar` (Dashboard, Discover, Profile)
- `Drawer` sa role-specific linkovima (upiti, inventar, kampanje, admin config, brendovi)
- Logout dugme u drawer-u

**Desktop (>= 900px):**
- Nema bottom navigation bar-a
- Collapsible sidebar levo (260px expanded / 72px collapsed)
- `AnimatedContainer` za smooth tranziciju (200ms)
- User avatar + ime u header-u sidebar-a
- Main nav items (Dashboard, Discover, Profile) sa ikonama
- Role-specific linkovi ispod razdjelnika
- Toggle dugme (chevron) za kolaps/ekspanziju
- `Tooltip` na ikonama kada je sidebar sklopljen

**State management:**
```dart
class ShellState {
  final int index;           // Aktivna grana (0-2)
  final bool sidebarExpanded; // Desktop sidebar stanje
}
class ShellCubit extends Cubit<ShellState> {
  void setIndex(int index);
  void toggleSidebar();
}
```

---

### 5. Dashboard (`/features/dashboard/`)

**Putanja:** `/app/dashboard`

Role-based dashboard koji prikazuje različit sadržaj u zavisnosti od korisničke uloge:

| Rola | Prikaz |
|------|--------|
| `brand` | Moji upiti, Kampanje |
| `agency` | Moji brendovi, Upiti, Kampanje |
| `mediaOwner` | Moj inventar, Upiti |
| `admin` | Svi upiti, Konfiguracija |

Svaki dashboard ima CTA dugmad koja vode na odgovarajuće stranice (npr. "Pogledaj upite" → `/app/inquiries`).

---

### 6. Inquiry (`/features/inquiry/`)

**Putanje:** `/app/inquiries`, `/app/inquiries/:id`

**Fajlovi:**
```
inquiry/
├── data/
│   ├── api/inquiry_api_service.dart
│   ├── dto/inquiry_dto.dart
│   └── repository/inquiry_repository.dart
└── presentation/
    ├── blocs/inquiry_bloc.dart
    └── pages/
        ├── inquiry_list_page.dart
        └── inquiry_detail_page.dart
```

**InquiryBloc Events/States:**
- `LoadInquiries` → `InquiriesLoaded(inquiries)`
- `LoadInquiryDetail(id)` → `InquiryDetailLoaded(inquiry)`
- Error/Loading state-ovi

**API:** Koristi role-based endpoint (`/brand/inquiries`, `/agency/inquiries`, ili `/admin/inquiries`) u zavisnosti od korisničke uloge.

---

### 7. Inventory Management (`/features/inventory_management/`)

**Putanje:** `/app/my-inventory`, `/app/inventory/create`, `/app/inventory/:id/edit`

**Fajlovi:**
```
inventory_management/
├── data/
│   ├── api/inventory_management_api_service.dart
│   ├── dto/inventory_item_dto.dart
│   └── repository/inventory_management_repository.dart
└── presentation/
    ├── blocs/inventory_management_bloc.dart
    └── pages/
        ├── my_inventory_page.dart      # Lista inventara vlasnika
        └── inventory_form_page.dart    # Kreiranje/editovanje
```

**Dostupno za:** `mediaOwner`, `admin`

---

### 8. Campaign (`/features/campaign/`)

**Putanje:** `/app/campaigns`, `/app/campaigns/create`

**Fajlovi:**
```
campaign/
├── data/
│   ├── api/campaign_api_service.dart
│   ├── dto/campaign_dto.dart          # CampaignDto + CampaignStatus enum
│   └── repository/campaign_repository.dart
└── presentation/
    ├── blocs/campaign_bloc.dart
    └── pages/
        ├── campaign_list_page.dart     # Lista sa status badge-ovima
        └── campaign_form_page.dart     # Forma za kreiranje
```

**CampaignStatus:** `draft`, `active`, `completed`, `cancelled`

**CampaignBloc Events:**
- `LoadCampaigns` → `CampaignsLoaded(campaigns)`
- `CreateCampaign(name, description, startDate, endDate, budget, brandUsername?)`

**Dostupno za:** `brand`, `agency`

---

### 9. Admin Config (`/features/admin/`)

**Putanja:** `/app/admin/config`

**Fajlovi:**
```
admin/
├── data/
│   ├── api/admin_config_api_service.dart
│   └── repository/admin_config_repository.dart
└── presentation/
    ├── blocs/admin_config_bloc.dart
    └── pages/admin_config_page.dart
```

Stranica sa 5 tabova za upravljanje šifarnicima:
1. **Countries** (Države)
2. **Cities** (Gradovi) — sa dropdown-om za izbor države
3. **Unit Types** (Tipovi jedinica)
4. **Media Formats** (Formati medija)
5. **Venue Types** (Tipovi lokacija)

Svaki tab prikazuje listu stavki + FAB za dodavanje novih.

**Dostupno za:** `admin`

---

### 10. Agency Brands (`/features/agency/`)

**Putanja:** `/app/agency/brands`

**Fajlovi:**
```
agency/
├── data/
│   ├── api/agency_api_service.dart
│   └── repository/agency_repository.dart
└── presentation/
    ├── blocs/agency_bloc.dart
    └── pages/agency_brands_page.dart
```

Lista brendova agencije sa mogućnošću kreiranja novih. Svaki brend prikazuje CircleAvatar sa inicijalima, ime i #id.

**AgencyBloc Events:**
- `LoadBrands` → `BrandsLoaded(brands)`
- `CreateBrand(name)` → `BrandCreateSuccess`

**Dostupno za:** `agency`

---

## 🔧 Dependency Injection

**Lokacija:** `lib/app/di.dart`

**GetIt registracije:**
```dart
// Core
Logger, ApiClient, SharedPreferences

// Auth Feature
AuthTokenStorage
AuthRemoteDataSource → AuthRemoteDataSourceImpl(ApiClient, AuthTokenStorage)
AuthLocalDataSource → AuthLocalDataSourceImpl(SharedPreferences)
AuthRepository → AuthRepositoryImpl(remote, local, tokenStorage, apiClient)
LoginUseCase, RegisterUseCase, GetCurrentUserUseCase, LogoutUseCase

// Discover Feature
ConfigApiService(ApiClient), InventoryApiService(ApiClient)
DiscoverRepository → DiscoverRepositoryImpl(configApi, inventoryApi)

// Inquiry Feature
InquiryApiService(ApiClient)
InquiryRepository(InquiryApiService)

// Inventory Management Feature
InventoryManagementApiService(ApiClient)
InventoryManagementRepository(InventoryManagementApiService)

// Campaign Feature
CampaignApiService(ApiClient)
CampaignRepository(CampaignApiService)

// Admin Config Feature
AdminConfigApiService(ApiClient)
AdminConfigRepository(AdminConfigApiService)

// Agency Feature
AgencyApiService(ApiClient)
AgencyRepository(AgencyApiService)
```

**MultiRepositoryProvider** u `app.dart` pruža repozitorijume widget stablu:
```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: getIt<InquiryRepository>()),
    RepositoryProvider.value(value: getIt<InventoryManagementRepository>()),
    RepositoryProvider.value(value: getIt<CampaignRepository>()),
    RepositoryProvider.value(value: getIt<AdminConfigRepository>()),
    RepositoryProvider.value(value: getIt<AgencyRepository>()),
  ],
  child: MultiBlocProvider(...)
)
```

**Korišćenje:**
```dart
// U widgetu (BLoC kreiranje)
BlocProvider(create: (_) => InquiryBloc(context.read<InquiryRepository>()))

// Direktno (van widget stabla)
final repo = getIt<CampaignRepository>();
```

---

## 🚦 Routing (GoRouter)

**Lokacija:** `lib/app/router.dart`

**Javne rute (bez autentikacije):**
| Path | Page | Opis |
|------|------|------|
| `/` | LandingPage | Marketing landing |
| `/discover` | DiscoverPage | Javna pretraga inventara |
| `/discover/:id` | DiscoverDetailPage | Detalji jedinice |
| `/auth/login` | LoginPage | Prijava |
| `/auth/register` | RegisterPage | Registracija |

**Shell rute (StatefulShellRoute.indexedStack — 3 grane):**
| Branch | Path | Page |
|--------|------|------|
| 0 | `/app/dashboard` | DashboardPage |
| 1 | `/app/discover` | DiscoverPage |
| 2 | `/app/profile` | ProfilePage |

**Role-specific rute (push over shell):**
| Path | Page | Rola |
|------|------|------|
| `/app/inquiries` | InquiryListPage | brand, agency, admin |
| `/app/inquiries/:id` | InquiryDetailPage | brand, agency, admin |
| `/app/my-inventory` | MyInventoryPage | mediaOwner |
| `/app/inventory/create` | InventoryFormPage | mediaOwner |
| `/app/inventory/:id/edit` | InventoryFormPage | mediaOwner |
| `/app/campaigns` | CampaignListPage | brand, agency |
| `/app/campaigns/create` | CampaignFormPage | brand, agency |
| `/app/admin/config` | AdminConfigPage | admin |
| `/app/agency/brands` | AgencyBrandsPage | agency |

**Redirect logika:**
- Public rute (`/`, `/discover/*`, `/auth/*`) → slobodan pristup
- `/app/*` rute → zahtevaju autentikaciju, redirect na `/auth/login` ako nije ulogovan
- Ako je ulogovan i pristupa `/auth/*` ili `/` → redirect na `/app/dashboard`

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

**Breakpoints** (`lib/core/responsive/breakpoints.dart`):
```dart
static const double mobile = 600;       // 0-599px
static const double tablet = 900;       // 600-899px
static const double desktop = 1200;     // 900-1199px
static const double largeDesktop = 1536; // 1200px+
```

**Provera:**
```dart
// Extension metode
final isDesktop = context.isDesktop;     // >= 900px (tablet threshold)
final isMobile = context.isMobile;       // < 600px

// DeviceType enum
DeviceType.fromWidth(width)  // mobile, tablet, desktop, largeDesktop

// ResponsiveBuilder widget
ResponsiveBuilder(
  builder: (context, deviceType) {
    if (deviceType == DeviceType.mobile) return MobileWidget();
    return DesktopWidget();
  },
)
```

**Ključna responsive ponašanja:**
- **Shell navigacija:** Bottom nav (mobile) vs. Collapsible sidebar (desktop)
- **Discover page:** DraggableSheet + mapa (mobile) vs. Grid + mapa side-by-side (desktop)
- **Landing page:** Stacked layout (mobile) vs. Multi-column (desktop)

---

## 🔌 API Integracija

**Base URL:** `http://localhost:8080/api/v1` (konfigurisano preko `ApiConfig`)

**Konfiguracija:** `lib/core/config/api_config.dart` — sve endpoint konstante na jednom mestu.

**Public Endpoints (bez autentikacije):**
| Method | Path | Opis |
|--------|------|------|
| GET | `/public/units` | Pretraga inventara (sa filterima) |
| GET | `/public/units/:id` | Detalji jedinice |
| GET | `/public/dictionaries/cities` | Lista gradova |
| GET | `/public/dictionaries/countries` | Lista država |
| GET | `/public/dictionaries/unit-types` | Tipovi jedinica |
| GET | `/public/dictionaries/media-formats` | Formati medija |
| GET | `/public/dictionaries/venue-types` | Tipovi lokacija |

**Auth Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| POST | `/auth/login` | Prijava (vraća JWT) |
| POST | `/auth/register` | Registracija (vraća JWT) |
| GET | `/auth/me` | Trenutni korisnik |

**Brand Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/brand/inquiries` | Lista upita brenda |
| GET | `/brand/inquiries/:id` | Detalj upita |

**Agency Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/agency/inquiries` | Lista upita agencije |
| GET | `/agency/inquiries/:id` | Detalj upita |
| GET | `/agency/brands` | Lista brendova |
| POST | `/agency/brands` | Kreiranje brenda |

**Campaign Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/campaigns` | Lista kampanja |
| GET | `/campaigns/:id` | Detalj kampanje |
| POST | `/campaigns` | Kreiranje kampanje |

**Inventory Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/inventory/my` | Moj inventar (media owner) |
| GET | `/inventory/:id` | Detalj inventara |
| POST | `/inventory` | Kreiranje inventara |
| PUT | `/inventory/:id` | Izmena inventara |
| DELETE | `/inventory/:id` | Brisanje inventara |

**Admin Endpoints:**
| Method | Path | Opis |
|--------|------|------|
| GET | `/admin/inquiries` | Svi upiti |
| GET | `/admin/inquiries/:id` | Detalj upita |
| GET/POST | `/admin/config/countries` | Države |
| GET/POST | `/admin/config/cities` | Gradovi |
| GET/POST | `/admin/config/unit-types` | Tipovi jedinica |
| GET/POST | `/admin/config/media-formats` | Formati medija |
| GET/POST | `/admin/config/venue-types` | Tipovi lokacija |

**Error handling:**
- `ApiClient` (Dio) sa JWT interceptor-om za automatsko dodavanje tokena
- Repository baca exception koje BLoC hvata i emituje `ErrorState`
- 401 odgovor → redirect na login

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
- [ ] Dodati "Add to Proposal" funkcionalnost
- [ ] Booking flow (kalendar, datumi)
- [ ] Editovanje kampanja i detalj stranica
- [ ] Editovanje/brisanje admin config stavki

### Prioritet 2
- [ ] Offline mode (Hive/SQLite cache)
- [ ] Push notifikacije
- [ ] Dark tema
- [ ] Više jezika (nemački, engleski UK)
- [ ] Upload slika za inventar

### Prioritet 3
- [ ] Analytics/statistika dashboards
- [ ] Export u PDF/Excel
- [ ] Social sharing

### Tehnički dug
- [ ] Unit testovi za Bloc-ove
- [ ] Widget testovi za ključne komponente
- [ ] Integration testovi
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Error tracking (Sentry/Crashlytics)
- [ ] Zameniti `withOpacity` sa `withValues` (deprecation)

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
