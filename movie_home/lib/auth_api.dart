import 'package:dio/dio.dart';

class AuthApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 🔥 LOGIN (lấy token + basic info)
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        print("LOGIN RESPONSE: $data");

        return data; // chứa id + accessToken
      }

      return null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }

  // 🔥 NEW: LẤY FULL PROFILE (QUAN TRỌNG NHẤT)
  static Future<Map<String, dynamic>?> getUser(
      int userId, String token) async {
    try {
      final response = await _dio.get(
        '/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        print("FULL USER DATA: $data");

        return data; // chứa đầy đủ: age, hair, address...
      }

      return null;
    } catch (e) {
      print("GET USER ERROR: $e");
      return null;
    }
  }

  // 🔥 REGISTER
  static Future<bool> register(String username, String password) async {
    try {
      final response = await _dio.post(
        '/users/add',
        data: {
          'firstName': username,
          'lastName': 'User',
          'username': username,
          'password': password,
        },
      );

      print("REGISTER RESPONSE: ${response.data}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }
}