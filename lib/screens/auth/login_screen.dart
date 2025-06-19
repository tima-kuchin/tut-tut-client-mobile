import 'package:flutter/material.dart';
import '../../core/api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _loginCtrl   = TextEditingController();
  final _passwordCtrl= TextEditingController();
  bool _loading      = false;
  String? _error;

  bool get _isFormValid =>
      (_loginCtrl.text.trim().isNotEmpty) &&
          (_passwordCtrl.text.isNotEmpty);

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final ok = await AuthService.login(
      _loginCtrl.text.trim(),
      _passwordCtrl.text,
    );

    setState(() { _loading = false; });

    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() { _error = 'Неверный логин или пароль'; });
    }
  }

  @override
  void initState() {
    super.initState();
    _loginCtrl.addListener(() => setState(() {}));
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _loginCtrl,
                decoration: const InputDecoration(labelText: 'Логин или Email'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите логин или email';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFormValid && !_loading ? _doLogin : null,
                child: _loading
                    ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Войти'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                child: const Text('Нет аккаунта? Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
                child: const Text('Забыли пароль?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
