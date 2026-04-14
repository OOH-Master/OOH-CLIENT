# Implementation Summary - OOH Platform

## 1. Backend (Spring Boot + PostgreSQL)

### 1.1 Infrastructure and Security

- **JWT Authentication** -- Stateless authentication. Server generates JWT access + refresh tokens at login/register; client sends access token in `Authorization: Bearer <token>` header. `JwtAuthenticationFilter` intercepts every request and validates the token.
- **Refresh Tokens** -- 7-day expiry refresh tokens stored in DB. `POST /auth/refresh` issues new access + refresh token pair. `POST /auth/logout` invalidates the refresh token.
- **Role-based access** -- 4 system roles: `INTERNAL_ADMIN`, `MEDIA_OWNER`, `BRAND`, `AGENCY`. URL-path-based authorization in `SecurityConfig`.
- **CORS configuration** -- Configurable via `CORS_ALLOWED_ORIGINS` env var.
- **Rate limiting** -- `/auth/**` endpoints limited to 10 req/min per IP.
- **Account lockout** -- 5 failed login attempts triggers 15-min lock.
- **Bean Validation** -- `@NotBlank`, `@Email`, `@Size`, `@NotNull`, `@DecimalMin` on all DTOs; `@Valid` on all `@RequestBody` params.
- **Global error handler** -- `GlobalExceptionHandler` catches all exceptions and returns structured JSON responses (404, 400, 500). `ValidationErrorResponse` with `fieldErrors` map for validation failures.
- **Bootstrap (DataLoader)** -- Automatic creation of default users and dictionaries at startup. Optional Excel import of inventory data.
- **Swagger UI** -- API documentation at `/swagger-ui.html`.

### 1.2 Modules

#### Auth Module
- `POST /auth/register` -- Registration (returns JWT + refresh token)
- `POST /auth/login` -- Login (returns JWT + refresh token)
- `GET /auth/me` -- Current user from token
- `POST /auth/refresh` -- Refresh token flow
- `POST /auth/logout` -- Invalidate refresh token
- `POST /auth/forgot-password` -- Send reset email
- `POST /auth/reset-password` -- Reset password with token
- `GET /auth/verify-email` -- Verify email address
- `POST /auth/resend-verification` -- Resend verification email

#### Dictionary (Configuration)
- Tables: `Country`, `City`, `UnitType`, `MediaFormat`, `VenueType`
- Public read: `GET /public/dictionaries/{type}`
- Admin CRUD: `GET/POST/PUT/DELETE /admin/config/{type}`
- Used for filters, dropdown menus, and data standardization

#### Inventory
- `InventoryItem` -- central table with location, price, type, format, dimensions, images
- Private (Media Owner): `GET /inventory/my`, `POST/PUT/DELETE /inventory`
- Public search: `GET /public/units` with filters (country, city, type, format, price, keyword, status)
- Image upload: `POST /media-owner/inventory/{id}/images` with MIME validation (JPEG, PNG, WebP; 10MB max)
- Image serving: `GET /public/files/{filename}`
- Excel import: `POST /admin/inventory/import-excel` (Apache POI, upsert by `vendorInventoryId`)

#### Inquiry
- Full lifecycle: `SUBMITTED` -> `IN_PROGRESS` -> `QUOTES_REQUESTED` -> `PRICING_READY` -> `OFFER_SENT` -> `ACCEPTED`/`REJECTED` -> `REALIZED` -> `CLOSED`
- Two inquiry types: Inventory-Based (`UNIT_SELECTION` with `unitIds`) and Brief-Based (`BRIEF` with campaign description)
- Brand/Agency create: `POST /public/inquiries`
- Admin management: `GET /admin/inquiries` with filters (status, requesterType, search), status transitions
- Quote management: Admin requests quotes from media owners, media owners edit/submit/decline
- Offer flow: Admin sends aggregated offer, brand/agency accepts or rejects
- PDF generation (OpenPDF): automatic on creation, regenerated on price/notes changes
- `InquiryStatusMachine` validates allowed status transitions

#### Campaign
- `Campaign` + `CampaignItem` (campaign-inventory join table)
- CRUD: `POST/GET/PUT/DELETE /campaigns`
- Status: DRAFT, ACTIVE, COMPLETED, CANCELLED

#### Organization
- `Brand` -- advertiser entity
- `Agency` -- agency representing brands (1:N relationship)
- Agency CRUD brands: `GET/POST /agency/brands`

#### Availability
- Media owner availability management: `GET/POST/PUT/DELETE /media-owner/availability`
- Public availability: `GET /public/availability`

#### Notifications
- `Notification` entity with `NotificationType` enum
- CRUD: list, mark read, mark all read, unread count
- `UserDevice` entity for FCM token registration (push not yet implemented)

#### Analytics
- Role-specific endpoints: `/admin/analytics`, `/media-owner/analytics`, `/brand/analytics`, `/agency/analytics`
- Overview KPIs, inquiry pipeline, inventory stats, trend data

#### Admin Users
- `GET /admin/users` -- list with filter/search
- `PUT /admin/users/{id}` -- edit user
- Enable/disable user accounts

---

## 2. Frontend (Flutter + BLoC)

### 2.1 Architecture

- **Feature-First** organization with **BLoC pattern** for state management
- `auth` feature uses full **Clean Architecture** (data/domain/presentation); others use simplified data + presentation
- **GoRouter** for navigation with `StatefulShellRoute.indexedStack` (3 branches)
- **GetIt** for dependency injection (12 feature registrations)
- **Responsive design**: mobile (< 600px), tablet (600-899px), desktop (900-1199px), large desktop (>= 1200px)

### 2.2 Core Infrastructure

#### API Client
- Dio HTTP client with `QueuedInterceptorsWrapper` for JWT management
- **Refresh token interceptor:** on 401 response automatically attempts token refresh using a separate Dio instance (avoids interceptor loops), then retries the original request. `LogoutCallback` invoked when refresh fails.
- `AuthTokenStorage` uses `FlutterSecureStorage` for access and refresh tokens (`saveToken`, `getToken`, `saveRefreshToken`, `getRefreshToken`, `clearAll`)
- `ApiConfig` class with 40+ endpoint constants
- `ValidationErrorParser` utility for parsing backend validation error responses
- Base URL: `http://localhost:8080/api/v1` (override with `--dart-define=API_BASE_URL=...`)
- Timeouts: 30s connect/receive/send (sendTimeout disabled on web)

#### Auth Flow
- Login: username + password -> JWT access + refresh token -> `FlutterSecureStorage` -> `/auth/me` for user profile
- Register: multi-step (3 steps: role cards -> account details -> organization info) -> JWT -> auto-login
- `AuthStarted` on app launch: checks existing token from storage
- Logout: clears all tokens (`clearAll`), dispatches `LogoutRequested`, redirect to login
- Forgot Password: email -> server sends reset link -> `/auth/forgot-password`
- Reset Password: token + new password -> reset -> `/auth/reset-password`
- Email Verification: page for email address verification -> `/auth/verify-email`
- User entity fields: id, username, email, role, firstName, lastName, phone, country, city, website, emailVerified

#### Responsive Shell
- **Mobile**: Bottom NavigationBar (Dashboard, Discover, Profile) + Drawer with role-specific links
- **Desktop**: Collapsible sidebar (260px expanded / 72px collapsed) with `AnimatedContainer` transition
- `ShellCubit` manages sidebar state (index, sidebarExpanded)

#### Localization (i18n)
- 2 languages: Serbian (default display), English
- ~223 keys in English ARB, ~131 keys in Serbian ARB
- `LocaleCubit` with `SharedPreferences` persistence
- Language toggle in app bar, drawer, and sidebar

### 2.3 Feature Modules

#### Landing Page (`/`)
- Hero section with animated keywords, search, country/city dropdowns (uses DiscoverBloc state directly)
- CategoriesSection, NewlyAddedSection, AdvancedAnalyticsSection
- ExpertAdviceSection, TestimonialsSection, NewsInsightsSection, CTASection, AppFooter
- Responsive: stacked (mobile) vs. multi-column (desktop)

#### Discover (`/discover`, `/app/discover`) -- redesigned
- Public inventory search with filters (country, city, type, format, venue, environment, illumination, price)
- Country/City cascading filter (default: Serbia/Belgrade, options "All countries"/"All cities")
- 3 view modes: grid, list, mapOnly (via `ViewToggle` + `ChangeViewMode` event)
- `DiscoverCardGrid` (responsive grid) / `DiscoverCardList` (vertical list) layouts
- `SortDropdown` for sorting (priceAsc, priceDesc, newest)
- `ActiveFilterChips` showing removable filter chips with "clear all"
- `FilterBottomSheet` for advanced filtering
- Pagination with `LoadMore` event, `hasMore` flag, `currentPage` tracking
- Multi-select for inquiry via `ToggleUnitSelection` / `ClearSelection`
- Desktop: grid + map (flutter_map + OpenStreetMap with marker clustering)
- Mobile: DraggableScrollableSheet over map background
- Animated zoom on city/country change (TickerProviderStateMixin + AnimationController)
- Detail page: `ImageGallery`, `Breadcrumb`, tabbed sections, sticky CTA

#### Dashboard (`/app/dashboard`) -- redesigned
- Role-based display with real-time stats from API:
  - Brand: inquiry count, campaign count
  - Agency: brand count, inquiry count, campaign count
  - Media Owner: total inventory + active (AVAILABLE) count
  - Admin: KPI cards + pipeline chart + trend chart (`AnalyticsBloc`)
- `FutureBuilder` with `catchError` fallback for graceful API error handling
- CTA buttons navigating to relevant pages
- `AnalyticsApiService` + `AnalyticsRepository` + `AnalyticsBloc` for chart data
- `fl_chart` package for KPI, pipeline bar chart, and trend line chart rendering
- Dashboard widgets: `AdminDashboard`, `BrandDashboard`, `AgencyDashboard`, `MediaOwnerDashboard`, `BaseDashboard`, `StatCard`, `QuickActionCard`

#### Inquiry (`/app/inquiries`, `/app/inquiries/create`) -- expanded
- Inquiry list with role-based endpoint (brand/agency/admin)
- **Dual flow toggle for inquiry creation:**
  - **Flow A (Inventory-Based):** user selects inventory items on Discover, passes `unitIds` to create page
  - **Flow B (Campaign Brief):** user describes campaign (budget, dates, cities, media types) without selecting inventory
  - Form with contact info, campaign details, date pickers, budget
  - Calls `POST /api/v1/public/inquiries` with `CreateInquiryRequestDto`
- Inquiry detail: `/app/inquiries/:id`
- **Admin Inquiry Management:** `/app/admin/inquiries`
  - Filters: status, requesterType, search
  - Status transition buttons
- **Media Owner Quotes:** `/app/media-owner/quotes`
  - Quote list with editable prices per item
  - Submit/decline actions
- **Offer Review:** `/app/inquiries/:id/offer`
  - Offer breakdown with prices
  - Accept/reject with reason
- InquiryBloc: 15 events -- `LoadInquiries`, `LoadInquiryDetail`, `CreateInquiry`, `TransitionInquiryStatus`, `RequestQuotes`, `SendOffer`, `LoadMediaOwnerQuotes`, `SubmitQuote`, `DeclineQuote`, `UpdateQuoteItemPrice`, `LoadOffer`, `AcceptOffer`, `RejectOffer`, `UpdateAdminNotes`, `UpdateQuotedPrice`
- Widgets: `InquiryCard`, `InquiryStatusBadge`

#### Inventory Management (`/app/my-inventory`) -- expanded
- Media owner inventory list with search, filter, sort
- Create: `/app/inventory/create`
- Edit: `/app/inventory/:id/edit`
- `ImageUploadWidget` -- image picker (image_picker + file_picker), upload, thumbnail preview, delete
- `InventoryFilterBar` -- search/filter/sort controls
- `MapLocationPicker` -- interactive flutter_map location picker
- `BulkActionToolbar` -- bulk status change, select all/deselect all
- InventoryManagementBloc: `LoadMyInventory`, `CreateInventoryItem`, `UpdateInventoryItem`, `DeleteInventoryItem`, `SearchInventory`, `FilterByStatus`, `SortInventory`, `ToggleSelection`, `SelectAll`, `ClearSelection`, `BulkUpdateStatus`

#### Campaign (`/app/campaigns`) -- expanded
- Campaign list with status badges (draft, active, completed, cancelled) + filter bar
- Create form: `/app/campaigns/create`
- Detail page: `/app/campaigns/:id`
- Edit page: `/app/campaigns/:id/edit`
- `CampaignStatusBadge` widget
- Agency-only field: `brandUsername`
- CampaignBloc: `LoadCampaigns`, `CreateCampaign`, `LoadCampaignDetail`, `UpdateCampaign`, `DeleteCampaign`, `ChangeStatus`

#### Admin Config (`/app/admin/config`) -- expanded
- 5-tab interface: Countries, Cities (with country dropdown), UnitTypes, MediaFormats, VenueTypes
- List items + FAB for adding new
- Edit/delete dialogs for all items
- AdminConfigBloc: `LoadConfigTab`, `CreateConfigItem`, `UpdateConfigItem`, `DeleteConfigItem`

#### Admin Users (`/app/admin/users`)
- `AdminUserApiService` + `AdminUserRepository` + `AdminUserBloc`
- `AdminUsersPage` -- user list with search/filter (role, enabled, search)
- `UserEditDialog` -- dialog for editing user data
- AdminUserBloc: `LoadUsers`, `UpdateUser`, `DisableUser`, `EnableUser`

#### Agency Brands (`/app/agency/brands`)
- Brand list with avatar initials and #id display
- Create new brands
- AgencyBloc: `LoadBrands`, `CreateBrand`

#### Availability (`/app/media-owner/availability`)
- `AvailabilityApiService` + `AvailabilityRepository` + `AvailabilityBloc`
- `AvailabilityManagementPage` for managing inventory availability slots
- Complete data/presentation layer
- AvailabilityBloc: `LoadSlots`, `CreateSlot`, `UpdateSlot`, `DeleteSlot`

#### Notification (`/app/notifications`)
- `NotificationApiService` + `NotificationRepository` + `NotificationBloc`
- `NotificationsPage` -- list of all notifications with `NotificationTile` widgets
- `NotificationBell` -- AppBar badge with unread count (red circle, hides at 0)
- NotificationBloc is global (created in `app.dart` MultiBlocProvider)
- NotificationBloc: `LoadNotifications`, `LoadUnreadCount`, `MarkRead`, `MarkAllRead`

#### Profile (`/app/profile`) -- expanded
- `ProfileApiService` + `ProfileRepository` + `ProfileBloc`
- View/edit toggle mode on profile page
- `ChangePasswordDialog` -- current + new + confirm password fields
- ProfileBloc: `LoadProfile`, `UpdateProfile`, `ChangePassword`

### 2.4 Design System

- **Colors**: Indigo primary (#6366F1), gray scale for text and borders, semantic colors (success, warning, destructive, info)
- **Typography**: Space Grotesk (Google Fonts)
- **Spacing**: Two systems -- `Spacing` (xs=8 through xxxl=64) and `AppSpacing` (xxxs=2 through huge=96)
- **Radius**: `AppRadius` (xs=4, sm=8, md=16, lg=24, xl=24, xxl=32, xxxl=40, full=9999)
- **Breakpoints**: 600px (mobile), 900px (tablet), 1200px (desktop), 1536px (large desktop)
- **Components**: AppButton, AppTextField, MainAppBar, AppSnackbar, AuthGuardDialog

### 2.5 DI Registrations

All services and repositories registered in `di.dart` as lazy singletons:
- **Auth**: AuthTokenStorage, AuthRemoteDataSource (impl), AuthLocalDataSource (impl), AuthRepository (impl), 4 UseCases
- **Discover**: ConfigApiService, InventoryApiService, DiscoverRepository (impl)
- **Inquiry**: InquiryApiService, InquiryRepository
- **InventoryManagement**: InventoryManagementApiService, InventoryManagementRepository
- **Campaign**: CampaignApiService, CampaignRepository
- **AdminConfig**: AdminConfigApiService, AdminConfigRepository
- **AdminUsers**: AdminUserApiService, AdminUserRepository
- **Agency**: AgencyApiService, AgencyRepository
- **Availability**: AvailabilityApiService, AvailabilityRepository
- **Profile**: ProfileApiService, ProfileRepository
- **Analytics**: AnalyticsApiService, AnalyticsRepository
- **Notification**: NotificationApiService, NotificationRepository

`MultiRepositoryProvider` in `app.dart` provides 12 repositories to the widget tree.
Global BLoCs in `MultiBlocProvider`: AuthBloc, DiscoverBloc, NotificationBloc, LocaleCubit.

---

## 3. Routing Map

| Type | Path | Page | Access |
|------|------|------|--------|
| Public | `/` | LandingPage | All |
| Public | `/discover` | DiscoverPage | All |
| Public | `/discover/:id` | DiscoverDetailPage | All |
| Auth | `/auth/login` | LoginPage | Unauthenticated |
| Auth | `/auth/register` | RegisterPage (multi-step) | Unauthenticated |
| Auth | `/auth/forgot-password` | ForgotPasswordPage | Unauthenticated |
| Auth | `/auth/reset-password` | ResetPasswordPage | Unauthenticated |
| Auth | `/auth/verify-email` | EmailVerificationPage | Unauthenticated |
| Shell | `/app/dashboard` | DashboardPage | Authenticated |
| Shell | `/app/discover` | DiscoverPage | Authenticated |
| Shell | `/app/profile` | ProfilePage | Authenticated |
| Role | `/app/inquiries` | InquiryListPage | brand, agency, admin |
| Role | `/app/inquiries/create` | InquiryCreatePage (dual flow) | brand, agency |
| Role | `/app/inquiries/:id` | InquiryDetailPage | brand, agency, admin |
| Role | `/app/inquiries/:id/offer` | OfferReviewPage | brand, agency |
| Role | `/app/admin/inquiries` | AdminInquiryManagementPage | admin |
| Role | `/app/admin/users` | AdminUsersPage | admin |
| Role | `/app/media-owner/quotes` | MediaOwnerQuotesPage | mediaOwner |
| Role | `/app/media-owner/availability` | AvailabilityManagementPage | mediaOwner |
| Role | `/app/my-inventory` | MyInventoryPage | mediaOwner |
| Role | `/app/inventory/create` | InventoryFormPage | mediaOwner |
| Role | `/app/inventory/:id/edit` | InventoryFormPage | mediaOwner |
| Role | `/app/campaigns` | CampaignListPage | brand, agency |
| Role | `/app/campaigns/create` | CampaignFormPage | brand, agency |
| Role | `/app/campaigns/:id` | CampaignDetailPage | brand, agency |
| Role | `/app/campaigns/:id/edit` | CampaignEditPage | brand, agency |
| Role | `/app/admin/config` | AdminConfigPage | admin |
| Role | `/app/agency/brands` | AgencyBrandsPage | agency |
| Shared | `/app/notifications` | NotificationsPage | all authenticated |

---

## 4. User Experience Flow (by role)

### Media Owner
1. Login with username/password
2. Dashboard: "My inventory" and "Add inventory" CTA
3. Browse own inventory (`GET /inventory/my`) -- with filters, search, bulk actions
4. Create/edit inventory -- with image upload and map location picker
5. Created items appear in public search
6. Manage quotes: view quotes, enter prices, submit/decline
7. Manage inventory availability
8. Notifications about new inquiries

### Brand
1. Login/Registration (multi-step: role -> account -> organization)
2. Dashboard: "My inquiries" and "Campaigns" CTA
3. Browse inventory on Discover page (grid/list/map, sort, filter chips)
4. Send inquiry for selected inventory (Flow A) or campaign brief (Flow B)
5. View inquiry status + review and accept/reject offers
6. Create/view/edit campaigns
7. Profile with edit mode and password change
8. Notifications

### Agency
1. Login/Registration (multi-step)
2. Dashboard: brands, inquiries, campaigns
3. Manage agency brands
4. Send inquiries on behalf of brands (dual flow)
5. Review offers and accept/reject
6. Create/view/edit campaigns with brand selection
7. Notifications

### Admin
1. Login with admin account
2. Dashboard: KPI cards, pipeline chart, trend chart
3. Manage dictionaries (5 tabs) -- with edit/delete dialogs
4. Manage inquiries: filters, status transitions
5. Manage users: list, edit, enable/disable
6. PDF generation for offers
7. Notifications

---

## 5. Technologies

| Component | Technology |
|-----------|-----------|
| Backend | Java 17, Spring Boot 3.4.0 |
| Database | PostgreSQL 16 |
| Authentication | JWT (stateless) with refresh tokens |
| PDF | OpenPDF |
| Excel import | Apache POI |
| Frontend framework | Flutter (Dart 3.6+) |
| State management | flutter_bloc 9.x (BLoC pattern) |
| Navigation | GoRouter 17.x |
| DI | GetIt 9.x |
| HTTP client | Dio 5.x |
| Maps | flutter_map 7.x + OpenStreetMap + marker clustering |
| Font | Space Grotesk (Google Fonts 8.x) |
| Localization | Flutter l10n (ARB files) |
| Token storage | FlutterSecureStorage 10.x |
| User preferences | SharedPreferences 2.x |
| Charts | fl_chart 0.69.x |
| Image handling | image_picker 1.x, file_picker 10.x |
| Animations | flutter_animate 4.x |
| Forms | reactive_forms 18.x |

---

## 6. Project Structure

### Backend (`ooh-backend/`)
```
src/main/java/com/ooh/ooh_backend/
├── config/          # Security, CORS, Swagger, JWT, Rate Limiting
├── bootstrap/       # DataLoader (initial data + Excel import)
├── exception/       # Global error handler + ValidationErrorResponse
├── feature/
│   ├── auth/        # Login, Register, JWT, Refresh, Password Reset, Email Verification
│   ├── dictionary/  # Country, City, UnitType, MediaFormat, VenueType
│   ├── inventory/   # InventoryItem CRUD + Excel import + Images
│   ├── inquiry/     # Inquiries + admin pricing + PDF + status machine + quotes + offers
│   ├── campaign/    # Campaigns + items
│   ├── organization/# Brand, Agency
│   ├── availability/# Availability management
│   ├── notification/# Notifications + UserDevice
│   ├── analytics/   # Role-specific analytics
│   └── user/        # Admin user management
```

### Frontend (`ooh_mobile/`)
```
lib/
├── app/             # App, DI, Router
├── core/
│   ├── config/      # ApiClient (QueuedInterceptorsWrapper), ApiConfig (40+ endpoints)
│   ├── constants/   # Asset paths
│   ├── l10n/        # Localization (en/sr) + LocaleCubit
│   ├── responsive/  # Breakpoints, ResponsiveBuilder, DeviceType
│   ├── theme/       # Colors, Typography, Spacing, Radius, Duration, Theme
│   ├── utils/       # Failures, Result<T>, ValidationErrorParser
│   └── widgets/     # AppButton, AppTextField, MainAppBar, AppSnackbar, AuthGuardDialog
└── features/
    ├── admin/       # Config (5-tab CRUD) + user management
    ├── agency/      # Agency brand management
    ├── auth/        # JWT auth + forgot/reset password + email verification (Clean Architecture)
    ├── availability/# Availability slot management
    ├── campaign/    # Campaigns + detail + edit + status
    ├── dashboard/   # Role-based dashboard + analytics (fl_chart)
    ├── discover/    # Inventory search + map (grid/list/map views, filters, sort, pagination)
    ├── inquiry/     # Inquiries + admin management + quotes + offers (dual flow)
    ├── inventory_management/  # Inventory CRUD + images + map picker + bulk actions
    ├── landing/     # Public landing page (10 section widgets)
    ├── notification/ # Notifications (bell badge + page)
    ├── profile/     # User profile + edit + change password
    └── shell/       # Responsive navigation shell
```

---

## 7. Testing

### 7.1 Backend Tests (JUnit 5 + Mockito + AssertJ)

**17 unit tests** in 3 test classes (pure Mockito mocks, no Spring context).

| Test Class | Count | Coverage |
|-----------|-------|---------|
| `AuthenticationServiceTest` | 4 | Registration, login, JWT generation |
| `InventoryServiceTest` | 6 | CRUD operations for inventory |
| `InventoryFilterServiceTest` | 7 | JPA Specification filtering (city, price, keyword, status) |

```bash
cd ooh-backend && ./gradlew test
```

### 7.2 Frontend Unit and Widget Tests (bloc_test + mockito + flutter_test)

**27 tests** in 3 test files:

| Test File | Type | Count | Coverage |
|-----------|------|-------|---------|
| `auth_bloc_test.dart` | BLoC | 6 | Login, register, logout, session check |
| `discover_bloc_test.dart` | BLoC | 14 | Countries, cities, inventory, filters, cascade, reset, dictionaries |
| `login_page_test.dart` | Widget | 7 | UI rendering, form validation, BLoC interaction |

**Testing techniques:**
- `@GenerateNiceMocks` + `build_runner` for mock class generation
- `blocTest<Bloc, State>()` for declarative state transition testing
- `provideDummy<Result<T>>()` for Mockito compatibility with sealed classes
- `GoRouter` test setup for widget tests using navigation
- `Completer<T>` pattern for simulating async loading states

```bash
cd ooh_mobile && flutter test test/features/
```

### 7.3 Integration (E2E) Tests (integration_test)

**1 E2E test** running the actual app with a real backend:

| Test | Description |
|------|-------------|
| Login -> Discover flow | Launches app -> navigates to login -> enters credentials -> verifies Discover page -> cities load (Belgrade) -> inventory displayed |

**Prerequisites:** Backend running at localhost:8080, user `brand`/`brand123` in database.

```bash
cd ooh_mobile && flutter test integration_test/ -d <device_id>
```

### 7.4 Testing Summary

| Metric | Backend | Frontend | E2E | Total |
|--------|---------|----------|-----|-------|
| Test count | 17 | 27 | 1 | **45** |
| Test files | 3 | 3 | 1 | **7** |
| Framework | JUnit 5 + Mockito | bloc_test + flutter_test | integration_test | -- |
| Type | Unit | Unit + Widget | Integration | -- |
| Backend required | No | No | Yes | -- |
| Execution time | ~2-3s | ~4s | ~15-30s | -- |
