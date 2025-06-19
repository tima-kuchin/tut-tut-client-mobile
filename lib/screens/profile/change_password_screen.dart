import 'package:flutter/material.dart';
import '../../core/api/users_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _oldCtrl     = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;
  String? _error;
  String? _msg;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await UsersService.changePassword(
      _oldCtrl.text, _newCtrl.text,
    );
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль успешно изменён'))
      );
      Navigator.pop(context);
    } else {
      setState(() => _error = 'Ошибка смены пароля');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сменить пароль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _oldCtrl,
                    decoration: const InputDecoration(labelText: 'Старый пароль'),
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? 'Введите старый пароль' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newCtrl,
                    decoration: const InputDecoration(labelText: 'Новый пароль'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Минимум 8 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    decoration: const InputDecoration(labelText: 'Повтор нового'),
                    obscureText: true,
                    validator: (v) =>
                    v != _newCtrl.text ? 'Несовпадение паролей' : null,
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_msg != null) ...[
              const SizedBox(height: 12),
              Text(_msg!, style: const TextStyle(color: Colors.green)),
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
                  : const Text('Сменить'),
            ),
          ],
        ),
      ),
    );
  }
}
