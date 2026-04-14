# OOH Mobile - Architecture

## Overview

OOH Mobile is a Flutter application for the Out-of-Home advertising platform. It uses a **Feature-First** organization with **BLoC pattern** for state management. The `auth` feature uses full Clean Architecture (data/domain/presentation), while other features use a simplified two-layer approach (data + presentation).

---

## Flutter Cross-Platform

Flutter compiles a single Dart codebase to Web (JavaScript via dart2js), Android (native ARM via AOT), and iOS (native ARM + Metal). The OOH Mobile app primarily targets **web** for the master's thesis, but the same code runs on mobile platforms.

```bash
# Development
flutter run -d chrome          # Web
flutter run -d android         # Android emulator/device
flutter run -d ios             # iOS simulator/device

# Production
flutter build web --release    # Web deploy
flutter build apk --release    # Android APK
flutter build ios --release    # iOS App Store
```

---

## Project Structure

```
lib/
├── main.dart                    # Entry point -> initDependencies() -> runApp(OohApp())
├── app/
│   ├── app.dart                 # MaterialApp.router + MultiBlocProvider + MultiRepositoryProvider
│   ├── di.dart                  # Dependency Injection (GetIt, 12 feature registrations)
│   └── router.dart              # GoRouter with auth redirect + StatefulShellRoute
├── core/
│   ├── config/
│   │   ├── api_client.dart      # Dio HTTP client with QueuedInterceptorsWrapper (refresh token, LogoutCallback)
│   │   └── api_config.dart      # API endpoint constants (40+)
│   ├── constants/
│   │   └── asset_paths.dart     # Asset path constants
│   ├── l10n/
│   │   ├── app_en.arb           # English translations (~223 keys)
│   │   ├── app_sr.arb           # Serbian translations (~131 keys)
│   │   ├── l10n.dart            # Export AppLocalizations
│   │   ├── locale_cubit.dart    # LocaleCubit (language toggle)
│   │   ├── app_localizations.dart         # Generated
│   │   ├── app_localizations_en.dart      # Generated
│   │   └── app_localizations_sr.dart      # Generated
│   ├── responsive/
│   │   ├── breakpoints.dart     # Breakpoints (600/900/1200/1536), DeviceType enum, ResponsiveValue<T>
│   │   ├── responsive_builder.dart  # ResponsiveBuilder, ResponsiveLayout, context extensions
│   │   └── responsive.dart      # Barrel export
│   ├── theme/
│   │   ├── app_colors.dart      # AppColors (Primary: #6366F1), AppColorsDark
│   │   ├── app_typography.dart  # Space Grotesk font
│   │   ├── app_constants.dart   # AppSpacing, AppRadius, AppElevation, AppDuration, AppCurves
│   │   ├── spacing.dart         # Spacing constants (xs=8 through xxxl=64)
│   │   └── app_theme.dart       # Light + dark theme definitions
│   ├── utils/
│   │   ├── failures.dart        # Failure class
│   │   ├── result.dart          # Result<T> sealed class (Success/Error)
│   │   └── validation_error_parser.dart  # Parse backend validation error responses
│   └── widgets/
│       ├── app_button.dart      # AppButton (primary/secondary/tertiary)
│       ├── app_text_field.dart  # AppTextField with validation
│       ├── app_scaffold.dart    # AppScaffold wrapper
│       ├── app_shell.dart       # AppShell layout
│       ├── app_snackbar.dart    # AppSnackbar (success/error/info/warning)
│       ├── main_app_bar.dart    # MainAppBar (NotificationBell, locale toggle, back button)
│       └── auth_guard_dialog.dart  # Login prompt dialog for unauthenticated users
└── features/
    ├── admin/                   # Admin config (dictionaries) + user management
    ├── agency/                  # Agency brand management
    ├── auth/                    # Authentication (JWT) + forgot/reset password + email verification
    ├── availability/            # Availability management (media owner)
    ├── campaign/                # Campaigns + detail + edit + status transitions
    ├── dashboard/               # Role-based dashboard + analytics (fl_chart)
    ├── discover/                # Public inventory search (redesigned: grid/list/map, filters, sort)
    ├── inquiry/                 # Inquiries + admin management + quotes + offer review + dual flow
    ├── inventory_management/    # Inventory CRUD + image upload + map picker + bulk actions
    ├── landing/                 # Public marketing landing page
    ├── notification/            # Notifications (bell badge + page)
    ├── profile/                 # User profile with edit mode + change password
    └── shell/                   # Navigation shell (responsive sidebar/bottom nav)
```

---

## Features (13 Modules)

### 1. Landing (`/features/landing/`)

**Route:** `/`

Public marketing landing page with sections:
- `AppHeader` -- navigation header (desktop horizontal, mobile hamburger)
- `HeroSection` -- animated rotating keywords, country/city search dropdowns
- `CategoriesSection` -- OOH category grid (4 categories)
- `NewlyAddedSection` -- horizontal carousel of media listings
- `AdvancedAnalyticsSection` -- two-column analytics feature showcase
- `ExpertAdviceSection` -- mobile app mockup with feature cards
- `TestimonialsSection` -- customer testimonial grid
- `NewsInsightsSection` -- blog articles + trending topics
- `CTASection` -- call-to-action
- `AppFooter` -- 4-column footer with links

**Files:**
```
landing/
└── presentation/
    ├── pages/landing_page.dart
    └── widgets/
        ├── app_header.dart
        ├── hero_section.dart
        ├── categories_section.dart
        ├── newly_added_section.dart
        ├── advanced_analytics_section.dart
        ├── expert_advice_section.dart
        ├── testimonials_section.dart
        ├── news_insights_section.dart
        ├── cta_section.dart
        └── app_footer.dart
```

---

### 2. Auth (`/features/auth/`)

**Routes:** `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`, `/auth/verify-email`

Full Clean Architecture with domain layer.

**Files:**
```
auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart        # Interface
│   │   ├── auth_remote_datasource_impl.dart   # JWT login/register/me + forgotPassword + resetPassword
│   │   ├── auth_local_datasource.dart         # SharedPreferences cache (interface + impl)
│   │   └── auth_token_storage.dart            # FlutterSecureStorage for JWT (access + refresh token)
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart              # User entity (id, username, email, role, firstName, lastName, phone, country, city, website, emailVerified)
│   │   └── role.dart              # Role enum (brand, mediaOwner, agency, admin)
│   ├── repositories/
│   │   └── auth_repository.dart   # Interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── get_current_user_usecase.dart
│       └── logout_usecase.dart
└── presentation/
    ├── blocs/auth_bloc.dart
    ├── pages/
    │   ├── login_page.dart
    │   ├── register_page.dart              # Multi-step: role cards -> account -> organization (3 steps via PageController)
    │   ├── forgot_password_page.dart
    │   ├── reset_password_page.dart        # Reads ?token= query param
    │   └── email_verification_page.dart    # Reads ?token= query param
    └── widgets/
        └── role_selector_card.dart         # Role card for registration step 1 (3 roles: Brand, Agency, Media Owner)
```

**AuthBloc Events:** `AuthStarted`, `LoginSubmitted(email, password)`, `RegisterSubmitted(name, email, password, role, ...)`, `LogoutRequested`

**AuthBloc States:** `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthFailure(message)`

---

### 3. Discover (`/features/discover/`)

**Routes:** `/discover`, `/discover/:id`, `/app/discover`, `/app/discover/:id`

Main feature of the application. Supports country/city cascading filters, grid/list/map views, sorting, pagination, and multi-select for inquiry creation.

**Files:**
```
discover/
├── data/
│   ├── api/
│   │   ├── api.dart                    # Barrel export
│   │   ├── config_api_service.dart     # Dictionary API calls
│   │   └── inventory_api_service.dart  # Inventory search + InventoryFilterParams class
│   ├── dto/
│   │   ├── dto.dart                    # Barrel export
│   │   ├── city_dto.dart
│   │   ├── country_dto.dart
│   │   ├── dictionary_ref_dto.dart
│   │   └── inventory_item_dto.dart
│   ├── mapper/
│   │   └── discover_mapper.dart        # DTO-to-entity mappers
│   └── repository/
│       └── discover_repository.dart    # Interface + implementation
├── domain/
│   └── entities/
│       ├── city.dart                   # City(id, name, country, lat, lng)
│       ├── country.dart                # Country(id, name)
│       └── ooh_unit.dart              # OohUnit with priceDisplay getter
└── presentation/
    ├── blocs/discover_bloc.dart        # ViewMode enum, SortOption enum, pagination state
    ├── pages/
    │   ├── discover_page.dart          # Main discover view (grid/list + map)
    │   └── discover_detail_page.dart   # Unit detail (ImageGallery, Breadcrumb, tabbed sections)
    └── widgets/
        ├── inventory_card.dart         # Card for grid/list display
        ├── inventory_map.dart          # flutter_map with marker clustering
        ├── inventory_map_card.dart     # Map popup card
        ├── filter_bottom_sheet.dart    # Advanced filter bottom sheet
        ├── discover_card_grid.dart     # Responsive grid layout
        ├── discover_card_list.dart     # Vertical list layout
        ├── view_toggle.dart            # Grid/list toggle button
        ├── sort_dropdown.dart          # Sort by price/name/date
        ├── active_filter_chips.dart    # Removable filter chips with "clear all"
        ├── image_gallery.dart          # Image carousel with lightbox (used in detail page)
        └── breadcrumb.dart             # Hierarchical breadcrumb navigation
```

**DiscoverBloc Events:** `LoadCountries`, `SelectCountry`, `LoadCities`, `SelectCity`, `LoadInventoryUnits`, `LoadDictionaries`, `ApplyFilters`, `ResetFilters`, `RefreshRequested`, `ChangeViewMode`, `ChangeSort`, `LoadMore`, `ToggleUnitSelection`, `ClearSelection`

**DiscoverBloc State (`DiscoverLoaded`):** countries, selectedCountry, cities, selectedCity, units, isLoadingUnits, unitTypes, mediaFormats, venueTypes, activeFilters, viewMode, sortOption, currentPage, hasMore, pageSize, selectedUnitsForInquiry

---

### 4. Shell (`/features/shell/`)

Navigation shell for authenticated users. Uses `StatefulShellRoute.indexedStack` with 3 branches (Dashboard, Discover, Profile).

**Files:**
```
shell/
└── presentation/
    ├── blocs/shell_cubit.dart     # ShellCubit (index, sidebarExpanded)
    └── pages/main_shell_page.dart # Responsive shell layout
```

**Mobile (< 900px):**
- Bottom NavigationBar (Dashboard, Discover, Profile)
- Drawer with role-specific links and logout button

**Desktop (>= 900px):**
- Collapsible sidebar (260px expanded / 72px collapsed) with `AnimatedContainer` transition (200ms)
- User avatar + name in sidebar header
- Main nav items + role-specific links below divider
- `NotificationBell` in AppBar with badge count
- Toggle chevron for collapse/expand
- `Tooltip` on icons when sidebar is collapsed

---

### 5. Dashboard (`/features/dashboard/`)

**Route:** `/app/dashboard`

**Files:**
```
dashboard/
├── data/
│   ├── api/analytics_api_service.dart
│   └── repository/analytics_repository.dart
└── presentation/
    ├── blocs/analytics_bloc.dart
    ├── pages/dashboard_page.dart
    └── widgets/
        ├── admin_dashboard.dart        # KPI cards + pipeline chart + trend chart (fl_chart)
        ├── brand_dashboard.dart        # Inquiry/campaign stats + quick actions
        ├── agency_dashboard.dart       # Brand/inquiry/campaign stats + quick actions
        ├── media_owner_dashboard.dart  # Inventory stats (total + available)
        ├── base_dashboard.dart         # Shared dashboard layout
        ├── stat_card.dart              # Statistic card widget
        └── quick_action_card.dart      # CTA action card widget
```

**Role-based content:**

| Role | Stats (API) | Charts |
|------|-------------|--------|
| brand | Inquiry count, campaign count | -- |
| agency | Brand count, inquiry count, campaign count | -- |
| mediaOwner | Total inventory, active (AVAILABLE) count | -- |
| admin | KPI cards, pipeline, trends | fl_chart (pipeline bar chart, trend line chart) |

**AnalyticsBloc Events:** `LoadAdminAnalytics`, `LoadMediaOwnerAnalytics`, `LoadBrandAnalytics`, `LoadAgencyAnalytics`

---

### 6. Inquiry (`/features/inquiry/`)

**Routes:** `/app/inquiries`, `/app/inquiries/create`, `/app/inquiries/:id`, `/app/inquiries/:id/offer`, `/app/admin/inquiries`, `/app/media-owner/quotes`

**Files:**
```
inquiry/
├── data/
│   ├── api/inquiry_api_service.dart      # 14+ methods for full inquiry lifecycle
│   ├── dto/
│   │   ├── inquiry_dto.dart
│   │   └── inquiry_mapper.dart
│   └── repository/inquiry_repository.dart
├── domain/
│   └── entities/
│       └── inquiry.dart                  # Inquiry entity + InquiryStatus enum
└── presentation/
    ├── blocs/inquiry_bloc.dart           # 15 events covering full lifecycle
    ├── pages/
    │   ├── inquiry_list_page.dart
    │   ├── inquiry_create_page.dart       # Dual flow: inventory (Flow A) + brief (Flow B)
    │   ├── inquiry_detail_page.dart
    │   ├── admin_inquiry_management_page.dart  # Filters + status transitions
    │   ├── media_owner_quotes_page.dart        # Quote list, editable prices, submit/decline
    │   └── offer_review_page.dart              # Offer breakdown, accept/reject with reason
    └── widgets/
        ├── inquiry_card.dart
        └── inquiry_status_badge.dart      # Color-coded status badge
```

**InquiryBloc Events:** `LoadInquiries`, `LoadInquiryDetail`, `CreateInquiry`, `TransitionInquiryStatus`, `RequestQuotes`, `SendOffer`, `LoadMediaOwnerQuotes`, `SubmitQuote`, `DeclineQuote`, `UpdateQuoteItemPrice`, `LoadOffer`, `AcceptOffer`, `RejectOffer`, `UpdateAdminNotes`, `UpdateQuotedPrice`

---

### 7. Inventory Management (`/features/inventory_management/`)

**Routes:** `/app/my-inventory`, `/app/inventory/create`, `/app/inventory/:id/edit`

**Files:**
```
inventory_management/
├── data/
│   ├── api/inventory_management_api_service.dart
│   └── repository/inventory_management_repository.dart
└── presentation/
    ├── blocs/inventory_management_bloc.dart  # search/filter/sort/bulk/image events
    ├── pages/
    │   ├── my_inventory_page.dart      # Inventory list with filter bar + bulk actions
    │   └── inventory_form_page.dart    # Create/edit form with image upload + map picker
    └── widgets/
        ├── image_upload_widget.dart     # Image picker, upload, thumbnails, delete
        ├── inventory_filter_bar.dart    # Search/filter/sort controls
        ├── map_location_picker.dart     # Interactive flutter_map location picker
        └── bulk_action_toolbar.dart     # Bulk status change, select all/deselect
```

**InventoryManagementBloc Events:** `LoadMyInventory`, `CreateInventoryItem`, `UpdateInventoryItem`, `DeleteInventoryItem`, `SearchInventory`, `FilterByStatus`, `SortInventory`, `ToggleSelection`, `SelectAll`, `ClearSelection`, `BulkUpdateStatus`

---

### 8. Campaign (`/features/campaign/`)

**Routes:** `/app/campaigns`, `/app/campaigns/create`, `/app/campaigns/:id`, `/app/campaigns/:id/edit`

**Files:**
```
campaign/
├── data/
│   ├── api/campaign_api_service.dart
│   ├── dto/campaign_dto.dart          # CampaignDto + CampaignStatus enum
│   └── repository/campaign_repository.dart
├── domain/
│   └── entities/                      # (empty directory)
└── presentation/
    ├── blocs/campaign_bloc.dart
    ├── pages/
    │   ├── campaign_list_page.dart     # List with status badges + filter bar
    │   ├── campaign_form_page.dart     # Create form
    │   ├── campaign_detail_page.dart   # Detail view
    │   └── campaign_edit_page.dart     # Edit form
    └── widgets/
        └── campaign_status_badge.dart  # Color-coded status chip (draft/active/completed/cancelled)
```

**CampaignBloc Events:** `LoadCampaigns`, `LoadCampaignDetail`, `CreateCampaign`, `UpdateCampaign`, `DeleteCampaign`, `ChangeStatus`

---

### 9. Admin (`/features/admin/`)

**Routes:** `/app/admin/config`, `/app/admin/users`

**Files:**
```
admin/
├── data/
│   ├── api/
│   │   ├── admin_config_api_service.dart
│   │   └── admin_user_api_service.dart
│   └── repository/
│       ├── admin_config_repository.dart
│       └── admin_user_repository.dart
└── presentation/
    ├── blocs/
    │   ├── admin_config_bloc.dart      # CRUD for 5 dictionary types
    │   └── admin_user_bloc.dart        # User list/edit/disable/enable
    ├── pages/
    │   ├── admin_config_page.dart      # 5-tab interface with edit/delete dialogs
    │   └── admin_users_page.dart       # User list with search/filter
    └── widgets/
        └── user_edit_dialog.dart       # Dialog for editing user data
```

**Admin Config tabs:** Countries, Cities (with country dropdown), Unit Types, Media Formats, Venue Types

**AdminConfigBloc Events:** `LoadConfigTab`, `CreateConfigItem`, `UpdateConfigItem`, `DeleteConfigItem`

**AdminUserBloc Events:** `LoadUsers(role?, enabled?, search?)`, `UpdateUser`, `DisableUser`, `EnableUser`

---

### 10. Agency (`/features/agency/`)

**Route:** `/app/agency/brands`

**Files:**
```
agency/
├── data/
│   ├── api/agency_api_service.dart
│   └── repository/agency_repository.dart
└── presentation/
    ├── blocs/agency_bloc.dart
    └── pages/agency_brands_page.dart
```

**AgencyBloc Events:** `LoadBrands`, `CreateBrand(name)`

---

### 11. Availability (`/features/availability/`)

**Route:** `/app/media-owner/availability`

**Files:**
```
availability/
├── data/
│   ├── api/availability_api_service.dart
│   └── repository/availability_repository.dart
└── presentation/
    ├── blocs/availability_bloc.dart
    └── pages/availability_management_page.dart
```

**AvailabilityBloc Events:** `LoadSlots(inventoryItemId?)`, `CreateSlot(data)`, `UpdateSlot(id, data)`, `DeleteSlot(id, inventoryItemId?)`

---

### 12. Notification (`/features/notification/`)

**Route:** `/app/notifications`

**Files:**
```
notification/
├── data/
│   ├── api/notification_api_service.dart
│   ├── dto/notification_dto.dart
│   └── repository/notification_repository.dart
└── presentation/
    ├── blocs/notification_bloc.dart
    ├── pages/notifications_page.dart
    └── widgets/
        ├── notification_bell.dart     # AppBar badge with unread count
        └── notification_tile.dart     # Individual notification display
```

**NotificationBloc Events:** `LoadNotifications`, `LoadUnreadCount`, `MarkRead(id)`, `MarkAllRead`

NotificationBloc is a global BLoC (created in `app.dart` MultiBlocProvider).

---

### 13. Profile (`/features/profile/`)

**Route:** `/app/profile`

**Files:**
```
profile/
├── data/
│   ├── api/profile_api_service.dart
│   └── repository/profile_repository.dart
└── presentation/
    ├── blocs/profile_bloc.dart
    ├── pages/profile_page.dart            # View/edit toggle mode
    └── widgets/
        └── change_password_dialog.dart    # Current + new + confirm password fields
```

**ProfileBloc Events:** `LoadProfile`, `UpdateProfile(data)`, `ChangePassword(currentPassword, newPassword)`

---

## Dependency Injection

**Location:** `lib/app/di.dart`

All dependencies registered as lazy singletons using GetIt. 12 feature registrations:

```
Core:
  Logger, SharedPreferences, AuthTokenStorage, ApiClient(tokenStorage)

Auth:
  AuthRemoteDataSource -> AuthRemoteDataSourceImpl(apiClient, tokenStorage)
  AuthLocalDataSource -> AuthLocalDataSourceImpl(sharedPreferences)
  AuthRepository -> AuthRepositoryImpl(remote, local, tokenStorage, apiClient)
  LoginUseCase, RegisterUseCase, GetCurrentUserUseCase, LogoutUseCase

Discover:
  ConfigApiService(apiClient), InventoryApiService(apiClient)
  DiscoverRepository -> DiscoverRepositoryImpl(configApi, inventoryApi)

Inquiry:
  InquiryApiService(apiClient), InquiryRepository(apiService)

InventoryManagement:
  InventoryManagementApiService(apiClient), InventoryManagementRepository(apiService)

Campaign:
  CampaignApiService(apiClient), CampaignRepository(apiService)

AdminConfig:
  AdminConfigApiService(apiClient), AdminConfigRepository(apiService)

AdminUsers:
  AdminUserApiService(apiClient), AdminUserRepository(apiService)

Agency:
  AgencyApiService(apiClient), AgencyRepository(apiService)

Availability:
  AvailabilityApiService(apiClient), AvailabilityRepository(apiService)

Profile:
  ProfileApiService(apiClient), ProfileRepository(apiService)

Analytics:
  AnalyticsApiService(apiClient), AnalyticsRepository(apiService)

Notification:
  NotificationApiService(apiClient), NotificationRepository(apiService)
```

**MultiRepositoryProvider** in `app.dart` provides 12 repositories to the widget tree:
ApiClient, DiscoverRepository, InquiryRepository, InventoryManagementRepository, CampaignRepository, AdminConfigRepository, AdminUserRepository, AgencyRepository, AvailabilityRepository, ProfileRepository, AnalyticsRepository, NotificationRepository

**Global BLoCs** (MultiBlocProvider in `app.dart`):
AuthBloc, DiscoverBloc, NotificationBloc, LocaleCubit

**Local BLoCs** (created in pages):
All other BLoCs are created locally via `BlocProvider(create: ...)` in their respective pages.

---

## Routing (GoRouter)

**Location:** `lib/app/router.dart`

### Public routes (no auth required)

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

### Shell routes (StatefulShellRoute.indexedStack, 3 branches)

| Branch | Path | Page |
|--------|------|------|
| 0 | `/app/dashboard` | DashboardPage |
| 1 | `/app/discover` | DiscoverPage (nested: `/app/discover/:id`) |
| 2 | `/app/profile` | ProfilePage |

### Role-specific routes (pushed over shell)

| Path | Page | Access |
|------|------|--------|
| `/app/inquiries` | InquiryListPage | brand, agency, admin |
| `/app/inquiries/create` | InquiryCreatePage | brand, agency (reads `?unitIds=`) |
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
| `/app/notifications` | NotificationsPage | all authenticated |

**Total: 28 routes** (8 public + 3 shell + 17 role-specific + 1 shared)

### Redirect logic

- Public routes (`/`, `/discover/*`, `/auth/*`) are freely accessible
- `/app/*` routes require `AuthAuthenticated` state; redirect to `/auth/login` if not authenticated
- If authenticated and accessing `/auth/*` or `/`, redirect to `/app/dashboard`
- GoRouter `refreshListenable` listens to AuthBloc stream for reactive redirects

---

## Localization (l10n)

**Location:** `lib/core/l10n/`

- 2 languages: English (template), Serbian (default display)
- ~223 keys in English ARB, ~131 keys in Serbian ARB (Serbian has fewer translations)
- `LocaleCubit` with `SharedPreferences` persistence
- Language toggle available in AppBar, drawer, and sidebar
- Usage: `final l10n = AppLocalizations.of(context)!; Text(l10n.loginButton);`
- After ARB changes: run `flutter gen-l10n` then hot restart

---

## Map

**Package:** flutter_map 7.x + latlong2 + flutter_map_marker_cluster

**Location:** `lib/features/discover/presentation/widgets/inventory_map.dart`

- Tile provider: OpenStreetMap
- Cluster markers for grouping nearby units
- Highlight selected marker
- Tap marker to show `InventoryMapCard` popup
- Animated zoom on country/city change (TickerProviderStateMixin + AnimationController)
- `MapLocationPicker` widget for inventory create/edit (tap to set location)
