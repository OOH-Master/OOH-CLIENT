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
    final token = data['token'] as String;

    // Store token and set on ApiClient
    await _tokenStorage.saveToken(token);
    _apiClient.setAuthToken(token);

    // Fetch full user profile
    final meResponse = await _apiClient.get<Map<String, dynamic>>(ApiConfig.authMe);
    final meData = meResponse.data!;

    return User(
      id: meData['id'].toString(),
      email: meData['email'] ?? '',
      name: meData['username'] ?? '',
      role: mapRole(meData['role'] as String),
      companyName: meData['companyName'] as String?,
      contactPerson: meData['contactPerson'] as String?,
    );
  }

  @override
  Future<User> register(String name, String email, String password, Role role) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'username': name,
        'email': email,
        'password': password,
        'role': _roleToString(role),
      },
    );

    final data = response.data!;
    final token = data['token'] as String;

    await _tokenStorage.saveToken(token);
    _apiClient.setAuthToken(token);

    // Fetch full user profile
    final meResponse = await _apiClient.get<Map<String, dynamic>>(ApiConfig.authMe);
    final meData = meResponse.data!;

    return User(
      id: meData['id'].toString(),
      email: meData['email'] ?? email,
      name: meData['username'] ?? name,
      role: mapRole(meData['role'] as String),
      companyName: meData['companyName'] as String?,
      contactPerson: meData['contactPerson'] as String?,
    );
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

  static String _roleToString(Role role) {
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
