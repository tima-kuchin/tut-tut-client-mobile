import 'package:flutter/material.dart';
import '../../core/api/routes_service.dart';
import '../../core/api/utils_service.dart';
import 'create_route_map_screen.dart';

class CreateRouteFormScreen extends StatefulWidget {
  const CreateRouteFormScreen({Key? key}) : super(key: key);

  @override
  State<CreateRouteFormScreen> createState() => _CreateRouteFormScreenState();
}

class _CreateRouteFormScreenState extends State<CreateRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _dirty = false;
  bool _loading = false;
  String? _error;

  List<RouteType> _routeTypes = [];
  RouteType? _selectedRouteType;
  List<DifficultyType> _difficultyTypes = [];
  DifficultyType? _selectedDifficulty;

  List<RouteTag> _tagTypes = [];
  final Set<String> _selectedTagUuids = {};

  @override
  void initState() {
    super.initState();
    _loadDictionaries();
    _nameCtrl.addListener(_markDirty);
    _locCtrl.addListener(_markDirty);
    _descCtrl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _loadDictionaries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rts = await UtilsService.getRouteTypes();
      final diffs = await UtilsService.getDifficultyTypes();
      final tags = await UtilsService.getRouteTags();
      setState(() {
        _routeTypes = rts;
        _difficultyTypes = diffs;
        _tagTypes = tags;
        _selectedRouteType = rts.isNotEmpty ? rts.first : null;
        _selectedDifficulty = diffs.isNotEmpty ? diffs.first : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_dirty) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердите выход'),
        content: const Text('Вы ввели данные, но они не будут сохранены. Выйти без сохранения?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Остаться')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Выйти')),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRouteType == null || _selectedDifficulty == null) {
      setState(() => _error = 'Выберите тип и сложность маршрута');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final newId = await RoutesService.createDraft(
        name: _nameCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        routeTypeUuid: _selectedRouteType!.uuid,
        tags: _selectedTagUuids.toList(),
      );
      _dirty = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditRouteMapScreen(routeId: newId),
        ),
      );
    } catch (e) {
      setState(() => _error = 'Ошибка: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
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
    if (_loading && _routeTypes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _routeTypes.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Ошибка загрузки: $_error')),
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Новый маршрут: Описание')),
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
                      : 'Обязательно укажите название',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locCtrl,
                  decoration: const InputDecoration(labelText: 'Локация'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RouteType>(
                  value: _selectedRouteType,
                  decoration: const InputDecoration(labelText: 'Тип маршрута'),
                  items: _routeTypes
                      .map((rt) => DropdownMenuItem(value: rt, child: Text(rt.name)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedRouteType = v;
                      _markDirty();
                    });
                  },
                  validator: (_) => _selectedRouteType == null ? 'Выберите тип' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DifficultyType>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(labelText: 'Сложность'),
                  items: _difficultyTypes
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedDifficulty = v;
                      _markDirty();
                    });
                  },
                  validator: (_) => _selectedDifficulty == null ? 'Выберите сложность' : null,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Теги'),
                  child: Wrap(
                    spacing: 8,
                    children: _tagTypes.map((tag) {
                      final selected = _selectedTagUuids.contains(tag.uuid);
                      return FilterChip(
                        label: Text(tag.name),
                        selected: selected,
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _selectedTagUuids.add(tag.uuid);
                            } else {
                              _selectedTagUuids.remove(tag.uuid);
                            }
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
                  onPressed: _loading ? null : _saveDraft,
                  child: _loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Сохранить черновик'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
