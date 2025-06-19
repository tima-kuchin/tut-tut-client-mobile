import 'dart:convert';

import '../../models/comment.dart';
import '../api/api_service.dart';

class CommentsService {
  /// Получение комментариев по targetType (например, 'route') и uuid сущности.
  static Future<List<Comment>> fetchComments(String targetType, String targetUuid) async {
    final response = await ApiService.get('comments/$targetType/$targetUuid');
    if (response.statusCode == 200) {
      final data = response.body == '' ? [] : (jsonDecode(response.body) as List);
      return data.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки комментариев');
    }
  }

  /// Создать комментарий
  static Future<Comment> createComment(String targetType, String targetUuid, String text) async {
    final response = await ApiService.post(
      'comments/$targetType/$targetUuid',
      body: {'comment_text': text},
    );
    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания комментария');
    }
  }

  /// Лайк/анлайк
  static Future<void> likeComment(String commentUuid) async {
    final response = await ApiService.post('comments/$commentUuid/like');
    if (response.statusCode != 200) {
      throw Exception('Ошибка лайка');
    }
  }

  static Future<void> unlikeComment(String commentUuid) async {
    final response = await ApiService.delete('comments/$commentUuid/like');
    if (response.statusCode != 200) {
      throw Exception('Ошибка снятия лайка');
    }
  }

  /// Удалить комментарий
  static Future<void> deleteComment(String commentUuid) async {
    final response = await ApiService.delete('comments/$commentUuid');
    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления комментария');
    }
  }
}
