# Pregled Implementacije - OOH Platforma

## 1. Backend (Spring Boot + PostgreSQL)

### 1.1 Infrastruktura i Sigurnost

- **JWT Autentifikacija** — Stateless autentifikacija. Server generiše JWT token pri login/register, klijent ga šalje u `Authorization: Bearer <token>` header-u. `JwtAuthenticationFilter` presreće svaki zahtev i validira token.
- **Role-based pristup** — 4 sistemske uloge: `INTERNAL_ADMIN`, `MEDIA_OWNER`, `BRAND`, `AGENCY`. Svaka ruta ima definisana pravila pristupa u `SecurityConfig`.
- **CORS konfiguracija** — Eksplicitno podešen za frontend origin (`http://localhost:5173`) sa podrškom za `Authorization` header.
- **Globalni error handler** — `GlobalExceptionHandler` hvata sve izuzetke i vraća strukturirane JSON odgovore (404, 400, 500).
- **Bootstrap (DataLoader)** — Automatsko kreiranje korisnika (`admin`, `brand_user`, `owner_user`) i šifarnika pri pokretanju. Opcioni Excel import inventara na start.
- **Swagger UI** — Dokumentacija API-ja dostupna na `/swagger-ui.html`.

### 1.2 Moduli

#### Auth Modul
- `POST /auth/register` — Registracija (vraća JWT)
- `POST /auth/login` — Prijava (vraća JWT)
- `GET /auth/me` — Trenutni korisnik na osnovu tokena

#### Dictionary (Šifarnici)
- Tabele: `Country`, `City`, `UnitType`, `MediaFormat`, `VenueType`
- Admin CRUD: `GET/POST /admin/config/{type}`
- Koriste se za filtere, dropdown menije i standardizaciju podataka

#### Inventory (Inventar)
- `InventoryItem` — centralna tabela sa lokacijom, cenom, tipom, formatom, dimenzijama
- Privatan inventar (Media Owner): `GET /inventory/my`, `POST/PUT/DELETE /inventory`
- Javna pretraga: `GET /public/units` sa filterima (grad, tip, format, cena)
- Excel import: `POST /admin/inventory/import-excel` (Apache POI, upsert po `vendorInventoryId`)

#### Inquiry (Upiti)
- Brand/Agency šalju upite: `POST /public/inquiries`
- Admin pregled: `GET /admin/inquiries`, update admin beleški, unos cena po stavci
- PDF generisanje (OpenPDF): automatski pri kreiranju, regeneriše se pri izmeni cena/beleški

#### Campaign (Kampanje)
- `Campaign` + `CampaignItem` (vezna tabela kampanja-inventar)
- CRUD: `POST/GET /campaigns`
- Status: ACTIVE, COMPLETED

#### Organization
- `Brand` — oglašivač
- `Agency` — agencija koja zastupa brendove (1:N veza)
- Agency CRUD brendova: `GET/POST /agency/brands`

#### Bootstrap Media Owner-i
- 2 unapred kreirana media owner naloga: **City Light** i **Grifon Media**
- Svaki ima svoj inventar uvežen iz Excel šema

---

## 2. Frontend (Flutter + BLoC)

### 2.1 Arhitektura

- **Clean Architecture** sa **Feature-First** organizacijom
- **BLoC pattern** za state management (flutter_bloc)
- **GoRouter** za navigaciju sa `StatefulShellRoute.indexedStack`
- **GetIt** za dependency injection
- **Responsive design**: mobile (< 900px) i desktop (>= 900px) layout

### 2.2 Core Infrastruktura

#### API Client
- Dio HTTP klijent sa JWT interceptor-om
- `ApiConfig` klasa sa svim endpoint konstantama
- Automatsko dodavanje `Authorization: Bearer <token>` header-a

#### Auth Flow
- Login: username + password → JWT token → `SharedPreferences` storage → `/auth/me` za user profil
- Register: username + email + password + role → JWT → auto-login
- `CheckAuth` pri pokretanju: proverava postojeći token iz storage-a
- Logout: briše token, redirect na login

#### Responsive Shell
- **Mobile**: Bottom NavigationBar (Dashboard, Discover, Profile) + Drawer sa role-specific linkovima
- **Desktop**: Collapsible sidebar (260px expanded / 72px collapsed) sa `AnimatedContainer` tranzicijom
- `ShellCubit` za upravljanje sidebar stanjem

#### Lokalizacija (i18n)
- 2 jezika: Srpski (default) i English
- ~100 ključeva u ARB fajlovima
- `LocaleCubit` sa `SharedPreferences` persistencijom
- Language toggle u app bar-u, drawer-u i sidebar-u

### 2.3 Feature Moduli

#### Landing Page (`/`)
- Hero sekcija sa animiranim ključnim rečima i pretragom
- CategoriesSection, NewlyAddedSection, AdvancedAnalyticsSection
- TestimonialsSection, NewsInsightsSection, CTASection, Footer
- Responsive: stacked (mobile) vs. multi-column (desktop)

#### Discover (`/discover`, `/app/discover`)
- Javna pretraga inventara sa filterima (grad, tip, format, cena)
- Desktop: 3-kolonski grid + mapa (flutter_map + OpenStreetMap)
- Mobile: DraggableScrollableSheet sa mapom u pozadini
- Detalj stranica: `/discover/:id`

#### Dashboard (`/app/dashboard`)
- Role-based prikaz sa CTA dugmadima:
  - Brand: Upiti, Kampanje
  - Agency: Brendovi, Upiti, Kampanje
  - Media Owner: Inventar, Dodaj inventar
  - Admin: Upiti, Konfiguracija

#### Inquiry (`/app/inquiries`)
- Lista upita sa role-based endpoint-om (brand/agency/admin)
- Detalj upita: `/app/inquiries/:id`
- BLoC: `LoadInquiries`, `LoadInquiryDetail`

#### Inventory Management (`/app/my-inventory`)
- Lista inventara vlasnika medija
- Kreiranje: `/app/inventory/create`
- Editovanje: `/app/inventory/:id/edit`
- BLoC: `LoadMyInventory`, `CreateInventory`, `UpdateInventory`

#### Campaign (`/app/campaigns`)
- Lista kampanja sa status badge-ovima (draft, active, completed, cancelled)
- Forma za kreiranje: `/app/campaigns/create`
- Agency-only polje: `brandUsername`
- BLoC: `LoadCampaigns`, `CreateCampaign`

#### Admin Config (`/app/admin/config`)
- 5-tab interfejs: Countries, Cities, UnitTypes, MediaFormats, VenueTypes
- Lista stavki + FAB za dodavanje novih
- Cities tab: dropdown za izbor države
- BLoC: `LoadConfigTab`, `CreateConfigItem`

#### Agency Brands (`/app/agency/brands`)
- Lista brendova agencije
- Kreiranje novih brendova (ime)
- BLoC: `LoadBrands`, `CreateBrand`

### 2.4 Design System

- **Boje**: Indigo primary (#6366F1), Gray skala za tekst i bordere
- **Tipografija**: Space Grotesk (Google Fonts), skala od 72px do 12px
- **Spacing**: 8pt grid sistem (4, 8, 16, 24, 32, 48, 64, 96)
- **Breakpoints**: 600px (mobile), 900px (tablet), 1200px (desktop), 1536px (large desktop)
- **Komponente**: AppButton, AppTextField, MainAppBar, AppSnackbar

### 2.5 DI Registracije

Svi servisi i repozitorijumi su registrovani u `di.dart` kao lazy singleton-i:
- **Auth**: TokenStorage, RemoteDataSource, LocalDataSource, Repository, 4 UseCases
- **Discover**: ConfigApiService, InventoryApiService, DiscoverRepository
- **Inquiry**: ApiService, Repository
- **InventoryManagement**: ApiService, Repository
- **Campaign**: ApiService, Repository
- **AdminConfig**: ApiService, Repository
- **Agency**: ApiService, Repository

`MultiRepositoryProvider` u `app.dart` pruža repozitorijume widget stablu.

---

## 3. Routing Mapa

| Tip | Putanja | Stranica | Pristup |
|-----|---------|----------|---------|
| Javna | `/` | Landing | Svi |
| Javna | `/discover` | Pretraga | Svi |
| Javna | `/discover/:id` | Detalj | Svi |
| Auth | `/auth/login` | Prijava | Neulogovani |
| Auth | `/auth/register` | Registracija | Neulogovani |
| Shell | `/app/dashboard` | Dashboard | Ulogovani |
| Shell | `/app/discover` | Discover | Ulogovani |
| Shell | `/app/profile` | Profil | Ulogovani |
| Role | `/app/inquiries` | Lista upita | brand, agency, admin |
| Role | `/app/inquiries/:id` | Detalj upita | brand, agency, admin |
| Role | `/app/my-inventory` | Moj inventar | mediaOwner |
| Role | `/app/inventory/create` | Novi inventar | mediaOwner |
| Role | `/app/inventory/:id/edit` | Izmena inventara | mediaOwner |
| Role | `/app/campaigns` | Kampanje | brand, agency |
| Role | `/app/campaigns/create` | Nova kampanja | brand, agency |
| Role | `/app/admin/config` | Konfiguracija | admin |
| Role | `/app/agency/brands` | Brendovi | agency |

---

## 4. Tok Korisnickog Iskustva (po ulozi)

### Media Owner
1. Login sa username/password
2. Dashboard: „Moj inventar" i „Dodaj inventar" CTA
3. Pregled svog inventara (`GET /inventory/my`)
4. Kreiranje/editovanje inventara
5. Kreirana stavka se pojavljuje u javnoj pretrazi

### Brand
1. Login/Registracija
2. Dashboard: „Moji upiti" i „Kampanje" CTA
3. Pretraga inventara na Discover stranici
4. Slanje upita za odabrane inventare
5. Pregled statusa upita
6. Kreiranje kampanja

### Agency
1. Login/Registracija
2. Dashboard: brendovi, upiti, kampanje
3. Upravljanje brendovima koji pripadaju agenciji
4. Slanje upita u ime brendova
5. Kreiranje kampanja sa izborom brenda

### Admin
1. Login sa admin nalogom
2. Dashboard: svi upiti i konfiguracija
3. Upravljanje šifarnicima (5 tabova)
4. Pregled svih upita, admin beleške, pricing
5. PDF generisanje za ponude

---

## 5. Tehnologije

| Komponenta | Tehnologija |
|-----------|-------------|
| Backend | Java 17, Spring Boot 3.x |
| Baza podataka | PostgreSQL |
| Autentifikacija | JWT (stateless) |
| PDF | OpenPDF |
| Excel import | Apache POI |
| Frontend framework | Flutter (Dart) |
| State management | flutter_bloc (BLoC pattern) |
| Navigacija | GoRouter |
| DI | GetIt |
| HTTP klijent | Dio |
| Mapa | flutter_map + OpenStreetMap |
| Font | Space Grotesk (Google Fonts) |
| Lokalizacija | Flutter l10n (ARB fajlovi) |
| Lokalni storage | SharedPreferences |

---

## 6. Struktura Projekata

### Backend (`ooh-backend/`)
```
src/main/java/com/ooh/
├── config/          # Security, CORS, Swagger, JWT
├── bootstrap/       # DataLoader (inicijalni podaci)
├── exception/       # Global error handler
├── auth/            # Login, Register, JWT servis
├── dictionary/      # Šifarnici (City, UnitType, MediaFormat, VenueType)
├── inventory/       # InventoryItem CRUD + Excel import
├── inquiry/         # Upiti + admin pricing + PDF
├── campaign/        # Kampanje + stavke
├── organization/    # Brand, Agency
└── media_owner/     # Availability, Images (stubs)
```

### Frontend (`ooh_mobile/`)
```
lib/
├── app/             # App, DI, Router
├── core/
│   ├── config/      # ApiClient, ApiConfig
│   ├── l10n/        # Lokalizacija + LocaleCubit
│   ├── responsive/  # Breakpoints, ResponsiveBuilder
│   ├── theme/       # Boje, Tipografija, Spacing
│   └── widgets/     # AppButton, AppTextField, MainAppBar
└── features/
    ├── admin/       # Admin konfiguracija
    ├── agency/      # Brendovi agencije
    ├── auth/        # JWT autentikacija
    ├── campaign/    # Kampanje
    ├── dashboard/   # Role-based dashboard
    ├── discover/    # Javna pretraga + mapa
    ├── inquiry/     # Upiti
    ├── inventory_management/  # Inventar (media owner)
    ├── landing/     # Landing stranica
    ├── profile/     # Korisnicki profil
    └── shell/       # Responsive navigacija
```

---

## 7. Testiranje

Projekat ima tri nivoa testiranja rasporedjena na backend i frontend.

### 7.1 Backend Testovi (JUnit 5 + Mockito + AssertJ)

**17 unit testova** u 3 test klase, bez pokretanja Spring konteksta (cisti Mockito mock-ovi).

| Test klasa | Broj testova | Pokriveni servisi |
|-----------|-------------|-------------------|
| `AuthenticationServiceTest` | 4 | Registracija, prijava, JWT generisanje |
| `InventoryServiceTest` | 6 | CRUD operacije za inventar |
| `InventoryFilterServiceTest` | 7 | JPA Specification filtriranje (grad, cena, keyword, status) |

**Kljucne tehnike:**
- `@ExtendWith(MockitoExtension.class)` — Mockito bez Spring-a
- `ArgumentCaptor<Specification<T>>` — hvatanje dinamickih JPA upita
- Arrange-Act-Assert pattern za sve testove

**Pokretanje:**
```bash
cd ooh-backend && ./gradlew test
```

### 7.2 Frontend Unit i Widget Testovi (bloc_test + mockito + flutter_test)

**29 testova** u 3 test fajla:

| Test fajl | Tip | Broj testova | Opis |
|-----------|-----|-------------|------|
| `auth_bloc_test.dart` | BLoC | 6 | Login, register, logout, provera sesije |
| `discover_bloc_test.dart` | BLoC | 16 | Gradovi, inventar, filteri, resetovanje |
| `login_page_test.dart` | Widget | 7 | UI rendering, validacija forme, BLoC interakcija |

**Kljucne tehnike:**
- `@GenerateNiceMocks` + `build_runner` za generisanje mock klasa
- `blocTest<Bloc, State>()` za deklarativno testiranje state tranzicija
- `provideDummy<Result<T>>()` za Mockito kompatibilnost sa sealed klasama
- `GoRouter` test setup za widget testove koji koriste navigaciju
- `Completer<T>` pattern za simulaciju async loading stanja

**Pokretanje:**
```bash
cd ooh_mobile && flutter test test/features/
```

### 7.3 Integration (E2E) Testovi (integration_test)

**1 E2E test** koji pokrece stvarnu aplikaciju sa stvarnim backend-om:

| Test | Opis |
|------|------|
| Login → Discover tok | Pokrece app → navigira na login → unosi kredencijale → verifikuje Discover stranicu → ucitavanje gradova (Beograd) → prikaz inventara |

**Razlika od unit testova:** E2E testovi ne koriste mock-ove — rade sa pravim backend API-jem, pravom bazom i pravim network pozivima. Koriste `IntegrationTestWidgetsFlutterBinding` iz Flutter SDK-a.

**Preduslovi:** Backend pokrenut na localhost:8080, korisnik `brand`/`brand123` u bazi.

**Pokretanje:**
```bash
cd ooh_mobile && flutter test integration_test/ -d <device_id>
```

### 7.4 Sumarni pregled testiranja

| Metrika | Backend | Frontend | E2E | Ukupno |
|---------|---------|----------|-----|--------|
| Broj testova | 17 | 29 | 1 | **47** |
| Test fajlova | 3 | 3 | 1 | **7** |
| Framework | JUnit 5 + Mockito | bloc_test + flutter_test | integration_test | — |
| Tip | Unit | Unit + Widget | Integration | — |
| Backend potreban | Ne | Ne | Da | — |
| Vreme izvrsavanja | ~2-3s | ~4s | ~15-30s | — |

**Detaljnija dokumentacija:**
- Backend: `ooh-backend/docs/sr/11_TESTIRANJE.md`
- Frontend: `ooh_mobile/docs/TESTING.md`
