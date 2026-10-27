import 'package:flutter/foundation.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/repositories/watchlist_repository.dart';

enum WatchlistToggleOutcome {
  added,
  removed,

  /// Chưa đăng nhập nên không có watchlist để ghi.
  signInRequired,

  /// Phim này đang có một thao tác chưa xong.
  ignored,
  failed,
}

/// Trạng thái watchlist của khách đang đăng nhập, dùng chung cho mọi màn hình
/// phim. Server là nguồn dữ liệu chính thức; thay đổi được áp dụng lạc quan
/// rồi hoàn tác nếu server từ chối.
class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel(this._repository);

  final WatchlistRepository _repository;
  Set<String> _movieIds = const {};
  final Set<String> _pendingIds = {};
  String? _sessionKey;
  bool _sessionInitialized = false;
  // Tăng mỗi khi đổi phiên để bỏ kết quả của request thuộc phiên cũ.
  int _generation = 0;
  bool _disposed = false;

  /// Thông báo của lần [toggle] gần nhất bị [WatchlistToggleOutcome.failed].
  String? errorMessage;

  bool contains(String movieId) => _movieIds.contains(movieId);

  bool isPending(String movieId) => _pendingIds.contains(movieId);

  void syncSession(String? sessionKey) {
    if (_disposed || (_sessionInitialized && _sessionKey == sessionKey)) {
      return;
    }
    _sessionInitialized = true;
    _sessionKey = sessionKey;
    _generation++;
    final generation = _generation;

    Future<void>.microtask(() async {
      if (_disposed || generation != _generation) return;
      _movieIds = const {};
      _pendingIds.clear();
      notifyListeners();
      if (sessionKey != null) await load();
    });
  }

  Future<void> load() async {
    final generation = _generation;
    final result = await _repository.getWatchlistMovieIds();
    if (_disposed || generation != _generation) return;

    // Lỗi tải chỉ giữ watchlist trống: thao tác thêm/bỏ vẫn dùng được.
    if (result case Success(:final data)) {
      _movieIds = data;
      notifyListeners();
    }
  }

  Future<WatchlistToggleOutcome> toggle(String movieId) async {
    if (_sessionKey == null) return WatchlistToggleOutcome.signInRequired;
    if (_pendingIds.contains(movieId)) return WatchlistToggleOutcome.ignored;

    final generation = _generation;
    final wasSaved = _movieIds.contains(movieId);
    _setSaved(movieId, !wasSaved);
    _pendingIds.add(movieId);
    notifyListeners();

    final result = wasSaved
        ? await _repository.remove(movieId)
        : await _repository.add(movieId);
    if (_disposed || generation != _generation) {
      return WatchlistToggleOutcome.ignored;
    }

    _pendingIds.remove(movieId);
    switch (result) {
      case Success():
        notifyListeners();
        return wasSaved
            ? WatchlistToggleOutcome.removed
            : WatchlistToggleOutcome.added;
      case FailureResult(:final failure):
        _setSaved(movieId, wasSaved);
        errorMessage = failure.message;
        notifyListeners();
        return WatchlistToggleOutcome.failed;
    }
  }

  void _setSaved(String movieId, bool saved) {
    _movieIds = saved
        ? {..._movieIds, movieId}
        : (_movieIds.toSet()..remove(movieId));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
