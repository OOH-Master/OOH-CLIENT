/// API configuration for the OOH Backend
class ApiConfig {
  ApiConfig._();

  /// Base URL for the API
  /// In development, use localhost or local IP
  /// In production, use the actual server URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;

  /// Public endpoints (no auth required)
  static const String publicUnits = '/public/units';
  static const String publicConfig = '/public/config';
  static const String publicCities = '/public/config/cities';
  static const String publicCountries = '/public/config/countries';
  static const String publicUnitTypes = '/public/config/unit-types';
  static const String publicMediaFormats = '/public/config/media-formats';
  static const String publicVenueTypes = '/public/config/venue-types';

  /// Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';

  /// Public inquiry endpoints
  static const String publicInquiries = '/public/inquiries';
}
