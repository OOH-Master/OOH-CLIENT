import 'package:dio/dio.dart';

/// Parses validation error responses from the backend (400 with fieldErrors map)
class ValidationErrorParser {
  ValidationErrorParser._();

  /// Extract field errors map from a DioException response
  /// Returns null if the response is not a validation error
  static Map<String, String>? parseFieldErrors(DioException error) {
    if (error.response?.statusCode != 400) return null;

    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;

    final fieldErrors = data['fieldErrors'];
    if (fieldErrors is! Map<String, dynamic>) return null;

    return fieldErrors.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Extract the main error message from a DioException response
  static String? parseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
