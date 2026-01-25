# Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Tools

- **Flutter SDK**: Version 3.38.2 or higher
  ```bash
  flutter --version
  ```

- **Dart SDK**: Version 3.10.0 or higher (included with Flutter)
  ```bash
  dart --version
  ```

- **Git**: For version control
  ```bash
  git --version
  ```

### Platform-Specific Requirements

#### Web Development
- **Chrome Browser**: Latest stable version
- No additional setup required

#### Android Development
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 (Android 5.0) or higher
- **Java Development Kit (JDK)**: Version 11 or higher

#### iOS Development (macOS only)
- **Xcode**: Version 13.0 or higher
- **CocoaPods**: Latest version
  ```bash
  sudo gem install cocoapods
  ```
- **iOS Simulator**: Included with Xcode

#### macOS Development
- **Xcode**: Version 13.0 or higher
- **macOS**: Version 10.14 (Mojave) or higher

#### Linux Development
- **Linux Distribution**: Ubuntu 20.04 LTS or equivalent
- **Required packages**:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

#### Windows Development
- **Visual Studio 2022**: With "Desktop development with C++" workload
- **Windows 10**: Version 1809 or higher

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/OOH-Master/OOH-CLIENT.git
cd ooh_mobile
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This command downloads all the packages specified in `pubspec.yaml`.

### 3. Generate Localization Files

```bash
flutter gen-l10n
```

This generates Dart files from ARB localization files in `lib/core/l10n/`.

### 4. Verify Installation

```bash
flutter doctor -v
```

This command checks your environment and displays a report of the status of your Flutter installation. Fix any issues indicated by the report.

## Running the Application

### Web

#### Development Mode
```bash
flutter run -d chrome
```

#### Production Build
```bash
flutter build web --release
cd build/web
python3 -m http.server 8000
```

Access the app at `http://localhost:8000`

#### Custom Port
```bash
flutter run -d chrome --web-port 8080
```

### Android

#### Prerequisites
1. **Enable USB Debugging** on your Android device (Settings → Developer options → USB debugging)
2. **Connect device** via USB or use an emulator

#### List Available Devices
```bash
flutter devices
```

#### Run on Physical Device
```bash
flutter run -d <device-id>
```

#### Run on Emulator
```bash
# Start an emulator
flutter emulators --launch <emulator-id>

# Run the app
flutter run -d android
```

#### Build APK (Debug)
```bash
flutter build apk --debug
```

#### Build APK (Release)
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

The bundle will be located at: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### Prerequisites
1. **Apple Developer Account** (for running on physical devices)
2. **Xcode** installed with command line tools
3. **CocoaPods** installed

#### Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

#### Run on Simulator
```bash
# List simulators
flutter emulators

# Launch simulator
open -a Simulator

# Run the app
flutter run -d ios
```

#### Run on Physical Device
1. **Open Xcode project**: `open ios/Runner.xcworkspace`
2. **Select your team** in Signing & Capabilities
3. **Connect your iOS device**
4. **Run**:
   ```bash
   flutter run -d <device-id>
   ```

#### Build IPA (Release)
```bash
flutter build ios --release
```

Then archive and distribute through Xcode.

### macOS

#### Enable macOS Support
```bash
flutter config --enable-macos-desktop
```

#### Run Application
```bash
flutter run -d macos
```

#### Build Application
```bash
flutter build macos --release
```

The app bundle will be located at: `build/macos/Build/Products/Release/ooh_mobile.app`

### Linux

#### Enable Linux Support
```bash
flutter config --enable-linux-desktop
```

#### Run Application
```bash
flutter run -d linux
```

#### Build Application
```bash
flutter build linux --release
```

The executable will be located at: `build/linux/x64/release/bundle/`

### Windows

#### Enable Windows Support
```bash
flutter config --enable-windows-desktop
```

#### Run Application
```bash
flutter run -d windows
```

#### Build Application
```bash
flutter build windows --release
```

The executable will be located at: `build/windows/runner/Release/`

## Development Workflow

### Hot Reload

While the app is running, press `r` in the terminal to hot reload:
```
r  Hot reload. 🔥🔥🔥
```

Hot reload preserves app state and applies code changes instantly.

### Hot Restart

Press `R` (capital) for a full restart:
```
R  Hot restart.
```

Hot restart resets app state and rebuilds the widget tree.

### Debugging

#### Enable Debug Mode
Debug mode is enabled by default when running with `flutter run`.

#### Debug in VS Code
1. Install **Flutter** and **Dart** extensions
2. Open `lib/main.dart`
3. Press `F5` or click "Run and Debug"
4. Set breakpoints by clicking on line numbers

#### Debug in Android Studio
1. Install **Flutter** and **Dart** plugins
2. Open the project
3. Click the debug icon or press `Shift+F9`
4. Set breakpoints by clicking on line gutters

#### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then while the app is running, open the DevTools URL shown in the terminal.

## Environment Configuration

### API Configuration

Create environment-specific configuration files:

#### Development
```dart
// lib/core/config/env_dev.dart
class Environment {
  static const String apiUrl = 'http://localhost:8080/api';
  static const bool isProduction = false;
}
```

#### Production
```dart
// lib/core/config/env_prod.dart
class Environment {
  static const String apiUrl = 'https://api.ooh-platform.com/api';
  static const bool isProduction = true;
}
```

### Build Flavors (Optional)

#### Android Flavors
Edit `android/app/build.gradle`:

```gradle
android {
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        prod {
            dimension "environment"
        }
    }
}
```

Run with flavor:
```bash
flutter run --flavor dev
flutter build apk --flavor prod
```

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

View coverage report:
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test integration_test/app_test.dart
```

## Code Quality

### Linting
```bash
flutter analyze
```

### Formatting
```bash
# Check formatting
dart format --output=none --set-exit-if-changed .

# Apply formatting
dart format lib/ test/
```

### Fix Common Issues
```bash
dart fix --apply
```

## Performance Profiling

### Profile Mode
```bash
flutter run --profile
```

### Build Mode Comparison
- **Debug**: Slow performance, full debugging features
- **Profile**: Optimized performance, some debugging features
- **Release**: Maximum performance, no debugging

### Measure Performance
```bash
flutter run --profile --trace-startup
```

## Troubleshooting

### Clear Build Cache
```bash
flutter clean
flutter pub get
flutter run
```

### Reset Flutter
```bash
flutter channel stable
flutter upgrade
flutter doctor
```

### Android Build Issues

#### Gradle Sync Failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Multi-Dex Issue
Add to `android/app/build.gradle`:
```gradle
defaultConfig {
    multiDexEnabled true
}
```

### iOS Build Issues

#### Pod Install Failed
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

#### Xcode Build Failed
1. Open `ios/Runner.xcworkspace` in Xcode
2. Clean build folder: `Product → Clean Build Folder`
3. Build again: `Product → Build`

### Web Build Issues

#### CanvasKit Error
Try using HTML renderer:
```bash
flutter run -d chrome --web-renderer html
```

## IDE Setup

### VS Code

#### Recommended Extensions
- **Flutter** (by Dart Code)
- **Dart** (by Dart Code)
- **Bloc** (by FelixAngelov)
- **Error Lens** (by Alexander)
- **GitLens** (by GitKraken)

#### Settings (.vscode/settings.json)
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.lineLength": 100
}
```

### Android Studio

#### Recommended Plugins
- **Flutter**
- **Dart**
- **Bloc**
- **Rainbow Brackets**
- **GitToolBox**

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)
- [BLoC Library](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

**Need help?** Create an issue on GitHub or contact the development team.
