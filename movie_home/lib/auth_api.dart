import 'package:dio/dio.dart';

class AuthApi {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'https://dummyjson.com';

  // Đăng nhập
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data; 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Đăng ký
  static Future<bool> register(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/users/add',
        data: {
          'firstName': username,
          'lastName': 'User',
          'username': username,
          'password': password,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}