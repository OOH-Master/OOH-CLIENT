# Code Improvements & Future Enhancements

## Overview

This document outlines identified areas for improvement, technical debt, and future enhancement opportunities for the OOH Mobile application.

## Code Quality Improvements

### 1. Error Handling

**Current State**: Basic try-catch blocks
**Recommendation**: Implement comprehensive error handling with Either<Failure, Success> pattern

**Example Implementation**:
```dart
// Current
try {
  final result = await api.getData();
  return result;
} catch (e) {
  throw Exception(e.toString());
}

// Improved
Future<Either<Failure, Data>> getData() async {
  try {
    final result = await api.getData();
    return Right(result);
  } on NetworkException {
    return Left(NetworkFailure());
  } on ServerException {
    return Left(ServerFailure());
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

**Files to Update**:
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/discover/data/repositories/ooh_repository_impl.dart`

### 2. API Integration

**Current State**: Mock data sources
**Recommendation**: Implement real API integration with Dio

**Implementation Steps**:
1. Create API client configuration
2. Define API endpoints constants
3. Implement real remote data sources
4. Add request/response interceptors
5. Implement token refresh mechanism

**Files to Create**:
- `lib/core/network/api_client.dart`
- `lib/core/network/api_endpoints.dart`
- `lib/core/network/interceptors/auth_interceptor.dart`
- `lib/core/network/interceptors/logging_interceptor.dart`

**Example**:
```dart
class ApiClient {
  final Dio dio;
  
  ApiClient(this.dio) {
    dio.options.baseUrl = Environment.apiUrl;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    
    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }
}
```

### 3. State Management Optimization

**Current State**: Basic BLoC implementation
**Recommendations**:
- Add Equatable to states and events for better comparison
- Implement proper loading states
- Add pagination support
- Cache previous states for offline support

**Example**:
```dart
// Add Equatable
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  final bool isInitialLoad;
  
  const AuthLoading({this.isInitialLoad = false});
  
  @override
  List<Object?> get props => [isInitialLoad];
}
```

### 4. Form Validation

**Current State**: Inline validators
**Recommendation**: Create reusable validation utility

**Implementation**:
```dart
// lib/core/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }
}
```

## Performance Optimizations

### 1. Image Optimization

**Recommendations**:
- Implement lazy loading for images
- Add caching for remote images using `cached_network_image`
- Optimize image sizes for different screen densities

**Implementation**:
```dart
// pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1

// Usage
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

### 2. List Rendering

**Current State**: Basic ListView
**Recommendations**:
- Implement infinite scroll with pagination
- Add pull-to-refresh
- Use AutomaticKeepAliveClientMixin for preserving state

**Example**:
```dart
class DiscoverPage extends StatefulWidget {
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: _buildItem,
      ),
    );
  }
}
```

### 3. Animation Optimization

**Recommendations**:
- Use `RepaintBoundary` for complex widgets
- Implement `const` constructors wherever possible
- Use `AnimatedBuilder` instead of `setState` for animations

## Feature Enhancements

### 1. Offline Support

**Priority**: High

**Implementation**:
- Add local database (Hive or Drift)
- Cache API responses
- Implement sync mechanism
- Show offline indicator

**Files to Create**:
```
lib/core/database/
├── app_database.dart
├── models/
│   ├── cached_ooh_unit.dart
│   └── cached_user.dart
└── dao/
    ├── ooh_unit_dao.dart
    └── user_dao.dart
```

### 2. Search Functionality

**Priority**: High

**Features**:
- Full-text search
- Search history
- Search suggestions
- Filters and sorting

**Implementation Location**:
- `lib/features/search/`

### 3. Favorites/Bookmarks

**Priority**: Medium

**Features**:
- Save favorite OOH units
- Sync across devices
- Collections/folders

**Implementation Location**:
- `lib/features/favorites/`

### 4. Map Integration

**Priority**: High

**Features**:
- Google Maps / Mapbox integration
- Cluster markers
- Location-based search
- Direction navigation

**Dependencies**:
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
```

### 5. Push Notifications

**Priority**: Medium

**Features**:
- Firebase Cloud Messaging
- In-app notifications
- Notification preferences

**Dependencies**:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
```

### 6. Analytics & Tracking

**Priority**: Medium

**Features**:
- Firebase Analytics
- Custom event tracking
- User behavior analysis
- Crash reporting

**Dependencies**:
```yaml
dependencies:
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.8
```

### 7. Dark Mode

**Priority**: Low

**Implementation**:
- Complete dark theme colors (partially done)
- Theme switching UI
- Persist user preference
- Automatic theme based on system

### 8. Multi-tenancy Support

**Priority**: Medium

**Features**:
- Support for multiple organizations
- Role-based access control
- Organization switching

## Testing Improvements

### 1. Unit Tests

**Current Coverage**: ~0%
**Target**: >80%

**Priority Areas**:
- Domain use cases
- BLoC logic
- Utility functions
- Validators

**Example**:
```dart
// test/features/auth/domain/usecases/login_usecase_test.dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });
  
  test('should return User when login is successful', () async {
    // Arrange
    final user = User(id: 1, email: 'test@test.com');
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Right(user));
    
    // Act
    final result = await useCase('test@test.com', 'password');
    
    // Assert
    expect(result, Right(user));
  });
}
```

### 2. Widget Tests

**Priority Areas**:
- Custom widgets
- Form validation
- Navigation flows
- State changes

### 3. Integration Tests

**Priority Areas**:
- Login/Logout flow
- OOH unit browsing
- Search functionality
- Navigation between pages

## Security Enhancements

### 1. Secure Storage

**Recommendation**: Use `flutter_secure_storage` for sensitive data

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

**Implementation**:
```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
```

### 2. Certificate Pinning

**Recommendation**: Implement SSL pinning for API calls

```dart
dio.httpClientAdapter = IOHttpClientAdapter()
  ..onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) {
      return cert.sha256 == expectedCertificateHash;
    };
    return client;
  };
```

### 3. Input Sanitization

**Recommendation**: Sanitize all user inputs before processing

## Accessibility Improvements

### 1. Screen Reader Support

**Recommendations**:
- Add Semantics widgets
- Proper labels for interactive elements
- Announcement messages

**Example**:
```dart
Semantics(
  label: 'Login button',
  button: true,
  onTap: _handleLogin,
  child: ElevatedButton(
    onPressed: _handleLogin,
    child: Text('Login'),
  ),
)
```

### 2. Keyboard Navigation

**Recommendations**:
- Proper focus management
- Tab order
- Keyboard shortcuts

### 3. Color Contrast

**Current State**: Good contrast ratios
**Recommendation**: Validate all color combinations meet WCAG AA standards

## Documentation Improvements

### 1. Code Documentation

**Recommendations**:
- Add DartDoc comments for public APIs
- Document complex algorithms
- Add usage examples

**Example**:
```dart
/// Authenticates a user with email and password.
///
/// Returns a [User] object if authentication is successful,
/// or throws an [AuthException] if authentication fails.
///
/// Example:
/// ```dart
/// final user = await authRepository.login('email@example.com', 'password');
/// ```
Future<User> login(String email, String password);
```

### 2. README Updates

**Recommendations**:
- Add troubleshooting section
- Include screenshots
- Add contribution guidelines
- Document environment variables

## CI/CD Implementation

### 1. GitHub Actions Workflow

**Recommendations**:
- Automated testing on PR
- Build verification
- Code coverage reports
- Automated deployment

**Example Workflow**:
```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build web
```

### 2. Automated Versioning

**Recommendations**:
- Semantic versioning
- Automated changelog generation
- Version bumping on release

## Monitoring & Logging

### 1. Structured Logging

**Recommendation**: Implement structured logging with levels

```dart
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
  
  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

### 2. Performance Monitoring

**Recommendations**:
- Firebase Performance Monitoring
- Custom performance traces
- Network request monitoring

## Internationalization Improvements

### 1. Additional Languages

**Current**: English, Serbian
**Recommendations**: Add more languages based on target markets

### 2. Date & Number Formatting

**Recommendations**:
- Use `intl` package for formatting
- Locale-aware date/time display
- Currency formatting

## Priority Matrix

| Improvement | Priority | Effort | Impact |
|-------------|----------|--------|--------|
| API Integration | High | Medium | High |
| Offline Support | High | High | High |
| Search Functionality | High | Medium | High |
| Unit Tests | High | High | Medium |
| Map Integration | High | High | High |
| Error Handling | Medium | Low | High |
| Push Notifications | Medium | Medium | Medium |
| Analytics | Medium | Low | Medium |
| Dark Mode | Low | Low | Low |

## Conclusion

This document serves as a roadmap for improving the OOH Mobile application. Prioritize high-impact, low-effort improvements first, then work towards more complex enhancements.

**Next Steps**:
1. Review and prioritize improvements with team
2. Create GitHub issues for each improvement
3. Plan sprint work based on priorities
4. Track progress in project board

---

**Maintained by**: Development Team  
**Last Updated**: January 2026
