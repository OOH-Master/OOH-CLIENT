import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getLastUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedUserKey = 'CACHED_USER';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(User user) async {
    await sharedPreferences.setString(
      cachedUserKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<User?> getLastUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      return User.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(cachedUserKey);
  }
}
