import 'package:flutter/material.dart';
import '../../components/comments_section.dart';
import '../../core/api/routes_service.dart';
import '../../core/api/utils_service.dart';
import '../../core/utils/utils.dart';
import 'route_map_viewer_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeId;
  const RouteDetailScreen({Key? key, required this.routeId}) : super(key: key);

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  Map<String, dynamic>? _route;
  bool _loading = true;
  String? _error;
  Map<String, String> _tagsMap = {};

  bool _favoriteLoading = false;
  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final routeFuture = RoutesService.fetchRouteDetail(widget.routeId);
      final tagsFuture = UtilsService.getRouteTags();
      final results = await Future.wait([routeFuture, tagsFuture]);
      _route = results[0] as Map<String, dynamic>;
      final tagList = results[1] as List<RouteTag>;
      _tagsMap = {for (final tag in tagList) tag.uuid: tag.name};
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_route == null) return;
    setState(() => _favoriteLoading = true);
    final nowFavorite = !(_route!['is_favorite'] as bool? ?? false);

    try {
      if (nowFavorite) {
        await RoutesService.addFavorite(widget.routeId);
      } else {
        await RoutesService.removeFavorite(widget.routeId);
      }
      setState(() {
        _route!['is_favorite'] = nowFavorite;
      });
    } catch (e) {} finally {
      setState(() => _favoriteLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_route == null) return;
    setState(() => _likeLoading = true);

    final nowLiked = !(_route!['is_liked'] as bool? ?? false);

    try {
      if (nowLiked) {
        await RoutesService.likeRoute(widget.routeId);
      } else {
        await RoutesService.unlikeRoute(widget.routeId);
      }
      setState(() {
        _route!['is_liked'] = nowLiked;
        final currentCount = (_route!['likes_count'] as int? ?? 0);
        _route!['likes_count'] = nowLiked ? currentCount + 1 : currentCount - 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при ${nowLiked ? 'постановке' : 'снятии'} лайка')),
      );
    } finally {
      setState(() => _likeLoading = false);
    }
  }

  void _viewOnMap() {
    final waypoints = _route?['waypoints'] as List<dynamic>? ?? [];
    if (waypoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет точек маршрута для отображения на карте')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteMapViewerScreen(routeId: widget.routeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text('Ошибка: $_error')));
    }
    final r = _route!;
    final tagsUuids = (r['tags'] as List<dynamic>? ?? []).cast<String>();
    final tagsNames = tagsUuids.map((uuid) => _tagsMap[uuid] ?? uuid).toList();

    final created = r['created_at'] as String? ?? '';
    final edited = r['edited_at'] as String? ?? '';
    final showEdited = edited.isNotEmpty && edited != created;
    String getDistance() =>
        r['distance'] != null ? '${r['distance'].toString()} км' : '–';
    String getDuration() =>
        r['duration'] != null ? '${r['duration'].toString()} ч' : '–';
    String getType() => r['route_type_name'] ?? '–';

    Widget infoChip({required String text, Color? color}) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          foregroundColor: Colors.black87,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(r['name'] ?? '', overflow: TextOverflow.ellipsis),
        actions: [
          if (r['can_edit'] == true)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Редактировать маршрут',
              onPressed: () {
                Navigator.pushNamed(
                  context, '/edit_route_info',
                  arguments: widget.routeId,
                ).then((_) => _fetchAll());
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 210,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEFEF),
                  ),
                  child: r['thumbnail_url'] != null
                      ? Image.network(r['thumbnail_url'], fit: BoxFit.cover)
                      : Image.asset('assets/images/route_placeholder.jpg', fit: BoxFit.cover),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _viewOnMap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.map, size: 18),
                        SizedBox(width: 6),
                        Text("На карту", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['name'] ?? '', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if ((r['location'] as String?)?.isNotEmpty ?? false)
                    Text(r['location'], style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      infoChip(
                        text: '★ ${r['avg_rating'] != null ? (r['avg_rating'] as num).toStringAsFixed(1) : '–'}',
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 8),
                      infoChip(
                        text: '📏 ${getDistance()}',
                      ),
                      const SizedBox(width: 8),
                      infoChip(
                        text: getType(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if ((r['description'] as String?)?.isNotEmpty ?? false)
                    Text(r['description'], style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 20),
                  Text(
                    'Создано: ${CoreUtils.formatDate(r['created_at'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (showEdited) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Изменено: ${CoreUtils.formatDate(r['edited_at'])}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                  Text(
                    'Автор: ${r['creator_login'] ?? ""}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (tagsNames.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: tagsNames.map((name) => OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.green[50],
                          shape: const StadiumBorder(),
                        ),
                        child: Text('#$name', style: const TextStyle(color: Colors.green)),
                      )).toList(),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            (r['is_liked'] ?? false) ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: _likeLoading ? null : _toggleLike,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            (r['is_favorite'] ?? false) ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed: _favoriteLoading ? null : _toggleFavorite,
                        ),
                      ),
                      const Expanded(
                        child: IconButton(
                          icon: Icon(Icons.share, color: Colors.blueGrey, size: 28),
                          onPressed: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CommentSection(
                    targetType: 'route',
                    targetUuid: widget.routeId,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
