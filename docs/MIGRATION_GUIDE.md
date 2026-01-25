# 🚀 Flutter Migration & Setup Guide

## ✅ Status Projekta

### **Uradjeno:**

1. ✅ **Ažuriran pubspec.yaml** - dodati svi potrebni paketi
2. ✅ **Responsive system** - breakpoints i responsive widgets
3. ✅ **Theme system** - boje, tipografija, konstante (matching React)
4. ✅ **Clean arhitektura** - folder struktura pripremljena

### **Sledeći koraci:**

## 📋 Implementacioni Plan

### **Faza 1: Core Setup (3-5 dana)**
- [ ] Kreirati sve reusable UI komponente (buttons, inputs, cards)
- [ ] Implementirati kompletnu theme konfiguraciju
- [ ] Setup dependency injection sa get_it + injectable
- [ ] Konfigurisati routing sa go_router

### **Faza 2: Landing Page (5-7 dana)**
- [ ] Hero section sa animacijama
- [ ] Categories section
- [ ] Features showcase
- [ ] Testimonials
- [ ] CTA sections
- [ ] Footer

### **Faza 3: Auth Feature (3-4 dana)**
- [ ] Login page
- [ ] Register page
- [ ] Auth BLoC
- [ ] API integration
- [ ] JWT storage

### **Faza 4: Inventory Search (7-10 dana)**
- [ ] Interactive map (flutter_map)
- [ ] Search filters
- [ ] Inventory cards
- [ ] Detail pages
- [ ] Cart/Selection system

### **Faza 5: Dashboards (10-14 dana)**
- [ ] Brand dashboard
- [ ] Agency dashboard
- [ ] Media Owner portal
- [ ] Admin panel

### **Faza 6: Optimization (5-7 dana)**
- [ ] Performance optimization
- [ ] Web-specific optimizations
- [ ] Accessibility improvements
- [ ] Testing (unit, widget, integration)

---

## 🎨 Design System - Matching React

### **Colors:**
```dart
Primary: #6366F1 (Indigo)
Primary Foreground: #FFFFFF
Background: #FFFFFF
Foreground: #111827
Border: #E5E7EB
Secondary: #F5F6FF
Muted: #F9FAFB
```

### **Typography:**
```dart
Font: Space Grotesk
Weights: 300, 400, 500, 600, 700

Display Large: 72px / Bold
H1: 40px / Bold
H2: 32px / Bold
Body: 16px / Regular
```

### **Spacing:**
```dart
xs: 8px
sm: 12px
md: 16px (base)
lg: 24px
xl: 32px
xxl: 48px
```

### **Border Radius:**
```dart
Default: 16px
XL: 24px
XXL: 32px
Full: 9999px
```

---

## 📱 Responsive Breakpoints

```dart
Mobile: < 600px
Tablet: 600px - 900px
Desktop: 900px - 1200px
Large Desktop: > 1200px
```

### **Usage Example:**
```dart
// Responsive layout
ResponsiveLayout(
  mobile: MobileHeader(),
  desktop: DesktopHeader(),
)

// Context extension
if (context.isMobile) {
  return MobileLayout();
}

// Responsive padding
Padding(
  padding: context.responsivePadding,
  child: Content(),
)
```

---

## 🧩 UI Component Library

### **Buttons:**

```dart
// Primary button
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Secondary button
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Ghost button
TextButton(
  onPressed: () {},
  child: Text('Tertiary Action'),
)
```

### **Inputs:**

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email),
  ),
)
```

### **Cards:**

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Column(
      children: [
        Text('Title', style: AppTypography.h5),
        SizedBox(height: AppSpacing.sm),
        Text('Content', style: AppTypography.bodyMedium),
      ],
    ),
  ),
)
```

---

## 🏗️ Folder Structure

```
lib/
├── app/
│   ├── app.dart                 # Root MaterialApp
│   ├── di.dart                  # GetIt setup
│   └── router.dart              # GoRouter config
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_constants.dart
│   │   └── app_theme.dart
│   │
│   ├── responsive/
│   │   ├── breakpoints.dart
│   │   └── responsive_builder.dart
│   │
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── ghost_button.dart
│   │   ├── inputs/
│   │   │   ├── text_input.dart
│   │   │   ├── search_input.dart
│   │   │   └── select_input.dart
│   │   ├── cards/
│   │   │   ├── base_card.dart
│   │   │   └── inventory_card.dart
│   │   └── layout/
│   │       ├── app_scaffold.dart
│   │       ├── responsive_container.dart
│   │       └── section_wrapper.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   └── helpers.dart
│   │
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── route_constants.dart
│   │   └── app_constants.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── interceptors.dart
│   │   └── endpoints.dart
│   │
│   └── l10n/                    # Localization
│       ├── app_en.arb
│       └── app_sr.arb
│
├── features/
│   ├── landing/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── landing_page.dart
│   │   │   └── widgets/
│   │   │       ├── hero_section.dart
│   │   │       ├── categories_section.dart
│   │   │       ├── features_section.dart
│   │   │       └── footer.dart
│   │   └── data/
│   │       └── mock_data.dart
│   │
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── register_usecase.dart
│   │   │
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       ├── widgets/
│   │       │   ├── auth_form.dart
│   │       │   └── social_login_buttons.dart
│   │       └── blocs/
│   │           ├── auth_bloc.dart
│   │           ├── auth_event.dart
│   │           └── auth_state.dart
│   │
│   ├── inventory/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── search_page.dart
│   │       │   └── inventory_detail_page.dart
│   │       └── widgets/
│   │           ├── map_view.dart
│   │           ├── filter_bar.dart
│   │           └── inventory_list.dart
│   │
│   ├── dashboard/
│   │   ├── brand/
│   │   ├── agency/
│   │   └── media_owner/
│   │
│   └── admin/
│       └── presentation/
│           └── pages/
│               ├── admin_dashboard.dart
│               ├── user_management.dart
│               └── pricing_panel.dart
│
└── main.dart
```

---

## 🔧 Development Commands

### **Run app:**
```bash
# Mobile (iOS)
flutter run -d ios

# Mobile (Android)
flutter run -d android

# Web
flutter run -d chrome

# Desktop
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

### **Build:**
```bash
# Web production
flutter build web --release --web-renderer canvaskit

# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release

# Desktop
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

### **Code generation:**
```bash
# Generate files (models, DI, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

### **Testing:**
```bash
# All tests
flutter test

# Coverage
flutter test --coverage

# Widget tests
flutter test test/widgets

# Integration tests
flutter drive --target=test_driver/app.dart
```

### **Analysis:**
```bash
# Analyze code
flutter analyze

# Fix formatting
dart format lib/ --fix

# Check outdated packages
flutter pub outdated
```

---

## 🌐 Web Configuration

### **index.html:**
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OOH Platform</title>
  
  <!-- Google Fonts - Space Grotesk -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  
  <!-- Meta tags for SEO -->
  <meta name="description" content="OOH Platform - Out of Home Advertising">
  <meta name="keywords" content="OOH, advertising, outdoor">
  
  <!-- Open Graph -->
  <meta property="og:title" content="OOH Platform">
  <meta property="og:description" content="Out of Home Advertising Platform">
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

---

## 📦 Deployment

### **Web (Firebase Hosting):**
```bash
# Build
flutter build web --release

# Deploy
firebase init hosting
firebase deploy
```

### **Mobile (App Store / Play Store):**
```bash
# iOS
flutter build ios --release
# Upload to App Store Connect

# Android
flutter build appbundle --release
# Upload to Play Console
```

---

## ✅ Checklist pre-launch:

- [ ] All pages responsive (mobile, tablet, desktop)
- [ ] All forms validated
- [ ] API integration complete
- [ ] Authentication working
- [ ] Maps working
- [ ] Error handling implemented
- [ ] Loading states everywhere
- [ ] Accessibility (screen readers, keyboard nav)
- [ ] Performance optimization
- [ ] Analytics integrated
- [ ] Testing coverage > 70%
- [ ] Documentation complete

---

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Go Router](https://pub.dev/packages/go_router)
- [Flutter Map](https://pub.dev/packages/flutter_map)
- [Google Fonts](https://pub.dev/packages/google_fonts)

---

**Maintained by:** OOH Development Team  
**Last updated:** 25 January 2026  
**Version:** 1.0
