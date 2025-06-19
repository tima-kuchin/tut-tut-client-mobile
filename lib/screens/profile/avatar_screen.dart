import 'package:flutter/material.dart';
import '../../core/api/users_service.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({Key? key}) : super(key: key);

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final u = await UsersService.getProfile();
    _urlCtrl.text = u['profile_picture'] ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await UsersService.updateAvatar(_urlCtrl.text.trim());
    setState(() => _loading = false);
    if (ok) Navigator.pop(context);
    else setState(() => _error = 'Ошибка обновления фото');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ссылка на фото')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(labelText: 'URL картинки'),
                validator: (v) {
                  final isValid = v != null && (Uri.tryParse(v)?.hasAbsolutePath ?? false);
                  if (!isValid) return 'Введите корректную ссылку';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Сохранить фото'),
            ),
          ],
        ),
      ),
    );
  }
}
