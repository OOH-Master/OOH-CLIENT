# OOH Mobile

Flutter cross-platform app (web, Android, iOS) for the OOH advertising platform.

## Tech Stack

- Flutter 3.x, Dart 3.6+ (`sdk: ">=3.6.0 <4.0.0"`)
- State management: flutter_bloc 9.x (BLoC pattern), equatable 2.x
- Routing: go_router 17.x (StatefulShellRoute)
- DI: get_it 9.x (manual registration in `app/di.dart`)
- HTTP: dio 5.x (custom ApiClient wrapper with QueuedInterceptorsWrapper)
- Maps: flutter_map 7.x + latlong2 + flutter_map_marker_cluster + geolocator
- Forms: reactive_forms 18.x
- Localization: flutter_localizations (Serbian default, English) -- ~223 keys in ARB files
- Storage: flutter_secure_storage 10.x (JWT tokens), shared_preferences 2.x (locale, user cache)
- Charts: fl_chart 0.69.x (analytics dashboards)
- UI: google_fonts 8.x, flutter_animate 4.x, flutter_svg 2.x, cached_network_image 3.x, shimmer 3.x
- Images: image_picker 1.x, file_picker 10.x
- Utilities: logger 2.x, intl 0.20.x, url_launcher 6.x, connectivity_plus 7.x, package_info_plus 9.x

## Project Structure

```
lib/
├── main.dart               Entry point -> initDependencies() -> runApp(OohApp())
├── app/
│   ├── app.dart            MaterialApp.router + MultiBlocProvider + MultiRepositoryProvider
│   ├── di.dart             GetIt dependency registration (12 features)
│   └── router.dart         GoRouter with auth redirect + StatefulShellRoute
├── core/
│   ├── config/
│   │   ├── api_client.dart       Dio wrapper with QueuedInterceptorsWrapper (refresh token, LogoutCallback)
│   │   └── api_config.dart       API endpoint constants (40+ constants)
│   ├── constants/
│   │   └── asset_paths.dart      Asset path constants
│   ├── l10n/
│   │   ├── app_en.arb            English translations (~223 keys)
│   │   ├── app_sr.arb            Serbian translations (~131 keys)
│   │   ├── l10n.dart             Export AppLocalizations
│   │   ├── locale_cubit.dart     LocaleCubit (language toggle with SharedPreferences persistence)
│   │   ├── app_localizations.dart         Generated
│   │   ├── app_localizations_en.dart      Generated
│   │   └── app_localizations_sr.dart      Generated
│   ├── responsive/
│   │   ├── breakpoints.dart      Breakpoints, DeviceType enum, ResponsiveValue<T>
│   │   ├── responsive_builder.dart  ResponsiveBuilder, ResponsiveLayout, context extensions
│   │   └── responsive.dart       Barrel export
│   ├── theme/
│   │   ├── app_colors.dart       AppColors (#6366F1 primary), AppColorsDark
│   │   ├── app_typography.dart   Space Grotesk (Google Fonts)
│   │   ├── app_constants.dart    AppSpacing, AppRadius, AppElevation, AppDuration, AppCurves
│   │   ├── spacing.dart          Spacing constants (xs=8, sm=12, md=16, lg=24, xl=32, xxl=48, xxxl=64)
│   │   └── app_theme.dart        Light + dark theme definitions
│   ├── utils/
│   │   ├── failures.dart         Failure class
│   │   ├── result.dart           Result<T> sealed class (Success/Error)
│   │   └── validation_error_parser.dart  Parses backend validation error responses
│   └── widgets/
│       ├── app_button.dart       AppButton (primary/secondary/tertiary variants)
│       ├── app_text_field.dart   AppTextField with validation support
│       ├── app_scaffold.dart     AppScaffold wrapper
│       ├── app_shell.dart        AppShell layout
│       ├── app_snackbar.dart     AppSnackbar (success/error/info/warning)
│       ├── main_app_bar.dart     MainAppBar with NotificationBell, locale toggle
│       └── auth_guard_dialog.dart  Login prompt dialog for unauthenticated users
└── features/
    ├── admin/              Dictionary management (5-tab CRUD) + user management (AdminUsersPage, UserEditDialog)
    ├── agency/             Agency brand management
    ├── auth/               Login/Register/ForgotPassword/ResetPassword/EmailVerification -- full Clean Architecture
    ├── availability/       Availability management (media owner) -- full data/presentation layers
    ├── campaign/           Campaign CRUD + detail + edit + status transitions
    ├── dashboard/          Role-based dashboard with analytics (fl_chart KPI, pipeline, trends)
    ├── discover/           Main feature: inventory search with map + filters + detail (redesigned)
    ├── inquiry/            Inquiry CRUD + admin management + quotes + offer review + dual flows
    ├── inventory_management/  Media owner inventory CRUD + image upload + map picker + bulk actions
    ├── landing/            Public marketing landing page
    ├── notification/       Notification bell (AppBar badge) + notifications page
    ├── profile/            User profile with edit mode + change password
    └── shell/              Navigation shell (responsive sidebar/bottom nav)
```

## Feature Structure Convention

```
feature_name/
├── data/
│   ├── api/            API service class (uses ApiClient)
│   ├── dto/            Data transfer objects (fromJson/toJson)
│   ├── repository/     Repository implementation
│   └── mapper/         DTO-to-entity mappers (optional, used in discover)
├── domain/             Only in auth feature (full Clean Architecture)
│   ├── entities/
│   ├── repositories/   Repository interface
│   └── usecases/
└── presentation/
    ├── blocs/          BLoC/Cubit classes
    ├── pages/          Full-screen pages (*_page.dart)
    └── widgets/        Feature-specific widgets
```

**Notes:**
- `auth` uses full Clean Architecture with domain layer (data/domain/presentation), with 4 use cases.
- `discover`, `inquiry`, and `campaign` have domain/entities but not full domain layers.
- Other features use simplified architecture (data + presentation only).
- Three features added in Phase 1/2: `availability`, `notification`, and expanded `profile` (with full data/api layers).

## API Client

- Configured in `core/config/api_client.dart` -- wraps Dio with two instances:
  - Main `_dio` with logging interceptor + `QueuedInterceptorsWrapper` for refresh token
  - Separate `_refreshDio` for refresh calls (avoids interceptor loops)
- **Refresh token interceptor**: on 401 response (excluding `/auth/` paths), automatically attempts token refresh, saves new tokens, then retries the original request. Accepts a `LogoutCallback` for when refresh fails.
- `AuthTokenStorage` uses `FlutterSecureStorage` for both access and refresh tokens (`saveToken`, `getToken`, `saveRefreshToken`, `getRefreshToken`, `clearAll`)
- Endpoints as constants in `core/config/api_config.dart` (40+ endpoint constants covering public, auth, profile, admin, inventory, brand, agency, media-owner, campaign, notification, and file endpoints)
- `ValidationErrorParser` utility for parsing backend validation error responses
- Token set via `apiClient.setAuthToken(token)` after login
- Base URL: `http://localhost:8080/api/v1` (override with `--dart-define=API_BASE_URL=...`)
- Timeouts: 30s connect/receive/send (sendTimeout disabled on web)

## DI Pattern

- All dependencies registered in `app/di.dart` using `getIt` as lazy singletons
- Per feature: ApiService -> Repository -> (UseCase if applicable)
- Repositories provided to widget tree via `MultiRepositoryProvider` in `app.dart`
- BLoCs created locally in pages: `BlocProvider(create: (_) => FeatureBloc(context.read<Repository>()))`
- Global BLoCs in `app.dart`: AuthBloc, DiscoverBloc, NotificationBloc, LocaleCubit
- `ApiClient.setLogoutCallback` wired to `AuthBloc` in `app.dart` for auto-logout on expired refresh tokens

**12 feature registrations in `di.dart`:**

| Feature | Registered Classes |
|---------|-------------------|
| Auth | AuthTokenStorage, AuthRemoteDataSource (impl), AuthLocalDataSource (impl), AuthRepository (impl), LoginUseCase, RegisterUseCase, GetCurrentUserUseCase, LogoutUseCase |
| Discover | ConfigApiService, InventoryApiService, DiscoverRepository (impl) |
| Inquiry | InquiryApiService, InquiryRepository |
| InventoryManagement | InventoryManagementApiService, InventoryManagementRepository |
| Campaign | CampaignApiService, CampaignRepository |
| AdminConfig | AdminConfigApiService, AdminConfigRepository |
| AdminUsers | AdminUserApiService, AdminUserRepository |
| Agency | AgencyApiService, AgencyRepository |
| Availability | AvailabilityApiService, AvailabilityRepository |
| Profile | ProfileApiService, ProfileRepository |
| Analytics | AnalyticsApiService, AnalyticsRepository |
| Notification | NotificationApiService, NotificationRepository |

## Routing

**Public routes (8):**

| Path | Page | Notes |
|------|------|-------|
| `/` | LandingPage | Marketing landing |
| `/discover` | DiscoverPage | Public inventory search |
| `/discover/:id` | DiscoverDetailPage | Unit detail |
| `/auth/login` | LoginPage | |
| `/auth/register` | RegisterPage | Multi-step (3 steps) |
| `/auth/forgot-password` | ForgotPasswordPage | |
| `/auth/reset-password` | ResetPasswordPage | Reads `?token=` query param |
| `/auth/verify-email` | EmailVerificationPage | Reads `?token=` query param |

**Shell routes (3 branches via StatefulShellRoute.indexedStack):**

| Branch | Path | Page |
|--------|------|------|
| 0 | `/app/dashboard` | DashboardPage |
| 1 | `/app/discover` | DiscoverPage (authenticated, with nested `/app/discover/:id`) |
| 2 | `/app/profile` | ProfilePage |

**Role-specific routes (17, pushed over shell):**

| Path | Page | Access |
|------|------|--------|
| `/app/inquiries` | InquiryListPage | brand, agency, admin |
| `/app/inquiries/create` | InquiryCreatePage | brand, agency (reads `?unitIds=` query param) |
| `/app/inquiries/:id` | InquiryDetailPage | brand, agency, admin |
| `/app/inquiries/:id/offer` | OfferReviewPage | brand, agency |
| `/app/my-inventory` | MyInventoryPage | mediaOwner |
| `/app/inventory/create` | InventoryFormPage | mediaOwner |
| `/app/inventory/:id/edit` | InventoryFormPage | mediaOwner |
| `/app/campaigns` | CampaignListPage | brand, agency |
| `/app/campaigns/create` | CampaignFormPage | brand, agency |
| `/app/campaigns/:id` | CampaignDetailPage | brand, agency |
| `/app/campaigns/:id/edit` | CampaignEditPage | brand, agency |
| `/app/admin/config` | AdminConfigPage | admin |
| `/app/admin/users` | AdminUsersPage | admin |
| `/app/admin/inquiries` | AdminInquiryManagementPage | admin |
| `/app/agency/brands` | AgencyBrandsPage | agency |
| `/app/media-owner/quotes` | MediaOwnerQuotesPage | mediaOwner |
| `/app/media-owner/availability` | AvailabilityManagementPage | mediaOwner |

**Shared route:**

| Path | Page | Access |
|------|------|--------|
| `/app/notifications` | NotificationsPage | all authenticated |

**Total: 28 routes** (8 public + 3 shell + 17 role-specific)

**Auth redirect logic:**
- Public routes (`/`, `/discover/*`, `/auth/*`) are freely accessible
- `/app/*` routes require `AuthAuthenticated` state, otherwise redirect to `/auth/login`
- If authenticated and accessing `/auth/*` or `/`, redirect to `/app/dashboard`
- GoRouter `refreshListenable` listens to AuthBloc stream for reactive redirects

## Design System

| Token | Value |
|-------|-------|
| Primary color | #6366F1 (Indigo) |
| Font | Space Grotesk (Google Fonts) |
| Spacing (Spacing class) | xs=8, sm=12, md=16, lg=24, xl=32, xxl=48, xxxl=64 |
| Spacing (AppSpacing class) | xxxs=2, xxs=4, xs=8, sm=12, md=16, lg=24, xl=32, xxl=48, xxxl=64, huge=96 |
| Radius (AppRadius) | xs=4, sm=8, md=16, lg=24, xl=24, xxl=32, xxxl=40, full=9999 |
| Elevation (AppElevation) | xs=1, sm=2, md=4, lg=8, xl=16 |
| Duration (AppDuration) | fast=150ms, normal=300ms, slow=500ms, slower=700ms |
| Mobile breakpoint | < 600px |
| Tablet breakpoint | 600-899px |
| Desktop breakpoint | 900-1199px |
| Large Desktop breakpoint | >= 1200px |

**Colors:** AppColors (light) + AppColorsDark (dark mode, defined but app uses `ThemeMode.light`).
Semantic colors: primary (#6366F1), destructive (#EF4444), success (#10B981), warning (#F59E0B), info (#3B82F6).

**Responsive helpers:**
- `context.isDesktop`, `context.isMobile`, `context.isTablet`
- `context.deviceType` returns `DeviceType` enum
- `ResponsiveBuilder` widget, `ResponsiveLayout` widget
- `ResponsiveValue<T>` for responsive value resolution
- `context.responsivePadding`, `context.maxContentWidth`

## BLoCs (12 BLoCs + 2 Cubits)

| BLoC/Cubit | Feature | Events | Purpose |
|------------|---------|--------|---------|
| AuthBloc | auth | AuthStarted, LoginSubmitted, RegisterSubmitted, LogoutRequested | Login, register (multi-step), logout, session check on startup |
| DiscoverBloc | discover | LoadCountries, SelectCountry, LoadCities, SelectCity, LoadInventoryUnits, LoadDictionaries, ApplyFilters, ResetFilters, RefreshRequested, ChangeViewMode, ChangeSort, LoadMore, ToggleUnitSelection, ClearSelection | Search/filter/sort inventory, pagination, view toggle, unit selection for inquiry |
| InquiryBloc | inquiry | LoadInquiries, LoadInquiryDetail, CreateInquiry, TransitionInquiryStatus, RequestQuotes, SendOffer, LoadMediaOwnerQuotes, SubmitQuote, DeclineQuote, UpdateQuoteItemPrice, LoadOffer, AcceptOffer, RejectOffer, UpdateAdminNotes, UpdateQuotedPrice | Full inquiry lifecycle: create (dual flow), list, detail, admin transitions, quotes, offers |
| InventoryManagementBloc | inventory_management | LoadMyInventory, CreateInventoryItem, UpdateInventoryItem, DeleteInventoryItem, SearchInventory, FilterByStatus, SortInventory, ToggleSelection, SelectAll, ClearSelection, BulkUpdateStatus | CRUD, search/filter/sort, bulk selection, bulk status update |
| CampaignBloc | campaign | LoadCampaigns, LoadCampaignDetail, CreateCampaign, UpdateCampaign, DeleteCampaign, ChangeStatus | CRUD, detail, edit, status transitions |
| AdminConfigBloc | admin | LoadConfigTab, CreateConfigItem, UpdateConfigItem, DeleteConfigItem | Dictionary management (5 types) with CRUD |
| AdminUserBloc | admin | LoadUsers, UpdateUser, DisableUser, EnableUser | User list with search/filter, edit, enable/disable |
| AgencyBloc | agency | LoadBrands, CreateBrand | Brand list and creation |
| ProfileBloc | profile | LoadProfile, UpdateProfile, ChangePassword | Profile view/edit, password change |
| AvailabilityBloc | availability | LoadSlots, CreateSlot, UpdateSlot, DeleteSlot | Availability slot management for media owners |
| AnalyticsBloc | dashboard | LoadAdminAnalytics, LoadMediaOwnerAnalytics, LoadBrandAnalytics, LoadAgencyAnalytics | Role-specific analytics data loading |
| NotificationBloc | notification | LoadNotifications, LoadUnreadCount, MarkRead, MarkAllRead | Notification list, unread badge count, mark as read |
| LocaleCubit | core/l10n | (Cubit, no events) | Language toggle (en/sr) with SharedPreferences persistence |
| ShellCubit | shell | (Cubit, no events) | Sidebar expanded/collapsed state, active branch index |

## Key Features

### Notifications
- `NotificationApiService` + `NotificationRepository` + `NotificationBloc` in `features/notification/`
- `NotificationBell` widget in MainAppBar shows unread badge count (red circle, hides at 0)
- `NotificationsPage` lists all notifications with `NotificationTile` widgets (icon by type, read/unread state, timestamp)
- `NotificationBloc` is global (created in `app.dart` MultiBlocProvider)
- Route: `/app/notifications`

### Analytics
- `AnalyticsApiService` + `AnalyticsRepository` + `AnalyticsBloc` in dashboard feature
- Admin dashboard: KPI cards + pipeline chart + trend line chart
- Role-specific analytics: admin, media owner, brand, agency (4 separate load events)
- Uses `fl_chart` package for chart rendering
- Dashboard widgets: `AdminDashboard`, `BrandDashboard`, `AgencyDashboard`, `MediaOwnerDashboard`, `BaseDashboard`, `StatCard`, `QuickActionCard`

### Image Upload
- `ImageUploadWidget` in `features/inventory_management/presentation/widgets/`
- Supports image picker (image_picker + file_picker), upload to backend, thumbnail preview grid, and delete
- Used in inventory create/edit forms (`InventoryFormPage`)

### Availability
- Full feature module at `features/availability/`
- `AvailabilityApiService` -> `AvailabilityRepository` -> `AvailabilityBloc`
- `AvailabilityManagementPage` for media owners -- slot-based CRUD (LoadSlots, CreateSlot, UpdateSlot, DeleteSlot)
- Route: `/app/media-owner/availability`

### Registration (Multi-Step)
- 3-step flow using `PageController` in `RegisterPage`:
  - Step 1: Role selection via `RoleSelectorCard` widgets (3 cards: Brand, Agency, Media Owner -- no Admin)
  - Step 2: Account details (first name, last name, email, username, password with strength indicator)
  - Step 3: Organization info (company name, phone, country, city)
- Step indicator built inline (not a separate widget)
- Submits via `RegisterSubmitted` event on AuthBloc

### Discovery (Redesigned)
- Grid/list/map view modes via `ViewToggle` + `ChangeViewMode` event (ViewMode enum: grid, list, mapOnly)
- `DiscoverCardGrid` (responsive grid) and `DiscoverCardList` (vertical list) layouts
- `SortDropdown` for sorting (priceAsc, priceDesc, newest)
- `ActiveFilterChips` showing removable filter chips with "clear all"
- `FilterBottomSheet` for advanced filtering (unitType, mediaFormat, venueType, environment, illumination, price range)
- Pagination with `LoadMore` event, `hasMore` flag, `currentPage` tracking
- Multi-select units for inquiry via `ToggleUnitSelection` / `ClearSelection`
- Inventory detail redesign: `ImageGallery` (carousel/lightbox), `Breadcrumb` navigation
- Desktop: 3-column grid + map (flutter_map + OpenStreetMap with marker clustering)
- Mobile: DraggableScrollableSheet over map background
- `InventoryCard` for card display, `InventoryMapCard` for map popup
- Animated zoom on country/city change

### Inquiry (Dual Flow)
- **Flow A (Inventory-Based):** user selects specific inventory items on Discover page, passes `unitIds` to `InquiryCreatePage`
- **Flow B (Campaign Brief):** user describes campaign needs (budget, dates, cities, media types) without selecting inventory
- Admin management page with filters (status, requesterType, search) and status transitions
- Media owner quotes page with editable prices per item, submit/decline actions
- Offer review page with accept/reject (with reason)

## How to Add a New Feature/Screen

1. Create `lib/features/{name}/`
2. `data/api/{name}_api_service.dart` -- uses ApiClient
3. `data/repository/{name}_repository.dart` -- wraps API service, returns `Result<T>`
4. `presentation/blocs/{name}_bloc.dart` -- Events, States, BLoC class
5. `presentation/pages/{name}_page.dart` -- UI with BlocProvider/BlocBuilder
6. Register in DI: add ApiService + Repository to `app/di.dart`
7. Add Repository to `MultiRepositoryProvider` in `app/app.dart`
8. Add route to `app/router.dart`
9. Add endpoint constants to `core/config/api_config.dart`
10. Add navigation link to shell sidebar/drawer if needed

## Testing

```bash
flutter test                              # All tests
flutter test test/features/auth/          # Feature-specific
flutter test integration_test/            # E2E (requires running backend)
```

Tests: 27 frontend unit/widget tests + 1 E2E test = 28 total

| Test File | Type | Count | Coverage |
|-----------|------|-------|----------|
| `auth_bloc_test.dart` | BLoC | 6 | Login, register, logout, session check |
| `discover_bloc_test.dart` | BLoC | 14 | Countries, cities, inventory, filters, cascade, reset, dictionaries |
| `login_page_test.dart` | Widget | 7 | UI rendering, validation, BLoC interaction |
| `app_test.dart` (integration) | E2E | 1 | Login -> Discover flow |

Tools: mockito 5.x, bloc_test 10.x, flutter_test

## Build Commands

```bash
flutter pub get                           # Install deps
flutter gen-l10n                          # Regenerate localizations (after ARB changes)
flutter run -d chrome                     # Run web (dev)
flutter build web --release               # Build web
flutter build apk --release               # Build Android
flutter build ios --release               # Build iOS
```

## Known Issues

- `withOpacity()` deprecation warnings -- should migrate to `withValues()` (already partially migrated in `InquiryStatusBadge`)
- CORS must be enabled on backend for web development (`CORS_ALLOWED_ORIGINS` env var)
- Hot reload does not pick up new l10n keys (requires hot restart after ARB changes)
- App ID is `com.example.ooh_mobile` -- must change for production
- Many pages use hardcoded Serbian strings (should migrate to ARB localization files)
- English ARB has more keys (~223) than Serbian ARB (~131) -- Serbian translations are incomplete
- Dark theme is defined (`AppColorsDark`, `AppTheme.darkTheme`) but app is locked to `ThemeMode.light`
- `discover/data/models/` and `campaign/domain/entities/` directories exist but are empty
