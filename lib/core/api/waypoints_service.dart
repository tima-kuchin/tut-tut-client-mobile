import 'api_service.dart';
import '../../models/waypoint.dart';
import 'dart:convert';

class WaypointsService {
  static Future<List<Waypoint>> fetchWaypoints(String routeId) async {
    final resp = await ApiService.get('waypoints/$routeId/waypoints');
    if (resp.statusCode != 200) throw Exception('Ошибка загрузки точек');
    final List data = jsonDecode(resp.body);
    return data.map((e) => Waypoint.fromJson(e)).toList();
  }

  static Future<Waypoint> addWaypoint(String routeId, Map<String, dynamic> body) async {
    final resp = await ApiService.post('waypoints/$routeId/waypoints', body: jsonEncode(body));
    if (resp.statusCode != 200 && resp.statusCode != 201) throw Exception('Ошибка добавления точки');
    return Waypoint.fromJson(jsonDecode(resp.body));
  }

  static Future<void> deleteWaypoint(String routeId, String waypointId) async {
    final resp = await ApiService.delete('waypoints/$routeId/waypoints/$waypointId');
    if (resp.statusCode != 200) throw Exception('Ошибка удаления точки');
  }

  static Future<void> updateWaypoint(String routeId, String waypointId, Map<String, dynamic> body) async {
    final resp = await ApiService.put('waypoints/$routeId/waypoints/$waypointId', body: jsonEncode(body));
    if (resp.statusCode != 200) throw Exception('Ошибка обновления точки');
  }
}