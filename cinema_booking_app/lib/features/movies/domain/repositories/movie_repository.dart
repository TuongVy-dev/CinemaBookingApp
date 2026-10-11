import '../../../../core/network/api_result.dart';
import '../entities/movie.dart';
import '../entities/movie_schedule.dart';

abstract interface class MovieRepository {
  Future<ApiResult<List<Movie>>> getMovies(MovieSchedule schedule);

  Future<ApiResult<Movie>> getMovieDetail(String movieId);
}
