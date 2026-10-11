import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_schedule.dart';
import '../../domain/repositories/movie_repository.dart';
import '../dtos/movie_dto.dart';
import '../mappers/movie_mapper.dart';
import '../services/movie_api_service.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl(this._apiService);

  final MovieApiService _apiService;

  @override
  Future<ApiResult<List<Movie>>> getMovies(MovieSchedule schedule) async {
    try {
      final response = await _apiService.getMovies(schedule);
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Expected a JSON array of movies.');
      }
      final movies = data
          .whereType<Map<String, dynamic>>()
          .map((json) => MovieDto.fromJson(json).toEntity())
          .toList(growable: false);
      return ApiResult.success(movies);
    } on DioException catch (error) {
      return ApiResult.failure(
        _dioFailure(error, fallback: 'Không tải được danh sách phim.'),
      );
    } on FormatException {
      return ApiResult.failure(
        const Failure('Dữ liệu phim từ máy chủ không hợp lệ.'),
      );
    }
  }

  @override
  Future<ApiResult<Movie>> getMovieDetail(String movieId) async {
    try {
      final response = await _apiService.getMovieDetail(movieId);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object for movie.');
      }
      return ApiResult.success(MovieDto.fromJson(data).toEntity());
    } on DioException catch (error) {
      return ApiResult.failure(
        _dioFailure(error, fallback: 'Không tải được chi tiết phim.'),
      );
    } on FormatException {
      return ApiResult.failure(
        const Failure('Dữ liệu phim từ máy chủ không hợp lệ.'),
      );
    }
  }

  Failure _dioFailure(DioException error, {required String fallback}) {
    final statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return const Failure('Không thể kết nối máy chủ. Vui lòng thử lại.');
    }
    if (statusCode == 404) {
      return const Failure('Không tìm thấy phim.', statusCode: 404);
    }
    final body = error.response?.data;
    final message = body is Map<String, dynamic>
        ? body['message']?.toString()
        : null;
    return Failure(
      message?.isNotEmpty == true ? message! : '$fallback ($statusCode)',
      statusCode: statusCode,
    );
  }
}
