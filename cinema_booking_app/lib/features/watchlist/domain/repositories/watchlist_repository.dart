import '../../../../core/network/api_result.dart';

abstract interface class WatchlistRepository {
  /// ID các phim khách đang lưu; server là nguồn dữ liệu chính thức.
  Future<ApiResult<Set<String>>> getWatchlistMovieIds();

  /// Idempotent: thêm phim đã có trong watchlist vẫn thành công.
  Future<ApiResult<void>> add(String movieId);

  /// Idempotent: bỏ phim chưa lưu vẫn thành công.
  Future<ApiResult<void>> remove(String movieId);
}
