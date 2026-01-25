# 🎯 Flutter Clean Architecture Guide

## Arhitektura projekta

### **Folder struktura:**

```
lib/
├── app/
│   ├── app.dart                 # Root widget
│   ├── di.dart                  # Dependency injection setup
│   └── router.dart              # Go Router configuration
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Color palette (matching React)
│   │   ├── app_typography.dart  # Typography system (Space Grotesk)
│   │   ├── app_constants.dart   # Spacing, radius, durations
│   │   └── app_theme.dart       # Complete theme configuration
│   ├── responsive/
│   │   ├── breakpoints.dart     # Device breakpoints
│   │   └── responsive_builder.dart # Responsive widgets
│   ├── widgets/
│   │   ├── buttons/             # Reusable button components
│   │   ├── inputs/              # Form inputs
│   │   ├── cards/               # Card components
│   │   └── layout/              # Layout widgets
│   ├── utils/
│   │   ├── validators.dart      # Form validators
│   │   └── extensions.dart      # Dart extensions
│   ├── constants/
│   │   ├── api_constants.dart   # API endpoints
│   │   └── app_constants.dart   # App-wide constants
│   └── l10n/                    # Localization files
├── features/
│   ├── landing/                 # Landing page feature
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── data/
│   ├── auth/                    # Authentication
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── blocs/
│   ├── inventory/               # Inventory search & map
│   ├── dashboard/               # User dashboards
│   └── admin/                   # Admin panel
└── main.dart                    # Entry point
```

---

## 🎨 Design System

### **Boje (matching React):**
- Primary: `#6366F1` (Indigo)
- Background: `#FFFFFF`
- Foreground: `#111827`
- Border: `#E5E7EB`

### **Font:**
- Family: **Space Grotesk** (via Google Fonts)
- Weights: 300, 400, 500, 600, 700

### **Border Radius:**
- Default: `16px` (1rem)
- XL: `24px` (1.5rem)
- XXL: `32px` (2rem)

### **Spacing (8pt grid):**
- xs: 8px
- sm: 12px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

---

## 📱 Responsive Design

### **Breakpoints:**
```dart
mobile: < 600px
tablet: 600px - 900px
desktop: 900px - 1200px
large-desktop: > 1200px
```

### **Usage:**
```dart
// Responsive builder
ResponsiveBuilder(
  builder: (context, deviceType) {
    if (deviceType == DeviceType.mobile) {
      return MobileLayout();
    }
    return DesktopLayout();
  },
)

// Responsive layout
ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)

// Context extensions
context.isMobile
context.isDesktop
context.responsivePadding
```

---

## 🧩 UI Components

### **Button Variants:**
- Primary (ElevatedButton)
- Secondary (OutlinedButton)
- Ghost (TextButton)

### **Usage:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Button'),
)

OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Button'),
)
```

---

## 🚀 State Management

**BLoC pattern** za sve feature-e:

```dart
// Bloc
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // Implementation
}

// Event
abstract class FeatureEvent extends Equatable {}

// State
abstract class FeatureState extends Equatable {}
```

---

## 🔄 Routing

**Go Router** za sve platforme:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
  ],
)
```

---

## 🌐 Platforms

### **Support:**
- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

### **Build commands:**
```bash
# Web
flutter build web --release

# iOS
flutter build ios --release

# Android
flutter build apk --release

# Desktop
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

---

## 📦 Dependencies

### **Core:**
- flutter_bloc: State management
- get_it: Dependency injection
- go_router: Routing
- dio: HTTP client

### **UI:**
- google_fonts: Typography
- flutter_animate: Animations
- flutter_svg: SVG support
- cached_network_image: Image caching

### **Maps:**
- flutter_map: Interactive maps
- latlong2: Coordinates
- geolocator: Location services

---

## ✅ Best Practices

1. **Clean Architecture** - Separation of concerns
2. **BLoC Pattern** - Predictable state management
3. **Responsive First** - Design for all screen sizes
4. **Reusable Components** - DRY principle
5. **Type Safety** - Strong typing throughout
6. **Testing** - Unit, widget, and integration tests
7. **Documentation** - Clear code comments
8. **Code Generation** - Use build_runner for models

---

## 🔧 Setup Instructions

### **1. Install dependencies:**
```bash
flutter pub get
```

### **2. Generate code:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### **3. Run:**
```bash
# Mobile
flutter run

# Web
flutter run -d chrome

# Desktop
flutter run -d macos
```

---

## 📚 Code Examples

### **Responsive Page:**
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }
}
```

### **BLoC Usage:**
```dart
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is LoadingState) {
      return CircularProgressIndicator();
    }
    if (state is LoadedState) {
      return DataWidget(data: state.data);
    }
    return ErrorWidget();
  },
)
```

---

**Version:** 1.0  
**Created:** 25 January 2026  
**Maintained by:** OOH Team
