import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/movie_schedule.dart';

class MovieApiService {
  MovieApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<Response<dynamic>> getMovies(MovieSchedule schedule) => _dio.get(
    ApiConfig.publicMovies,
    queryParameters: {'status': _statusParam(schedule)},
  );

  Future<Response<dynamic>> getMovieDetail(String movieId) =>
      _dio.get('${ApiConfig.publicMovieDetail}${Uri.encodeComponent(movieId)}');

  static String _statusParam(MovieSchedule schedule) => switch (schedule) {
    MovieSchedule.nowShowing => 'now-showing',
    MovieSchedule.comingSoon => 'coming-soon',
  };
}
