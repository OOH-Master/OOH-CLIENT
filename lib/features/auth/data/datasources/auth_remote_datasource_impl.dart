import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import 'auth_remote_datasource.dart';
import 'auth_token_storage.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required AuthTokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<User> login(String username, String password) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authLogin,
      data: {'username': username, 'password': password},
    );

    final data = response.data!;
    await _storeTokens(data);

    // Fetch full user profile
    return _fetchCurrentUser();
  }

  @override
  Future<User> register(
    String name,
    String email,
    String password,
    Role role, {
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
    String? country,
    String? city,
  }) async {
    final data = <String, dynamic>{
      'username': name,
      'email': email,
      'password': password,
      'role': roleToString(role),
    };
    if (firstName != null && firstName.isNotEmpty) data['firstName'] = firstName;
    if (lastName != null && lastName.isNotEmpty) data['lastName'] = lastName;
    if (companyName != null && companyName.isNotEmpty) data['organizationName'] = companyName;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    if (country != null && country.isNotEmpty) data['country'] = country;
    if (city != null && city.isNotEmpty) data['city'] = city;

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authRegister,
      data: data,
    );

    final responseData = response.data!;
    await _storeTokens(responseData);

    // Fetch full user profile
    return _fetchCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiConfig.authForgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await _apiClient.post(
      ApiConfig.authResetPassword,
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConfig.authLogout);
    } catch (_) {
      // Ignore errors on logout — clear tokens regardless
    }
  }

  Future<User> _fetchCurrentUser() async {
    final meResponse = await _apiClient.get<Map<String, dynamic>>(ApiConfig.authMe);
    final meData = meResponse.data!;

    return User(
      id: meData['id'].toString(),
      email: meData['email'] ?? '',
      name: meData['username'] ?? '',
      role: mapRole(meData['role'] as String),
      companyName: meData['companyName'] as String?,
      contactPerson: meData['contactPerson'] as String?,
      firstName: meData['firstName'] as String?,
      lastName: meData['lastName'] as String?,
      phone: meData['phone'] as String?,
      country: meData['country'] as String?,
      city: meData['city'] as String?,
      website: meData['website'] as String?,
      emailVerified: meData['emailVerified'] as bool? ?? false,
    );
  }

  Future<void> _storeTokens(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final refreshToken = data['refreshToken'] as String?;

    await _tokenStorage.saveToken(token);
    _apiClient.setAuthToken(token);

    if (refreshToken != null) {
      await _tokenStorage.saveRefreshToken(refreshToken);
    }
  }

  static Role mapRole(String roleStr) {
    switch (roleStr) {
      case 'MEDIA_OWNER':
        return Role.mediaOwner;
      case 'BRAND':
        return Role.brand;
      case 'AGENCY':
        return Role.agency;
      case 'INTERNAL_ADMIN':
        return Role.admin;
      default:
        return Role.brand;
    }
  }

  static String roleToString(Role role) {
    switch (role) {
      case Role.mediaOwner:
        return 'MEDIA_OWNER';
      case Role.brand:
        return 'BRAND';
      case Role.agency:
        return 'AGENCY';
      case Role.admin:
        return 'INTERNAL_ADMIN';
    }
  }
}
