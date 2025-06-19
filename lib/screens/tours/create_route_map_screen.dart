import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api/waypoints_service.dart';
import '../../core/utils/utils.dart';
import '../../models/waypoint.dart';

enum WaypointTool { move, connected, isolated }

class EditRouteMapScreen extends StatefulWidget {
  final String routeId;
  const EditRouteMapScreen({Key? key, required this.routeId}) : super(key: key);

  @override
  State<EditRouteMapScreen> createState() => _EditRouteMapScreenState();
}

class _EditRouteMapScreenState extends State<EditRouteMapScreen> {
  late final MapController _mapController;
  List<Waypoint> _waypoints = [];
  bool _loading = true;
  double _zoom = 12;
  WaypointTool _tool = WaypointTool.move;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadWaypoints();
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

  void _onMapTap(LatLng point) async {
    if (_tool == WaypointTool.move) return;
    final type = _tool == WaypointTool.connected ? 'intermediate' : 'isolated';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddWaypointDialog(
        lat: point.latitude,
        lng: point.longitude,
        type: type,
      ),
    );
    if (result != null) {
      try {
        await WaypointsService.addWaypoint(widget.routeId, result);
        await _loadWaypoints();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка добавления точки')),
        );
      }
    }
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
      case 'start': return Colors.green;
      case 'finish': return Colors.red;
      case 'isolated': return Colors.deepPurple;
      default: return Colors.red;
    }
  }

  void _onWaypointTap(Waypoint wp) async {
    showDialog(
      context: context,
      builder: (context) => _ViewWaypointDialog(
        waypoint: wp,
        onEdit: () async {
          Navigator.pop(context);
          final updated = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => _EditWaypointDialog(waypoint: wp),
          );
          if (updated != null) {
            try {
              await WaypointsService.updateWaypoint(widget.routeId, wp.uuid, updated);
              await _loadWaypoints();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка обновления точки')),
              );
            }
          }
        },
        onDelete: () async {
          try {
            await WaypointsService.deleteWaypoint(widget.routeId, wp.uuid);
            Navigator.pop(context);
            await _loadWaypoints();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка удаления точки')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать точки')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _waypoints.isNotEmpty
                  ? LatLng(_waypoints.first.lat, _waypoints.first.lng)
                  : LatLng(54, 83),
              initialZoom: _zoom,
              onTap: (tapPosition, point) => _onMapTap(point),
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
                _ToolIconButton(
                  icon: Icons.pan_tool_alt,
                  selected: _tool == WaypointTool.move,
                  onTap: () => setState(() => _tool = WaypointTool.move),
                  tooltip: "Двигать",
                ),
                const SizedBox(height: 14),
                _ToolIconButton(
                  icon: Icons.timeline,
                  selected: _tool == WaypointTool.connected,
                  onTap: () => setState(() => _tool = WaypointTool.connected),
                  tooltip: "Соединённая точка",
                ),
                const SizedBox(height: 14),
                _ToolIconButton(
                  icon: Icons.place_outlined,
                  selected: _tool == WaypointTool.isolated,
                  onTap: () => setState(() => _tool = WaypointTool.isolated),
                  tooltip: "Отдельная точка",
                ),
                const SizedBox(height: 24),
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

/// Диалог добавления точки
class _AddWaypointDialog extends StatefulWidget {
  final double lat, lng;
  final String type;

  const _AddWaypointDialog({
    required this.lat,
    required this.lng,
    required this.type,
  });

  @override
  State<_AddWaypointDialog> createState() => _AddWaypointDialogState();
}

class _AddWaypointDialogState extends State<_AddWaypointDialog> {
  final _descCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить точку'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Широта: ${widget.lat.toStringAsFixed(6)}'),
          Text('Долгота: ${widget.lng.toStringAsFixed(6)}'),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Описание'),
          ),
          TextField(
            controller: _photoCtrl,
            decoration: const InputDecoration(labelText: 'URL фото'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              "lat": widget.lat,
              "lon": widget.lng,
              "type": widget.type,
              "description": _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
              "photo_url": _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
            });
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}

class _EditWaypointDialog extends StatefulWidget {
  final Waypoint waypoint;
  const _EditWaypointDialog({required this.waypoint});

  @override
  State<_EditWaypointDialog> createState() => _EditWaypointDialogState();
}

class _EditWaypointDialogState extends State<_EditWaypointDialog> {
  late TextEditingController _descCtrl;
  late TextEditingController _photoCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.waypoint.description ?? '');
    _photoCtrl = TextEditingController(text: widget.waypoint.photoUrl ?? '');
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать точку'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Широта: ${widget.waypoint.lat.toStringAsFixed(6)}'),
          Text('Долгота: ${widget.waypoint.lng.toStringAsFixed(6)}'),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Описание'),
          ),
          TextField(
            controller: _photoCtrl,
            decoration: const InputDecoration(labelText: 'URL фото'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              "description": _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
              "photo_url": _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
            });
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

/// Просмотр точки (можно добавить кнопку редактирования)
class _ViewWaypointDialog extends StatelessWidget {
  final Waypoint waypoint;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _ViewWaypointDialog({
    required this.waypoint,
    this.onDelete,
    this.onEdit,
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
            ElevatedButton(
              onPressed: onEdit ?? () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Редактирование сломалось")));
              },
              child: const Text('Редактировать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (onDelete != null)
              TextButton(
                onPressed: onDelete,
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}


class _ToolIconButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
  const _ToolIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.blueAccent : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: IconButton(
        icon: Icon(icon, color: selected ? Colors.white : Colors.black, size: 28),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }
}