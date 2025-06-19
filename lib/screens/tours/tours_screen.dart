import 'package:flutter/material.dart';
import '../../core/api/utils_service.dart';
import '../../models/route_card.dart';
import '../../core/api/routes_service.dart';
import '../../components/route_card_item.dart';

class ToursScreen extends StatefulWidget {
  const ToursScreen({Key? key}) : super(key: key);

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  final _searchCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  List<RouteCard> _all = [];
  List<RouteCard> _filtered = [];
  List<RouteType> _routeTypes = [];
  String? _selectedTypeUuid;

  @override
  void initState() {
    super.initState();
    _init();
    _searchCtrl.addListener(_applyFilter);
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final types = await UtilsService.getRouteTypes();
      setState(() {
        _routeTypes = types;
        _selectedTypeUuid = null;
      });
      await _loadRoutes();
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки фильтров';
        _loading = false;
      });
    }
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await RoutesService.fetchRoutes();
      setState(() {
        _all = list;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки маршрутов';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final term = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((r) {
        final matchesSearch = r.name.toLowerCase().contains(term) ||
            r.location.toLowerCase().contains(term);
        final matchesType = _selectedTypeUuid == null ||
            r.routeTypeUuid == _selectedTypeUuid;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Поиск маршрутов...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedTypeUuid,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Все'),
                        ),
                        ..._routeTypes.map((t) => DropdownMenuItem(
                          value: t.uuid,
                          child: Text(t.name),
                        )),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedTypeUuid = v);
                        _applyFilter();
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // TODO: открыть расширенный фильтр
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _filtered.isEmpty
                  ? const Center(child: Text('Маршруты не найдены'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final r = _filtered[i];
                  return RouteCardItem(
                    route: r,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/route_detail',
                      arguments: r.uuid,
                    ).then((_) => _loadRoutes()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
