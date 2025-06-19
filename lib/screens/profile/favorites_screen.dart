import 'package:flutter/material.dart';
import '../../core/api/routes_service.dart';
import '../../models/route_card.dart';
import '../../components/route_card_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<RouteCard> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _items = await RoutesService.fetchFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранные маршруты')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Ошибка: $_error'))
          : _items.isEmpty
          ? const Center(child: Text('Нет избранных маршрутов'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (ctx, i) {
          final item = _items[i];
          return RouteCardItem(
            route: item,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/route_detail',
                arguments: item.uuid,
              ).then((_) => _loadFavorites());
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFavorites,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
