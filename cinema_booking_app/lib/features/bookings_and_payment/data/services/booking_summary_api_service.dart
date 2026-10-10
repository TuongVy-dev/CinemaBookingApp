import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';

class BookingSummaryApiService {
  BookingSummaryApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<Response<dynamic>> preview(Map<String, dynamic> request) =>
      _dio.post(ApiConfig.customerBookingPreview, data: request);
}
