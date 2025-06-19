import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static const _registerPath = 'auth/register';
  static const _loginPath    = 'auth/login';
  static const _refreshPath  = 'auth/refresh';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();


  static Future<bool> register(Map<String, dynamic> userData) async {
    final uri = Uri.parse('${ApiService.baseUrl}$_registerPath');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }


  static Future<bool> login(String username, String password) async {
    final uri = Uri.parse('${ApiService.baseUrl}$_loginPath');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token',  value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      return true;
    }
    return false;
  }


  static Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;

    final uri = Uri.parse('${ApiService.baseUrl}$_refreshPath');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'refresh_token': refresh},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      return true;
    }
    return false;
  }


  static Future<http.Response> forgotPasswordRequest(String email) async {
    final uri = Uri.parse('${ApiService.baseUrl}auth/forgot_password');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }


  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}