import 'package:flutter/material.dart';
import 'package:turtut_dev/core/api/waypoints_service.dart';
import '../../core/api/routes_service.dart';
import '../../core/api/utils_service.dart';
import '../../core/utils/utils.dart';

class EditRouteInfoScreen extends StatefulWidget {
  final String routeId;
  const EditRouteInfoScreen({Key? key, required this.routeId}) : super(key: key);

  @override
  State<EditRouteInfoScreen> createState() => _EditRouteInfoScreenState();
}

class _EditRouteInfoScreenState extends State<EditRouteInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imgUrlCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _dirty = false;

  List<RouteType> _routeTypes = [];
  RouteType? _selRouteType;
  List<DifficultyType> _diffTypes = [];
  DifficultyType? _selDiffType;
  List<RouteTag> _tagTypes = [];
  final Set<String> _selTagUuids = {};

  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _nameCtrl.addListener(_markDirty);
    _locCtrl.addListener(_markDirty);
    _descCtrl.addListener(_markDirty);
    _imgUrlCtrl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _dirty = false;
    });

    try {
      final rts = await UtilsService.getRouteTypes();
      final diffs = await UtilsService.getDifficultyTypes();
      final tags = await UtilsService.getRouteTags();
      final data = await RoutesService.fetchRouteDetail(widget.routeId);

      setState(() {
        _routeTypes = rts;
        _diffTypes = diffs;
        _tagTypes = tags;

        _nameCtrl.text = data['name'] as String? ?? '';
        _locCtrl.text = data['location'] as String? ?? '';
        _descCtrl.text = data['description'] as String? ?? '';
        _isPublic = data['is_public'] == true;
        _imgUrlCtrl.text = data['thumbnail_url'] as String? ?? '';

        final rtUuid = data['route_type_uuid'] as String?;
        final dfUuid = data['difficulty_uuid'] as String?;
        final tgList = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];

        _selRouteType = rts.firstWhere((e) => e.uuid == rtUuid, orElse: () => rts.first);
        _selDiffType = diffs.firstWhere((e) => e.uuid == dfUuid, orElse: () => diffs.first);
        _selTagUuids.clear();
        _selTagUuids.addAll(tgList);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selRouteType == null || _selDiffType == null) {
      setState(() => _error = 'Выберите тип и сложность');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final pointsResp = await WaypointsService.fetchWaypoints(widget.routeId);
      final waypoints = pointsResp as List<dynamic>;
      final List<List<double>> coords = waypoints
          .where((wp) =>
      wp.type == 'start' ||
          wp.type == 'intermediate' ||
          wp.type == 'finish'
      )
          .map<List<double>>((wp) => [wp.lat, wp.lng])
          .toList();

      final double distance = CoreUtils.calculateRouteDistance(coords);

      final ok = await RoutesService.updateRouteInfo(
        routeId: widget.routeId,
        name: _nameCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        routeTypeUuid: _selRouteType!.uuid,
        difficultyUuid: _selDiffType!.uuid,
        tags: _selTagUuids.toList(),
        distance: distance,
        thumbnailUrl: _imgUrlCtrl.text.trim().isEmpty ? null : _imgUrlCtrl.text.trim(),
      );

      setState(() {
        _saving = false;
        _dirty = false;
      });

      if (ok) {
        await _loadInitial();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено')));
      } else {
        setState(() => _error = 'Ошибка при сохранении');
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Ошибка вычисления длины: $e';
      });
    }
  }

  Future<void> _publishRoute() async {
    if (_dirty) {
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Сохранить изменения?'),
          content: const Text('Перед публикацией необходимо сохранить изменения. Сохранить сейчас?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
          ],
        ),
      );
      if (res == true) await _save();
      else return;
    }
    setState(() => _saving = true);
    String? errorMsg;
    try {
      await RoutesService.publishRoute(widget.routeId);
      await _loadInitial();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Маршрут опубликован')),
      );
    } catch (e) {
      errorMsg = CoreUtils.extractApiError(e) ?? 'Ошибка публикации';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      setState(() => _error = errorMsg);
      await _loadInitial();
    } finally {
      setState(() => _saving = false);
    }
  }


  Future<void> _setDraft() async {
    if (_dirty) {
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Сохранить изменения?'),
          content: const Text('Перед переводом в черновик необходимо сохранить изменения. Сохранить сейчас?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
          ],
        ),
      );
      if (res == true) await _save();
      else return;
    }
    setState(() => _saving = true);
    String? errorMsg;
    try {
      await RoutesService.setRouteDraft(widget.routeId);
      await _loadInitial();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Маршрут переведён в черновики')),
      );
    } catch (e) {
      errorMsg = CoreUtils.extractApiError(e) ?? 'Ошибка перевода в черновик';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      setState(() => _error = errorMsg);
      await _loadInitial();
    } finally {
      setState(() => _saving = false);
    }
  }


  Future<void> _deleteRoute() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить маршрут?'),
        content: const Text('Действие нельзя будет отменить. Продолжить?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (res != true) return;

    setState(() => _saving = true);
    try {
      await RoutesService.deleteRoute(widget.routeId);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ошибка: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать маршрут')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Название *'),
                validator: (v) =>
                v != null && v.trim().isNotEmpty
                    ? null
                    : 'Укажите название',
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imgUrlCtrl.text.trim().isNotEmpty
                    ? Image.network(_imgUrlCtrl.text.trim(), fit: BoxFit.cover)
                    : Image.asset('assets/images/route_placeholder.jpg', fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imgUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL изображения маршрута',
                  hintText: 'https://example.com/img.jpg',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _locCtrl,
                decoration: const InputDecoration(labelText: 'Локация'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RouteType>(
                value: _selRouteType,
                decoration: const InputDecoration(labelText: 'Тип маршрута'),
                items: _routeTypes.map((rt) =>
                    DropdownMenuItem(value: rt, child: Text(rt.name))
                ).toList(),
                onChanged: (v) {
                  setState(() => _selRouteType = v);
                  _markDirty();
                },
                validator: (_) => _selRouteType == null ? 'Выберите тип' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DifficultyType>(
                value: _selDiffType,
                decoration: const InputDecoration(labelText: 'Сложность'),
                items: _diffTypes.map((d) =>
                    DropdownMenuItem(value: d, child: Text(d.name))
                ).toList(),
                onChanged: (v) {
                  setState(() => _selDiffType = v);
                  _markDirty();
                },
                validator: (_) => _selDiffType == null ? 'Выберите сложность' : null,
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Теги'),
                child: Wrap(
                  spacing: 8,
                  children: _tagTypes.map((t) {
                    final sel = _selTagUuids.contains(t.uuid);
                    return FilterChip(
                      label: Text(t.name),
                      selected: sel,
                      onSelected: (y) {
                        setState(() {
                          if (y) _selTagUuids.add(t.uuid);
                          else _selTagUuids.remove(t.uuid);
                          _markDirty();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Сохранить'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPublic || _saving ? null : _publishRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPublic ? Colors.grey : Colors.green,
                      ),
                      child: const Text('Опубликовать'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_isPublic || _saving ? null : _setDraft,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isPublic ? Colors.grey : Colors.orange,
                      ),
                      child: const Text('В черновик'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_location_alt_outlined),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _loading
                    ? null
                    : () {
                  Navigator.pushNamed(
                    context,
                    '/edit_route_map',
                    arguments: widget.routeId,
                  );
                },
                label: const Text('Редактировать точки маршрута'),
              ),
              const SizedBox(height: 18),
              Center(
                child: InkWell(
                  onTap: _saving ? null : _deleteRoute,
                  child: const Text(
                    'Удалить маршрут',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
