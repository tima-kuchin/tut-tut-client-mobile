import 'dart:convert';
import 'api_service.dart';

/// Сервис для работы с профилем пользователя и связанными действиями
class UsersService {
  /// Получить данные текущего пользователя
  static Future<Map<String, dynamic>> getProfile() async {
    final resp = await ApiService.get('users/me');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Не удалось загрузить профиль (${resp.statusCode})');
  }

  /// Обновить данные профиля (кроме фото)
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final resp = await ApiService.put('users/me', body: data);
    return resp.statusCode == 200;
  }

  /// Обновить ссылку на фото профиля (через URL)
  static Future<bool> updateAvatar(String imageUrl) async {
    final resp = await ApiService.post(
      'users/me/avatar',
      body: {'profile_picture': imageUrl},
    );
    return resp.statusCode == 200;
  }

  /// Сменить пароль пользователя (требует авторизации)
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final resp = await ApiService.post(
      'auth/reset_password',
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
    return resp.statusCode == 200;
  }
}
