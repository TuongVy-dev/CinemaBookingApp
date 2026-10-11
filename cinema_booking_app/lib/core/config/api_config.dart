import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String _baseUrl = _defaultBaseUrl();

  static String _defaultBaseUrl() {
    const fromEnvironment = String.fromEnvironment('API_BASE_URL');
    if (fromEnvironment.isNotEmpty) {
      return fromEnvironment.replaceFirst(RegExp(r'/$'), '');
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://localhost:8081';
  }

  static String get baseUrl => _baseUrl;

  static void configure({String? baseUrl}) {
    final trimmedBaseUrl = baseUrl?.trim();
    if (trimmedBaseUrl != null && trimmedBaseUrl.isNotEmpty) {
      _baseUrl = trimmedBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
  }

  static void reset() {
    _baseUrl = _defaultBaseUrl();
  }

  static const login = '/api/auth/login';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';

  static const register = '/api/auth/register';
  static const logout = '/api/auth/logout';
  static const me = '/api/auth/me';
  static const customerBookings = '/api/customer/bookings';
  static const customerBookingPreview = '$customerBookings/preview';

  static const publicMovies = '/api/public/movies';
  static const publicMovieDetail = '/api/public/movies/';

  /// Backend trả đường dẫn ảnh tương đối (ví dụ `/assets/img/movies/x.jpg`).
  static String? resolveAssetUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '$_baseUrl${value.startsWith('/') ? '' : '/'}$value';
  }

  //Ngan
  static const showtimes = '/api/showtimes/movie';

  static String showtimesFor({required String movieId, required String date}) =>
      '/api/showtimes/movie/$movieId?date=$date';
}
