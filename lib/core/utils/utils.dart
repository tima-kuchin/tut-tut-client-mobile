import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class CoreUtils {
  static String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd.MM.yyyy HH:mm').format(dt);
    } catch (e) {
      return raw;
    }
  }

  static String? extractApiError(dynamic e) {
    if (e is String) return e;
    try {
      final data = e?.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return e.toString();
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Вычисляет длину маршрута по списку точек [lat, lng] (в метрах)
  static double calculateRouteDistance(List<List<double>> points) {
    double total = 0;
    const R = 6371.0;
    for (int i = 1; i < points.length; i++) {
      final lat1 = points[i - 1][0] * pi / 180;
      final lon1 = points[i - 1][1] * pi / 180;
      final lat2 = points[i][0] * pi / 180;
      final lon2 = points[i][1] * pi / 180;
      final dlat = lat2 - lat1;
      final dlon = lon2 - lon1;
      final a = sin(dlat / 2) * sin(dlat / 2) +
          cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      total += R * c;
    }
    return double.parse(total.toStringAsFixed(2));
  }
}
