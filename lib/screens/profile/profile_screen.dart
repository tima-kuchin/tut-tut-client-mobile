import 'package:flutter/material.dart';
import '../../core/api/users_service.dart';
import '../../core/api/auth_service.dart';
import 'edit_profile_screen.dart';
import 'avatar_screen.dart';
import 'change_password_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      _user = await UsersService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _user == null) {
      return Center(child: Text('Ошибка: $_error'));
    }
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: (_user!['profile_picture'] as String?) != null
                  ? NetworkImage(_user!['profile_picture'])
                  : const AssetImage('assets/images/avatar_placeholder.png')
              as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '@${_user!['login']}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${_user!['first_name']} ${_user!['last_name']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${_user!['gender']=='male'?'Мужской':'Женский'}'
                  '${_user!['age']!=null?', ${_user!['age']} лет':''}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          if ((_user!['description'] as String?)?.isNotEmpty==true) ...[
            const SizedBox(height: 16),
            Text(
              _user!['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
          const Divider(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Редактировать профиль'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen())
            ).then((_) => _loadProfile()),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Изменить фото профиля'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvatarScreen())
            ).then((_) => _loadProfile()),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.lock),
            label: const Text('Сменить пароль'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen())
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.bookmark),
            label: const Text('Избранные маршруты'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen())
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: _logout,
            child: const Text('Выйти из профиля'),
          ),
        ],
      ),
    );
  }
}
