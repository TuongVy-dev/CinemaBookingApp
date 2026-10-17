import 'package:flutter/foundation.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_map.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/repositories/seat_map_repository.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/presentation/states/seat_selection_state.dart';

enum SeatToggleResult { selected, deselected, unavailable, limitReached }

/// Quản lý việc tải sơ đồ ghế và chọn/bỏ chọn ghế trên UI.
///
/// Chưa giữ ghế: lựa chọn ở đây chỉ là nháp phía client, server vẫn quyết
/// định ghế còn trống khi tạo hold.
class SeatSelectionViewModel extends ChangeNotifier {
  SeatSelectionViewModel(this._repository, {this.maxSeats = defaultMaxSeats});

  static const defaultMaxSeats = 8;

  final SeatMapRepository _repository;
  final int maxSeats;

  SeatSelectionState _state = const SeatSelectionState();
  SeatSelectionState get state => _state;

  int _requestNumber = 0;
  bool _disposed = false;

  Future<void> load(String showtimeId) async {
    final requestNumber = ++_requestNumber;
    _emit(_state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getSeatMap(showtimeId);
    if (_disposed || requestNumber != _requestNumber) return;

    switch (result) {
      case Success<SeatMap>(:final data):
        // Khi tải lại, bỏ những ghế vừa bị người khác giữ/đặt.
        final stillSelectable = {
          for (final seat in data.seats)
            if (seat.isSelectable &&
                _state.selectedSeatIds.contains(seat.showtimeSeatId))
              seat.showtimeSeatId,
        };
        _emit(
          SeatSelectionState(seatMap: data, selectedSeatIds: stillSelectable),
        );
      case FailureResult<SeatMap>(:final failure):
        _emit(_state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  SeatToggleResult toggle(Seat seat) {
    final selected = {..._state.selectedSeatIds};
    if (selected.remove(seat.showtimeSeatId)) {
      _emit(_state.copyWith(selectedSeatIds: selected));
      return SeatToggleResult.deselected;
    }
    if (!seat.isSelectable) return SeatToggleResult.unavailable;
    if (selected.length >= maxSeats) return SeatToggleResult.limitReached;

    selected.add(seat.showtimeSeatId);
    _emit(_state.copyWith(selectedSeatIds: selected));
    return SeatToggleResult.selected;
  }

  void clearSelection() {
    if (_state.selectedSeatIds.isEmpty) return;
    _emit(_state.copyWith(selectedSeatIds: const {}));
  }

  void _emit(SeatSelectionState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
