# OOH Mobile Application

**Out-of-Home (OOH) Advertising Platform** - Flutter Mobile Application

## 📱 Overview

OOH Mobile is a cross-platform mobile application built with Flutter for managing and discovering Out-of-Home advertising spaces. This app provides a comprehensive platform for advertisers, media owners, and agencies to browse, book, and manage OOH advertising units.

### Key Features

- **🔍 Discover** - Browse and search through OOH advertising units
- **🗺️ Map View** - Interactive map to visualize OOH unit locations
- **👤 Profile** - User profile and account management
- **🌐 Multi-language** - Supports English and Serbian
- **🎨 Modern UI** - Material Design 3 with custom theme system
- **📱 Responsive** - Adaptive layouts for mobile, tablet, and web

## 🏗️ Architecture

This project follows **Clean Architecture** with **Feature-First** organization:

```
lib/
├── app/               # App initialization, DI, routing
├── core/              # Shared utilities, themes, widgets
└── features/          # Feature modules (auth, discover, map, etc.)
    └── [feature]/
        ├── data/      # Data sources, repositories
        ├── domain/    # Entities, use cases
        └── presentation/  # Pages, widgets, BLoCs
```

For detailed architecture information, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.38.2+
- Dart SDK 3.10.0+
- VS Code or Android Studio
- Chrome (for web development)
- Xcode (for iOS development on macOS)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/OOH-Master/OOH-CLIENT.git
   cd ooh_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # macOS
   flutter run -d macos
   ```

For detailed setup instructions, see [SETUP.md](docs/SETUP.md).

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Detailed architecture and project structure
- **[SETUP.md](docs/SETUP.md)** - Platform-specific setup instructions
- **[STYLING.md](docs/STYLING.md)** - Theme system, responsive design, spacing
- **[WIDGETS.md](docs/WIDGETS.md)** - Reusable widget library documentation

## 🎨 Design System

### Colors
- **Primary**: Indigo (#6366F1)
- **Background**: White (#FFFFFF)
- **Foreground**: Gray-900 (#111827)
- **Accent**: Indigo-50 (#F5F6FF)

### Typography
- **Font Family**: Space Grotesk
- **Scale**: Display (72px) → Label Small (12px)

### Spacing
- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px
- **2xl**: 48px
- **3xl**: 64px

See [STYLING.md](docs/STYLING.md) for complete design system documentation.

## 🌍 Localization

Supported languages:
- 🇺🇸 English (en)
- 🇷🇸 Serbian (sr)

Localization files are located in `lib/core/l10n/` and use Flutter's built-in ARB format.

## 📦 Key Dependencies

- **flutter_bloc** (^8.1.9) - State management
- **go_router** (^17.0.0) - Navigation and routing
- **get_it** (^8.0.3) - Dependency injection
- **dio** (^5.4.0) - HTTP client
- **flutter_animate** (^4.5.2) - Animations
- **google_fonts** (^6.2.1) - Typography

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📱 Supported Platforms

- ✅ Web (Chrome, Safari, Firefox, Edge)
- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ macOS (10.14+)
- ✅ Linux
- ✅ Windows

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 🔗 Related Projects

- **[OOH-WEB-APP](https://github.com/OOH-Master/OOH-WEB-APP)** - React web application
- **[OOH-API](https://github.com/OOH-Master/OOH-API)** - Spring Boot backend API

## 📞 Support

For support, email [support@ooh-platform.com](mailto:support@ooh-platform.com) or create an issue in this repository.

---

**Made with ❤️ using Flutter**
