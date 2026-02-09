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
  static const String publicConfig = '/public/dictionaries';
  static const String publicCities = '/public/dictionaries/cities';
  static const String publicCountries = '/public/dictionaries/countries';
  static const String publicUnitTypes = '/public/dictionaries/unit-types';
  static const String publicMediaFormats = '/public/dictionaries/media-formats';
  static const String publicVenueTypes = '/public/dictionaries/venue-types';

  /// Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';

  /// Public inquiry endpoints
  static const String publicInquiries = '/public/inquiries';

  /// Admin endpoints
  static const String adminInquiries = '/admin/inquiries';
  static const String adminConfig = '/admin/config';
  static const String adminConfigCountries = '/admin/config/countries';
  static const String adminConfigCities = '/admin/config/cities';
  static const String adminConfigUnitTypes = '/admin/config/unit-types';
  static const String adminConfigMediaFormats = '/admin/config/media-formats';
  static const String adminConfigVenueTypes = '/admin/config/venue-types';

  /// Inventory endpoints (authenticated)
  static const String inventory = '/inventory';
  static const String ownerInventory = '/inventory/my';

  /// Brand endpoints
  static const String brandInquiries = '/brand/inquiries';

  /// Agency endpoints
  static const String agencyInquiries = '/agency/inquiries';
  static const String agencyBrands = '/agency/brands';

  /// Campaign endpoints
  static const String campaigns = '/campaigns';
}
