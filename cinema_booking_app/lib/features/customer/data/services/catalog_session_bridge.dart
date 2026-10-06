import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_client.dart';

/// Temporary session bridge for testing the live catalog.
/// TV1 will provide the final authentication integration.
class CatalogSessionBridge {
  CatalogSessionBridge(this.client);

  final ApiClient client;

  Future<void> login(String username, String password) async {
    client.clearSession();
    var loginCompleted = false;

    try {
      await client.dio.post<void>(
        '/api/auth/login',
        data: {'username': username.trim(), 'password': password},
      );

      loginCompleted = true;

      await client.dio.get<void>('/api/auth/me');
    } on DioException catch (error) {
      client.clearSession();

      final unauthorized = error.response?.statusCode == 401;

      throw AppFailure(
        type: unauthorized && loginCompleted
            ? AppFailureType.sessionExpired
            : AppFailureType.unknown,
        message: unauthorized
            ? loginCompleted
                  ? 'Backend chưa nhận được session. Đăng nhập lại.'
                  : 'Tên đăng nhập hoặc mật khẩu không đúng.'
            : 'Không đăng nhập được. Kiểm tra backend và thử lại.',
        cause: error,
      );
    }
  }
}
