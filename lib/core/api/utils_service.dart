import 'dart:convert';
import '../../core/api/api_service.dart';


class RouteType {
  final String uuid;
  final String name;
  RouteType({required this.uuid, required this.name});
  factory RouteType.fromJson(Map<String, dynamic> j) => RouteType(
    uuid: j['uuid'] as String,
    name: j['name'] as String,
  );
}

class DifficultyType {
  final String uuid;
  final String name;
  DifficultyType({required this.uuid, required this.name});
  factory DifficultyType.fromJson(Map<String, dynamic> j) => DifficultyType(
    uuid: j['uuid'] as String,
    name: j['name'] as String,
  );
}

class TargetType {
  final String uuid;
  final String name;
  TargetType({required this.uuid, required this.name});
  factory TargetType.fromJson(Map<String, dynamic> j) => TargetType(
    uuid: j['uuid'] as String,
    name: j['name'] as String,
  );
}

class RouteTag {
  final String uuid;
  final String name;
  RouteTag({required this.uuid, required this.name});
  factory RouteTag.fromJson(Map<String, dynamic> j) => RouteTag(
    uuid: j['uuid'] as String,
    name: j['route_tag_name'] as String,
  );
}

class UtilsService {
  static Future<List<RouteType>> getRouteTypes() async {
    final resp = await ApiService.get('utils/route_types');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => RouteType.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить типы маршрутов');
  }

  static Future<List<DifficultyType>> getDifficultyTypes() async {
    final resp = await ApiService.get('utils/difficulty_types');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => DifficultyType.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить сложности');
  }

  static Future<List<TargetType>> getTargetTypes() async {
    final resp = await ApiService.get('utils/target_types');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => TargetType.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить теги');
  }

  static Future<List<RouteTag>> getRouteTags() async {
    final resp = await ApiService.get('utils/route_tags');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => RouteTag.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить теги');
  }
}
