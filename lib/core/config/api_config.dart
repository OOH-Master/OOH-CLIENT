/// API configuration for the OOH Backend
class ApiConfig {
  ApiConfig._();

  /// Base URL for the API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// Timeouts in milliseconds
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // === Public endpoints ===
  static const String publicUnits = '/public/units';
  static const String publicConfig = '/public/dictionaries';
  static const String publicCities = '/public/dictionaries/cities';
  static const String publicCountries = '/public/dictionaries/countries';
  static const String publicUnitTypes = '/public/dictionaries/unit-types';
  static const String publicMediaFormats = '/public/dictionaries/media-formats';
  static const String publicVenueTypes = '/public/dictionaries/venue-types';
  static const String publicInquiries = '/public/inquiries';

  // === Auth endpoints ===
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';

  // === Profile endpoints ===
  static const String profile = '/profile';
  static const String profileChangePassword = '/profile/change-password';

  // === Admin endpoints ===
  static const String adminInquiries = '/admin/inquiries';
  static const String adminConfig = '/admin/config';
  static const String adminConfigCountries = '/admin/config/countries';
  static const String adminConfigCities = '/admin/config/cities';
  static const String adminConfigUnitTypes = '/admin/config/unit-types';
  static const String adminConfigMediaFormats = '/admin/config/media-formats';
  static const String adminConfigVenueTypes = '/admin/config/venue-types';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';

  // === Inventory endpoints ===
  static const String inventory = '/inventory';
  static const String ownerInventory = '/inventory/my';

  // === Brand endpoints ===
  static const String brandInquiries = '/brand/inquiries';
  static const String brandAnalytics = '/brand/analytics';

  // === Agency endpoints ===
  static const String agencyInquiries = '/agency/inquiries';
  static const String agencyBrands = '/agency/brands';
  static const String agencyAnalytics = '/agency/analytics';

  // === Public availability ===
  static const String publicAvailability = '/public/availability';

  // === Media Owner endpoints ===
  static const String mediaOwnerInquiries = '/media-owner/inquiries';
  static const String mediaOwnerQuotes = '/media-owner/quotes';
  static const String mediaOwnerAvailability = '/media-owner/availability';
  static const String mediaOwnerAnalytics = '/media-owner/analytics';

  // === Campaign endpoints ===
  static const String campaigns = '/campaigns';

  // === Notification endpoints ===
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String devices = '/devices';

  // === File serving ===
  static String publicFileUrl(String filename) => '/public/files/$filename';
}
