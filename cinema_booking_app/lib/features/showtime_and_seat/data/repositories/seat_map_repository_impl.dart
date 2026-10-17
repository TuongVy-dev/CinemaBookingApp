import 'package:cinema_booking_app/core/errors/failures.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/data/dtos/seat_map_dto.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/data/services/seat_map_api_service.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_map.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/repositories/seat_map_repository.dart';
import 'package:dio/dio.dart';

class SeatMapRepositoryImpl implements SeatMapRepository {
  SeatMapRepositoryImpl(this._apiService);

  final SeatMapApiService _apiService;

  @override
  Future<ApiResult<SeatMap>> getSeatMap(String showtimeId) async {
    try {
      final response = await _apiService.getSeatMap(showtimeId);
      final body = response.data;
      if (body is! Map) {
        throw const FormatException('Expected a seat map object.');
      }
      return ApiResult.success(
        SeatMapDto.fromJson(Map<String, dynamic>.from(body)).toEntity(),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return ApiResult.failure(
          Failure(
            'Vui lòng đăng nhập để xem sơ đồ ghế.',
            statusCode: statusCode,
          ),
        );
      }
      // Backend trả {"error": "..."} khi suất chiếu không tồn tại/chưa có ghế.
      final payload = error.response?.data;
      final message = payload is Map ? payload['error']?.toString() : null;
      return ApiResult.failure(
        Failure(
          message ?? 'Không thể tải sơ đồ ghế. Vui lòng thử lại.',
          statusCode: statusCode,
        ),
      );
    } on FormatException catch (error) {
      return ApiResult.failure(
        Failure('Dữ liệu sơ đồ ghế không hợp lệ: ${error.message}'),
      );
    } on TypeError {
      return ApiResult.failure(
        const Failure('Dữ liệu sơ đồ ghế không hợp lệ.'),
      );
    }
  }
}
