class ApiConfig {
  ApiConfig._();

  static String _baseUrl = 'http://10.0.2.2:8081';

  static String get baseUrl => _baseUrl;

  static void configure({String? baseUrl}) {
    if (baseUrl != null && baseUrl.trim().isNotEmpty) {
      _baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    }
  }

  static const login = '/api/auth/login';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';

  static const register = '/api/auth/register';
  static const logout = '/api/auth/logout';
  static const me = '/api/auth/me';

  //Ngan
  static const showtimes = '/api/showtimes';
}
