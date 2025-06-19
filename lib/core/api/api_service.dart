import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  /// Базовый URL вашего FastAPI-сервера
  static const String baseUrl = 'http://10.0.2.2:8000/';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Формирует заголовки, включая Authorization, если есть токен
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET-запрос к path, возвращает http.Response
  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: headers);
  }

  /// POST-запрос к path с optional headers и телом (String или JSON)
  static Future<http.Response> post(
      String path, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    final authHeaders = await _authHeaders();
    final allHeaders = {...authHeaders, if (headers != null) ...headers};
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : jsonEncode(body);
    return http.post(uri, headers: allHeaders, body: encodedBody);
  }

  /// PUT-запрос к path с optional headers и телом
  static Future<http.Response> put(
      String path, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    final authHeaders = await _authHeaders();
    final allHeaders = {...authHeaders, if (headers != null) ...headers};
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : jsonEncode(body);
    return http.put(uri, headers: allHeaders, body: encodedBody);
  }

  /// DELETE-запрос к path
  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: headers);
  }

  /// Полная очистка всех сохранённых ключей (токенов)
  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<http.Response> patch(
      String path, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    final authHeaders = await _authHeaders();
    final allHeaders = {...authHeaders, if (headers != null) ...headers};
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body is String ? body : jsonEncode(body);
    return http.patch(uri, headers: allHeaders, body: encodedBody);
  }
}