import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api/waypoints_service.dart';
import '../../core/utils/utils.dart';
import '../../models/waypoint.dart';

class RouteMapViewerScreen extends StatefulWidget {
  final String routeId;
  const RouteMapViewerScreen({Key? key, required this.routeId}) : super(key: key);

  @override
  State<RouteMapViewerScreen> createState() => _RouteMapViewerScreenState();
}

class _RouteMapViewerScreenState extends State<RouteMapViewerScreen> {
  late final MapController _mapController;
  List<Waypoint> _waypoints = [];
  bool _loading = true;
  double _zoom = 12;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadWaypoints();
  }

  Future<void> _loadWaypoints() async {
    setState(() => _loading = true);
    try {
      _waypoints = await WaypointsService.fetchWaypoints(widget.routeId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки точек')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1).clamp(2, 19);
      _mapController.move(_mapController.camera.center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1).clamp(2, 19);
      _mapController.move(_mapController.camera.center, _zoom);
    });
  }

  IconData _getMarkerIcon(String type) {
    switch (type) {
      case 'start':
        return Icons.flag;
      case 'finish':
        return Icons.outlined_flag;
      case 'isolated':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'start':
        return Colors.green;
      case 'finish':
        return Colors.red;
      case 'isolated':
        return Colors.deepPurple;
      default:
        return Colors.red;
    }
  }

  void _onWaypointTap(Waypoint wp) {
    showDialog(
      context: context,
      builder: (context) => _ViewWaypointDialog(
        waypoint: wp,
        onEdit: null,
        onDelete: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршрут на карте'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _waypoints.isNotEmpty
                  ? LatLng(_waypoints.first.lat, _waypoints.first.lng)
                  : LatLng(54, 83),
              initialZoom: _zoom,
              onTap: (tapPosition, point) {},
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.turtut.app',
              ),
              MarkerLayer(
                markers: _waypoints.map((wp) => Marker(
                  width: 44,
                  height: 44,
                  point: LatLng(wp.lat, wp.lng),
                  child: GestureDetector(
                    onTap: () => _onWaypointTap(wp),
                    child: Icon(
                      _getMarkerIcon(wp.type),
                      color: _getMarkerColor(wp.type),
                      size: 38,
                    ),
                  ),
                )).toList(),
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 44,
                      height: 44,
                      point: _userLocation!,
                      child: Icon(Icons.navigation, color: Colors.green, size: 44),
                    )
                  ],
                ),
              if (_waypoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _waypoints
                          .where((wp) => wp.type != 'isolated')
                          .map((wp) => LatLng(wp.lat, wp.lng))
                          .toList(),
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            right: 10,
            bottom: 30,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'user-location',
                  tooltip: 'Показать моё местоположение',
                  child: const Icon(Icons.my_location),
                  onPressed: () async {
                    final pos = await CoreUtils.getCurrentLocation();
                    if (pos != null) {
                      setState(() {
                        _userLocation = LatLng(pos.latitude, pos.longitude);
                      });
                      _mapController.move(_userLocation!, _zoom);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Не удалось получить геолокацию')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom-in',
                  tooltip: "Увеличить карту",
                  child: const Icon(Icons.add),
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 14),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom-out',
                  tooltip: "Уменьшить карту",
                  child: const Icon(Icons.remove),
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Диалог просмотра точки маршрута (только просмотр, без редактирования)
class _ViewWaypointDialog extends StatelessWidget {
  final Waypoint waypoint;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ViewWaypointDialog({
    required this.waypoint,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Точка маршрута',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${waypoint.lat.toStringAsFixed(6)}, ${waypoint.lng.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 10),
            if ((waypoint.description ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  waypoint.description!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            if ((waypoint.photoUrl ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  waypoint.photoUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 140,
                  errorBuilder: (ctx, err, st) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    height: 140,
                    child: const Text('Ошибка загрузки фото'),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
