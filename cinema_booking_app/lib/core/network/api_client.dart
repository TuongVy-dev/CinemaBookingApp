import 'dart:io';

import 'package:dio/dio.dart';

/// Shared HTTP client for the backend's JSESSIONID session.
class ApiClient {
  ApiClient({required String baseUrl})
    : _origin = Uri.parse(baseUrl),
      dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          followRedirects: false,
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _attachSession(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _saveSession(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _saveSession(error.response);
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final Uri _origin;
  Cookie? _session;
  DateTime? _expiresAt;

  void clearSession() {
    _session = null;
    _expiresAt = null;
  }

  bool _sameOrigin(Uri uri) =>
      uri.scheme == _origin.scheme &&
      uri.host == _origin.host &&
      uri.port == _origin.port;

  void _attachSession(RequestOptions options) {
    final expiry = _expiresAt;
    if (expiry != null && !expiry.isAfter(DateTime.now())) {
      clearSession();
    }

    final cookie = _session;
    if (cookie == null || !_sameOrigin(options.uri)) {
      return;
    }

    if (cookie.secure && options.uri.scheme != 'https') {
      return;
    }

    final path = cookie.path ?? '/';
    final requestPath = options.uri.path;
    final matchesPath =
        requestPath == path ||
        (requestPath.startsWith(path) &&
            (path.endsWith('/') ||
                requestPath.substring(path.length).startsWith('/')));

    if (!matchesPath) {
      return;
    }

    options.headers[HttpHeaders.cookieHeader] =
        '${cookie.name}=${cookie.value}';
  }

  void _saveSession(Response<dynamic>? response) {
    if (response == null || !_sameOrigin(response.requestOptions.uri)) {
      return;
    }

    final values = response.headers[HttpHeaders.setCookieHeader] ?? [];

    for (final value in values) {
      if (value.split('=').first.trim() != 'JSESSIONID') {
        continue;
      }

      final cookie = Cookie.fromSetCookieValue(value);
      final domain = cookie.domain?.toLowerCase().replaceFirst(
        RegExp(r'^\.'),
        '',
      );

      if (domain != null &&
          _origin.host != domain &&
          !_origin.host.endsWith('.$domain')) {
        throw const FormatException('Session cookie has an invalid domain.');
      }

      final maxAge = cookie.maxAge;
      final expiry = maxAge != null
          ? DateTime.now().add(Duration(seconds: maxAge))
          : cookie.expires;

      if (cookie.value.isEmpty ||
          (expiry != null && !expiry.isAfter(DateTime.now()))) {
        clearSession();
      } else {
        _session = cookie;
        _expiresAt = expiry;
      }
    }
  }
}
