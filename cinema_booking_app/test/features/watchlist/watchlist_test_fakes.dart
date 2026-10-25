import 'dart:async';

import 'package:cinema_booking_app/core/errors/failures.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:cinema_booking_app/features/watchlist/presentation/view_models/watchlist_view_model.dart';

class FakeWatchlistRepository implements WatchlistRepository {
  ApiResult<Set<String>> listResult = ApiResult.success(<String>{});
  ApiResult<void> writeResult = ApiResult.success(null);

  /// Khi đặt, thao tác ghi chờ completer này để kiểm tra trạng thái đang xử lý.
  Completer<ApiResult<void>>? pendingWrite;
  final List<String> added = [];
  final List<String> removed = [];

  @override
  Future<ApiResult<Set<String>>> getWatchlistMovieIds() async => listResult;

  @override
  Future<ApiResult<void>> add(String movieId) {
    added.add(movieId);
    return pendingWrite?.future ?? Future.value(writeResult);
  }

  @override
  Future<ApiResult<void>> remove(String movieId) {
    removed.add(movieId);
    return pendingWrite?.future ?? Future.value(writeResult);
  }
}

/// ViewModel đã đăng nhập; gọi `pumpAndSettle` để phiên được đồng bộ.
WatchlistViewModel buildWatchlistViewModel(
  FakeWatchlistRepository repository, {
  bool signedIn = true,
}) =>
    WatchlistViewModel(repository)..syncSession(signedIn ? 'KH001:user' : null);

const watchlistFailure = Failure('Không thể thêm phim vào watchlist.');
