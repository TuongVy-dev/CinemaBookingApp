class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'http://10.0.2.2:8081';
  static String _baseUrl = _defaultBaseUrl;

  static String get baseUrl => _baseUrl;

  static void configure({String? baseUrl}) {
    final trimmedBaseUrl = baseUrl?.trim();
    if (trimmedBaseUrl != null && trimmedBaseUrl.isNotEmpty) {
      _baseUrl = trimmedBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
  }

  static void reset() {
    _baseUrl = _defaultBaseUrl;
  }

  static const login = '/api/auth/login';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';

  static const register = '/api/auth/register';
  static const logout = '/api/auth/logout';
  static const me = '/api/auth/me';
  static const customerBookings = '/api/customer/bookings';
  static const customerBookingPreview = '$customerBookings/preview';

  //Ngan
  static const showtimes = '/api/showtimes/movie';

  static String showtimesFor({
    required String movieId,
    required String date,
  }) =>
      '/api/showtimes/movie/$movieId?date=$date';
}
