import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui/cinema_theme.dart';
import '../view_models/catalog_session_view_model.dart';

class CatalogSessionScreen extends StatefulWidget {
  const CatalogSessionScreen({super.key});

  @override
  State<CatalogSessionScreen> createState() => _CatalogSessionScreenState();
}

class _CatalogSessionScreenState extends State<CatalogSessionScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<CatalogSessionViewModel>();

    if (vm.busy || !_form.currentState!.validate()) {
      return;
    }

    final success = await vm.login(_username.text.trim(), _password.text);

    if (!mounted) {
      return;
    }

    if (success) {
      context.go('/concessions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogSessionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'CINEMA.',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Đăng nhập để xem danh mục bắp/nước.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _username,
                    enabled: !vm.busy,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập username.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !vm.busy,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập mật khẩu.'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      vm.error!,
                      style: const TextStyle(color: CinemaColors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: vm.busy ? null : _submit,
                    child: Text(vm.busy ? 'Đang đăng nhập…' : 'Đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
