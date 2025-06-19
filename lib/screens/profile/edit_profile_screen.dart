import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api/users_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName  = TextEditingController();
  final _email     = TextEditingController();
  final _age       = TextEditingController();
  String? _gender;
  final _desc      = TextEditingController();
  bool _loading    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await UsersService.getProfile();
    _firstName.text = u['first_name'] ?? '';
    _lastName.text  = u['last_name']  ?? '';
    _email.text     = u['email']      ?? '';
    _age.text       = u['age']?.toString() ?? '';
    _gender         = u['gender'];
    _desc.text      = u['description'] ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await UsersService.updateProfile({
      'first_name': _firstName.text.trim(),
      'last_name' : _lastName.text.trim(),
      'email'     : _email.text.trim(),
      'gender'    : _gender,
      'age'       : int.tryParse(_age.text.trim()),
      'description': _desc.text.trim(),
    });
    setState(() => _loading = false);
    if (ok) Navigator.pop(context);
    else setState(() => _error = 'Не удалось сохранить');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Имя'),
                    validator: (v) => v!.isEmpty ? 'Укажите имя' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Фамилия'),
                    validator: (v) => v!.isEmpty ? 'Укажите фамилию' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Некорректный email',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Пол'),
                    items: const [
                      DropdownMenuItem(value: 'male',   child: Text('Мужской')),
                      DropdownMenuItem(value: 'female', child: Text('Женский')),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                    validator: (_) => _gender == null ? 'Выберите пол' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _age,
                    decoration: const InputDecoration(labelText: 'Возраст'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final a = int.tryParse(v ?? '');
                      if (a == null || a < 1 || a > 120) {
                        return 'Некорректный возраст';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Описание'),
                    maxLines: 3,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
