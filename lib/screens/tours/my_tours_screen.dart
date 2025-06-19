import 'package:flutter/material.dart';
import '../../core/api/routes_service.dart';
import '../../models/route_card.dart';
import 'create_route_form_screen.dart';
import '../../components/route_card_item.dart';

class MyToursScreen extends StatefulWidget {
  const MyToursScreen({Key? key}) : super(key: key);

  @override
  State<MyToursScreen> createState() => _MyToursScreenState();
}

class _MyToursScreenState extends State<MyToursScreen> {
  late Future<List<RouteCard>> _futureRoutes;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  /// Перезапускает загрузку и вызывает setState
  void _loadRoutes() {
    setState(() {
      _futureRoutes = RoutesService.fetchMyRoutes();
    });
  }

  /// Вспомогательный метод для pull-to-refresh
  Future<void> _onRefresh() async {
    _loadRoutes();
    await _futureRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<RouteCard>>(
        future: _futureRoutes,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snap.error}'));
          }
          final routes = snap.data ?? [];
          if (routes.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: Text('У вас ещё нет маршрутов')),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              itemBuilder: (ctx, i) {
                final r = routes[i];
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
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRouteFormScreen()),
          );
          _loadRoutes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
