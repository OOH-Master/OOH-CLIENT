# Reusable Widgets Documentation

## Overview

This document catalogs all reusable widgets in the OOH Mobile application. Widgets are organized by category.

## Widget Categories

- [Core Widgets](#core-widgets) - Basic UI components (`lib/core/widgets/`)
- [Landing Widgets](#landing-widgets) - Landing page sections
- [Layout Widgets](#layout-widgets) - Responsive layout components
- [Discover Widgets](#discover-widgets) - Inventory browsing components
- [Inventory Management Widgets](#inventory-management-widgets) - Media owner tools
- [Notification Widgets](#notification-widgets) - Notification system
- [Auth Widgets](#auth-widgets) - Registration flow
- [Campaign Widgets](#campaign-widgets) - Campaign management
- [Inquiry Widgets](#inquiry-widgets) - Inquiry status display
- [Navigation Widgets](#navigation-widgets) - Breadcrumb navigation
- [Profile Widgets](#profile-widgets) - Profile management
- [Dashboard Widgets](#dashboard-widgets) - Dashboard components
- [Admin Widgets](#admin-widgets) - Admin tools

---

## Core Widgets

Location: `lib/core/widgets/`

### AppButton

Custom button widget with multiple variants and consistent styling.

**Location**: `lib/core/widgets/app_button.dart`

**Variants**: Primary (Elevated), Secondary (Outlined), Tertiary (Text)

**Parameters**:
```dart
AppButton({
  required String text,
  required VoidCallback onPressed,
  ButtonVariant variant = ButtonVariant.primary,
  bool isLoading = false,
  bool isFullWidth = false,
  IconData? icon,
})
```

### AppTextField

Custom text input field with built-in validation and consistent styling.

**Location**: `lib/core/widgets/app_text_field.dart`

**Parameters**:
```dart
AppTextField({
  required TextEditingController controller,
  String? label,
  String? hint,
  IconData? prefixIcon,
  IconData? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  VoidCallback? onSuffixIconTap,
})
```

### AppScaffold

Custom scaffold with consistent structure and navigation.

**Location**: `lib/core/widgets/app_scaffold.dart`

**Parameters**:
```dart
AppScaffold({
  required Widget body,
  String? title,
  List<Widget>? actions,
  Widget? floatingActionButton,
  Widget? bottomNavigationBar,
  bool showAppBar = true,
})
```

### AppSnackbar

Utility for showing consistent snackbar messages.

**Location**: `lib/core/widgets/app_snackbar.dart`

**Methods**:
```dart
AppSnackbar.success(BuildContext context, String message)
AppSnackbar.error(BuildContext context, String message)
AppSnackbar.info(BuildContext context, String message)
AppSnackbar.warning(BuildContext context, String message)
```

### MainAppBar

Reusable AppBar used across all pages. Provides consistent branding, navigation, locale toggle, and notification bell.

**Location**: `lib/core/widgets/main_app_bar.dart`

**Parameters**:
```dart
MainAppBar({
  Widget? titleWidget,
  bool showBackButton = false,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
  bool showLoginButton = false,
})
```

**Features**:
- Integrates `NotificationBell` widget for authenticated users
- Language toggle (en/sr) via `LocaleCubit`
- Back button support for detail pages
- Responsive behavior based on screen width

### AuthGuardDialog

Modal dialog that prompts unauthenticated users to log in when they try to access protected features.

**Location**: `lib/core/widgets/auth_guard_dialog.dart`

**Usage**: `AuthGuardDialog.show(context)`

### AppShell

Layout shell widget for consistent page structure.

**Location**: `lib/core/widgets/app_shell.dart`

---

## Landing Widgets

Location: `lib/features/landing/presentation/widgets/`

### AppHeader

Navigation header with logo, menu, and auth buttons.

**Location**: `lib/features/landing/presentation/widgets/app_header.dart`

**Features**:
- Desktop horizontal navigation
- Mobile hamburger menu with vertical navigation drawer
- Smooth scroll to sections
- Login/Register buttons

### HeroSection

Landing page hero with animated rotating keywords and search.

**Location**: `lib/features/landing/presentation/widgets/hero_section.dart`

**Features**:
- 7 rotating keywords (2.2s interval): Billboards, Subways, Airports, Malls, Streets, Stadiums, Stations
- Country/City dropdown selectors (uses DiscoverBloc state directly)
- Search input field
- 8 category filter pills
- Gradient background with overlay

### CategoriesSection

Grid of OOH advertising categories with gradient cards.

**Location**: `lib/features/landing/presentation/widgets/categories_section.dart`

**Features**:
- 4 categories: Digital Billboards, Subway Advertising, Bus Shelters, Airport Displays
- Hover scale animation (1.02x, 300ms transition)
- Responsive grid: 1 column (mobile), 2 (tablet), 4 (desktop)

### NewlyAddedSection

Horizontal scrolling carousel of media listings.

**Location**: `lib/features/landing/presentation/widgets/newly_added_section.dart`

**Features**:
- 6 sample media cards with image, name, location, price
- Horizontal scroll with card hover effects

### AdvancedAnalyticsSection

Two-column section showcasing analytics features.

**Location**: `lib/features/landing/presentation/widgets/advanced_analytics_section.dart`

**Features**:
- Feature list with checkmarks (real-time tracking, demographics, ROI, competitor analysis)
- CTA button, gradient chart mockup
- Responsive: stacked (mobile), side-by-side 60/40 (desktop)

### ExpertAdviceSection

Mobile app mockup showcase with feature cards.

**Location**: `lib/features/landing/presentation/widgets/expert_advice_section.dart`

**Features**:
- Phone frame mockup (9:19.5 ratio)
- Expert Support icon with pulse animation
- 2 floating feature cards: Campaign Analytics, Performance Insights
- Responsive sizing

### TestimonialsSection

Grid of customer testimonials.

**Location**: `lib/features/landing/presentation/widgets/testimonials_section.dart`

**Features**:
- 3 testimonials with avatar, name, role, company, quote
- Responsive grid: 1 column (mobile), 2 (tablet), 3 (desktop)

### NewsInsightsSection

Blog articles and trending topics sidebar.

**Location**: `lib/features/landing/presentation/widgets/news_insights_section.dart`

**Features**:
- 2 featured articles + 3 trending topics
- Read time estimates, category badges
- Responsive: stacked (mobile), 70/30 split (desktop)

### CTASection

Final call-to-action section.

**Location**: `lib/features/landing/presentation/widgets/cta_section.dart`

### AppFooter

Site footer with link columns and copyright.

**Location**: `lib/features/landing/presentation/widgets/app_footer.dart`

**Features**:
- 4 columns: Solutions, Products, Resources, Company
- Responsive: 1 per row (mobile), 2 (tablet), 4 (desktop)

---

## Layout Widgets

### ResponsiveLayout

Adaptive layout builder for different screen sizes.

**Location**: `lib/core/responsive/responsive_builder.dart`

**Parameters**:
```dart
ResponsiveLayout({
  required Widget mobile,
  Widget? tablet,
  Widget? desktop,
  Widget? largeDesktop,
})
```

### ResponsiveBuilder

Builder widget that provides the current `DeviceType` to a callback.

**Location**: `lib/core/responsive/responsive_builder.dart`

**Parameters**:
```dart
ResponsiveBuilder({
  required Widget Function(BuildContext context, DeviceType deviceType) builder,
})
```

---

## Discover Widgets

Location: `lib/features/discover/presentation/widgets/`

### DiscoverCardGrid

Grid layout for inventory cards in discover view.

**Location**: `lib/features/discover/presentation/widgets/discover_card_grid.dart`

**Features**:
- Responsive grid columns based on screen width
- Card-based inventory presentation
- Supports pagination via `LoadMore` event

### DiscoverCardList

List layout for inventory cards in discover view.

**Location**: `lib/features/discover/presentation/widgets/discover_card_list.dart`

**Features**:
- Vertical list with detailed card layout
- Alternative to grid view
- Supports pagination

### ViewToggle

Toggle between grid and list display modes.

**Location**: `lib/features/discover/presentation/widgets/view_toggle.dart`

**Features**:
- Grid/List icon toggle
- Dispatches `ChangeViewMode` event on DiscoverBloc
- Compact icon button design

### SortDropdown

Dropdown for sorting inventory results.

**Location**: `lib/features/discover/presentation/widgets/sort_dropdown.dart`

**Features**:
- Sort by: price ascending, price descending, newest
- Dispatches `ChangeSort` event on DiscoverBloc

### ActiveFilterChips

Displays currently active filters as removable chips.

**Location**: `lib/features/discover/presentation/widgets/active_filter_chips.dart`

**Features**:
- Shows active filter values (country, city, type, format, price range, etc.)
- Each chip has a delete action to remove that filter
- Horizontal scrollable row
- "Clear all" option triggers `ResetFilters` event

### FilterBottomSheet

Bottom sheet with advanced filter options.

**Location**: `lib/features/discover/presentation/widgets/filter_bottom_sheet.dart`

**Features**:
- Filter by: unit type, media format, venue type, environment, illumination, price range
- Apply and reset callbacks
- Uses `InventoryFilterParams` data class

### InventoryCard

Card widget for displaying individual inventory items.

**Location**: `lib/features/discover/presentation/widgets/inventory_card.dart`

**Features**:
- Image thumbnail, name, location, price display
- Used in both grid and list layouts

### InventoryMap

Interactive map showing inventory locations.

**Location**: `lib/features/discover/presentation/widgets/inventory_map.dart`

**Features**:
- flutter_map with OpenStreetMap tiles
- Marker clustering via flutter_map_marker_cluster
- Animated zoom on city/country change
- Tap marker to select and show popup

### InventoryMapCard

Popup card displayed when tapping a map marker.

**Location**: `lib/features/discover/presentation/widgets/inventory_map_card.dart`

**Features**:
- Unit name, address, price
- Close button and "View Details" action

### ImageGallery

Image carousel with lightbox for inventory detail page.

**Location**: `lib/features/discover/presentation/widgets/image_gallery.dart`

**Features**:
- Horizontal image carousel
- Tap to open fullscreen lightbox
- Navigation arrows
- Image counter indicator

### Breadcrumb

Breadcrumb navigation component for detail pages.

**Location**: `lib/features/discover/presentation/widgets/breadcrumb.dart`

**Features**:
- Hierarchical path display (e.g., Home > Discover > Billboard Name)
- Clickable parent segments for navigation
- Current page shown as non-clickable text

---

## Inventory Management Widgets

Location: `lib/features/inventory_management/presentation/widgets/`

### ImageUploadWidget

Image management widget for inventory items.

**Location**: `lib/features/inventory_management/presentation/widgets/image_upload_widget.dart`

**Features**:
- Image picker integration (gallery/camera via image_picker + file_picker)
- Upload to backend API
- Thumbnail preview grid
- Delete individual images
- Loading state during upload

### InventoryFilterBar

Filter and search toolbar for inventory management.

**Location**: `lib/features/inventory_management/presentation/widgets/inventory_filter_bar.dart`

**Features**:
- Text search input
- Filter dropdowns (type, status, format)
- Sort controls
- Compact horizontal layout

### MapLocationPicker

Interactive map for selecting inventory location.

**Location**: `lib/features/inventory_management/presentation/widgets/map_location_picker.dart`

**Features**:
- flutter_map interactive picker
- Tap to set location marker
- Displays lat/lng coordinates
- Default center on current city

### BulkActionToolbar

Toolbar for bulk operations on selected inventory items.

**Location**: `lib/features/inventory_management/presentation/widgets/bulk_action_toolbar.dart`

**Features**:
- Appears when items are selected (checkbox mode)
- Bulk status change (available, maintenance, booked)
- Select all / deselect all
- Count of selected items displayed

---

## Notification Widgets

Location: `lib/features/notification/presentation/widgets/`

### NotificationBell

AppBar notification icon with unread badge.

**Location**: `lib/features/notification/presentation/widgets/notification_bell.dart`

**Features**:
- Bell icon integrated into MainAppBar
- Red circle badge with unread count
- Hides badge when count is 0
- Taps navigate to NotificationsPage

### NotificationTile

Individual notification display tile.

**Location**: `lib/features/notification/presentation/widgets/notification_tile.dart`

**Features**:
- Icon based on notification type
- Title + description text
- Timestamp display
- Read/unread visual state (bold for unread)
- Tap to mark as read and navigate

---

## Auth Widgets

Location: `lib/features/auth/presentation/widgets/`

### RoleSelectorCard

Role selection card for multi-step registration (step 1).

**Location**: `lib/features/auth/presentation/widgets/role_selector_card.dart`

**Features**:
- Card with role icon, name, description
- 3 cards: Brand (storefront icon), Agency (business center icon), Media Owner (TV icon)
- Selected state with primary color border
- Admin role is not available for self-registration

---

## Campaign Widgets

Location: `lib/features/campaign/presentation/widgets/`

### CampaignStatusBadge

Status badge chip for campaign status.

**Location**: `lib/features/campaign/presentation/widgets/campaign_status_badge.dart`

**Features**:
- Color-coded chips: draft (gray), active (green), completed (blue), cancelled (red)
- Consistent styling across list and detail pages

---

## Inquiry Widgets

Location: `lib/features/inquiry/presentation/widgets/`

### InquiryCard

Card widget for displaying inquiry items in lists.

**Location**: `lib/features/inquiry/presentation/widgets/inquiry_card.dart`

### InquiryStatusBadge

Color-coded status badge for inquiry lifecycle statuses.

**Location**: `lib/features/inquiry/presentation/widgets/inquiry_status_badge.dart`

**Features**:
- Color-coded background and border per InquiryStatus enum value
- Uses localized status labels via AppLocalizations
- Compact chip design with `AppTypography.caption` styling

---

## Navigation Widgets

### Breadcrumb

See [Discover Widgets > Breadcrumb](#breadcrumb) above.

**Location**: `lib/features/discover/presentation/widgets/breadcrumb.dart`

---

## Profile Widgets

Location: `lib/features/profile/presentation/widgets/`

### ChangePasswordDialog

Modal dialog for changing user password.

**Location**: `lib/features/profile/presentation/widgets/change_password_dialog.dart`

**Features**:
- Current password field
- New password + confirmation fields
- Validation (match check, minimum length)
- Submit triggers ProfileBloc `ChangePassword` event
- Cancel dismisses dialog

---

## Dashboard Widgets

Location: `lib/features/dashboard/presentation/widgets/`

### AdminDashboard

Admin-specific dashboard with KPI cards and charts.

**Location**: `lib/features/dashboard/presentation/widgets/admin_dashboard.dart`

**Features**:
- KPI stat cards
- Pipeline bar chart (fl_chart)
- Trend line chart (fl_chart)

### BrandDashboard

Brand-specific dashboard.

**Location**: `lib/features/dashboard/presentation/widgets/brand_dashboard.dart`

### AgencyDashboard

Agency-specific dashboard.

**Location**: `lib/features/dashboard/presentation/widgets/agency_dashboard.dart`

### MediaOwnerDashboard

Media owner-specific dashboard.

**Location**: `lib/features/dashboard/presentation/widgets/media_owner_dashboard.dart`

### BaseDashboard

Shared base layout for all role dashboards.

**Location**: `lib/features/dashboard/presentation/widgets/base_dashboard.dart`

### StatCard

Statistic display card used in all dashboards.

**Location**: `lib/features/dashboard/presentation/widgets/stat_card.dart`

**Features**:
- Icon, title, value display
- Used for KPIs across all role dashboards

### QuickActionCard

CTA action card for dashboard quick actions.

**Location**: `lib/features/dashboard/presentation/widgets/quick_action_card.dart`

**Features**:
- Icon, title, description
- Tap action navigates to relevant page

---

## Admin Widgets

Location: `lib/features/admin/presentation/widgets/`

### UserEditDialog

Dialog for editing user data in admin user management.

**Location**: `lib/features/admin/presentation/widgets/user_edit_dialog.dart`

**Features**:
- Form fields for user properties
- Dispatches `UpdateUser` event on AdminUserBloc

---

## Best Practices

### Widget Composition
- Compose small, reusable widgets instead of monolithic ones
- Use `const` constructors where possible to reduce rebuilds

### Named Parameters
- Use named parameters for clarity in complex widgets

### Widget Keys
- Use `ValueKey` for list items to help Flutter identify widgets

### Extract Methods
- Extract complex widget subtrees into `_buildX()` methods for readability

---

**Last Updated**: April 2026
