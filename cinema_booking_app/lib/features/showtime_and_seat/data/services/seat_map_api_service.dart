import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';

class SeatMapApiService {
  SeatMapApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getSeatMap(String showtimeId) =>
      _dio.get(ApiConfig.showtimeSeats(showtimeId));
}
