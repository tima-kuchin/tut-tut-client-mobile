import 'dart:convert';
import '../../models/route_card.dart';
import 'api_service.dart';

/// Сервис для получения и работы с маршрутами
class RoutesService {
  /// Получить список всех маршрутов
  static Future<List<RouteCard>> fetchRoutes() async {
    final resp = await ApiService.get('routes/');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => RouteCard.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить маршруты (${resp.statusCode})');
  }

  /// Получить список маршрутов текущего пользователя
  static Future<List<RouteCard>> fetchMyRoutes() async {
    final resp = await ApiService.get('routes/my/');
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => RouteCard.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить ваши маршруты (${resp.statusCode})');
  }

  /// Получить детали одного маршрута
  static Future<Map<String, dynamic>> fetchRouteDetail(String routeId) async {
    final resp = await ApiService.get('routes/$routeId');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Не удалось загрузить детали маршрута');
  }

  static Future<void> setRouteDraft(String routeId) async {
    final resp = await ApiService.patch('routes/$routeId/to_draft');
    if (resp.statusCode == 200) return;

    String detail = 'Ошибка перевода в черновик';
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body['detail'] != null) {
        detail = body['detail'].toString();
      }
    } catch (_) {}
    throw Exception(detail);
  }

  static Future<void> publishRoute(String routeId) async {
    final resp = await ApiService.patch('routes/$routeId/publish');
    if (resp.statusCode == 200) return;

    String detail = 'Ошибка публикации маршрута';
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body['detail'] != null) {
        detail = body['detail'].toString();
      }
    } catch (_) {}
    throw Exception(detail);
  }

  /// Удалить маршрут
  static Future<bool> deleteRoute(String routeId) async {
    final resp = await ApiService.delete('routes/$routeId');
    return resp.statusCode == 200;
  }

  /// Поиск по ключевому слову (если нужно)
  static Future<List<RouteCard>> searchRoutes(String query) async {
    final resp = await ApiService.get('routes/?search=${Uri.encodeQueryComponent(query)}');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => RouteCard.fromJson(e)).toList();
    }
    throw Exception('Поиск не удался (${resp.statusCode})');
  }

  /// Создать новый маршрут (черновик)
  static Future<String> createRoute(Map<String, dynamic> data) async {
    final resp = await ApiService.post('routes/', body: data);
    if (resp.statusCode == 201) {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return json['uuid'] as String;
    }
    throw Exception('Не удалось создать маршрут (${resp.statusCode})');
  }

  static Future<String> createDraft({
    required String name,
    String? location,
    String? description,
    required String routeTypeUuid,
    List<String>? tags,
  }) async {
    final body = {
      'name': name,
      'location': location,
      'description': description,
      'route_type_uuid': routeTypeUuid,
      'tags': tags ?? [],
      'is_public': false,
    };
    final resp = await ApiService.post('routes/', body: body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['uuid'] as String;
    }
    throw Exception('Не удалось создать черновик (${resp.statusCode})');
  }

  /// PUT /routes/{routeId} — обновить основную информацию маршрута
  static Future<bool> updateRouteInfo({
    required String routeId,
    required String name,
    String? location,
    String? description,
    required String routeTypeUuid,
    required String difficultyUuid,
    List<String>? tags,
    double? distance,
    String? thumbnailUrl,
  }) async {
    final body = {
      'name': name,
      'location': location,
      'description': description,
      'route_type_uuid': routeTypeUuid,
      'difficulty_uuid': difficultyUuid,
      'tags': tags ?? [],
    };
    if (distance != null) body["distance"] = distance;
    if (thumbnailUrl != null) body["thumbnail_url"] = thumbnailUrl;
    final resp = await ApiService.put('routes/$routeId', body: body);
    return resp.statusCode == 200;
  }

  static Future<void> likeRoute(String id) async {
    final resp = await ApiService.post('routes/$id/like');
    if (resp.statusCode != 200) throw Exception('Не удалось поставить лайк');
  }
  static Future<void> unlikeRoute(String id) async {
    final resp = await ApiService.delete('routes/$id/like');
    if (resp.statusCode != 200) throw Exception('Не удалось убрать лайк');
  }

  /// Добавить маршрут в избранное
  static Future<void> addFavorite(String id) async {
    final resp = await ApiService.post('routes/$id/favorite');
    if (resp.statusCode != 200) throw Exception('Не удалось добавить в избранное');
  }

  /// Убрать маршрут из избранного
  static Future<void> removeFavorite(String id) async {
    final resp = await ApiService.delete('routes/$id/favorite');
    if (resp.statusCode != 200) throw Exception('Не удалось убрать из избранного');
  }

  static Future<List<RouteCard>> fetchFavorites() async {
    final resp = await ApiService.get('routes/favorites/');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => RouteCard.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить избранные маршруты (${resp.statusCode})');
  }
}
