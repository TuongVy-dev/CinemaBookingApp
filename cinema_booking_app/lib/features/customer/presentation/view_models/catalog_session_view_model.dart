import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';

/// Session tạm để kiểm tra catalog, chờ tích hợp auth của TV1.
class CatalogSessionViewModel extends ChangeNotifier {
  CatalogSessionViewModel({required this.authenticate});

  final Future<void> Function(String, String) authenticate;

  bool busy = false;
  String? error;
  bool _disposed = false;

  Future<bool> login(String username, String password) async {
    if (_disposed || busy) {
      return false;
    }

    busy = true;
    error = null;
    notifyListeners();

    try {
      await authenticate(username, password);
      return !_disposed;
    } catch (e) {
      if (!_disposed) {
        error = e is AppFailure
            ? e.message
            : 'Không đăng nhập được. Vui lòng thử lại.';
      }
      return false;
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
