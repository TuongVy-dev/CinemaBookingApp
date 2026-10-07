import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';

class ApiClient {
  ApiClient._(this.dio, this.cookieJar);

  final Dio dio;
  final CookieJar cookieJar;
  static ApiClient? _instance;

  static Future<ApiClient> getInstance() async {
    if (_instance != null) return _instance!;

    final directory = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies/'),
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    )..interceptors.add(CookieManager(cookieJar));

    return _instance = ApiClient._(dio, cookieJar);
  }

  static ApiClient get instance {
    final client = _instance;
    if (client == null) {
      throw StateError(
        'ApiClient has not been initialized. '
        'Call ApiClient.getInstance() first.',
      );
    }
    return client;
  }

  static void reset() {
    _instance = null;
  }
}
