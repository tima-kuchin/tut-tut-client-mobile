import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl        = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _firstNameCtrl    = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _ageCtrl          = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  String? _gender;
  bool _loading = false;
  String? _error;

  bool get _isFormValid =>
      _formKey.currentState?.validate() == true && _gender != null;

  Future<void> _submit() async {
    if (!_isFormValid) return;
    setState(() { _loading = true; _error = null; });

    final userData = {
      'login'      : _loginCtrl.text.trim(),
      'email'      : _emailCtrl.text.trim(),
      'first_name' : _firstNameCtrl.text.trim(),
      'last_name'  : _lastNameCtrl.text.trim(),
      'gender'     : _gender!,
      'age'        : int.parse(_ageCtrl.text.trim()),
      'password'   : _passwordCtrl.text,
    };

    final success = await AuthService.register(userData);
    setState(() { _loading = false; });

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() { _error = 'Не удалось зарегистрироваться'; });
    }
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                controller: _loginCtrl,
                decoration: const InputDecoration(labelText: 'Логин'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))
                ],
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Логин должен быть не менее 3 символов (буквы, цифры, _)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || !RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,4}')
                      .hasMatch(v.trim())) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Укажите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Фамилия'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Укажите фамилию';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Пол'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Мужской')),
                  DropdownMenuItem(value: 'female', child: Text('Женский')),
                ],
                onChanged: (v) => setState(() => _gender = v),
                validator: (_) =>
                _gender == null ? 'Выберите пол' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Возраст'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final age = int.tryParse(v ?? '');
                  if (age == null || age < 1 || age > 120) {
                    return 'Введите корректный возраст';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 8) {
                    return 'Пароль минимум 8 символов';
                  }
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
                    return 'Добавьте хотя бы одну заглавную букву';
                  }
                  if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) {
                    return 'Добавьте хотя бы одну цифру';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPassCtrl,
                decoration: const InputDecoration(labelText: 'Повтор пароля'),
                obscureText: true,
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFormValid && !_loading ? _submit : null,
                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
