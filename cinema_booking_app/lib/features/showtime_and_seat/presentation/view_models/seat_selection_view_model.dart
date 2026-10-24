import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_hold.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_map.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/repositories/seat_hold_repository.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/domain/repositories/seat_map_repository.dart';
import 'package:cinema_booking_app/features/showtime_and_seat/presentation/states/seat_selection_state.dart';

enum SeatToggleResult { selected, deselected, unavailable, limitReached }

/// Quản lý việc tải sơ đồ ghế, chọn/bỏ chọn ghế và giữ ghế khi tiếp tục.
///
/// Lựa chọn chỉ là nháp phía client cho tới khi [holdSelectedSeats] thành
/// công; server quyết định ghế còn trống và thời hạn giữ.
class SeatSelectionViewModel extends ChangeNotifier {
  SeatSelectionViewModel(
    this._repository,
    this._holdRepository, {
    this.maxSeats = defaultMaxSeats,
  });

  static const defaultMaxSeats = 8;

  final SeatMapRepository _repository;
  final SeatHoldRepository _holdRepository;
  final int maxSeats;

  SeatSelectionState _state = const SeatSelectionState();
  SeatSelectionState get state => _state;

  int _requestNumber = 0;
  bool _disposed = false;

  Set<String> get _heldSeatIds =>
      _state.hold?.seatIds.toSet() ?? const <String>{};

  Future<void> load(String showtimeId) async {
    final requestNumber = ++_requestNumber;
    _emit(_state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getSeatMap(showtimeId);
    if (_disposed || requestNumber != _requestNumber) return;

    switch (result) {
      case Success<SeatMap>(:final data):
        // Ghế mình đang giữ là PENDING trên server nhưng vẫn là lựa chọn của
        // mình; ghế khác vừa bị người khác giữ/đặt thì bỏ khỏi lựa chọn.
        final heldSeatIds = _heldSeatIds;
        final stillSelected = {
          for (final seat in data.seats)
            if (_state.selectedSeatIds.contains(seat.showtimeSeatId) &&
                (seat.isSelectable ||
                    heldSeatIds.contains(seat.showtimeSeatId)))
              seat.showtimeSeatId,
        };
        _emit(
          _state.copyWith(
            isLoading: false,
            clearError: true,
            seatMap: data,
            selectedSeatIds: stillSelected,
          ),
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
    // Ghế PENDING do chính mình giữ (quay lại từ bước sau) vẫn chọn lại được.
    if (!seat.isSelectable && !_heldSeatIds.contains(seat.showtimeSeatId)) {
      return SeatToggleResult.unavailable;
    }
    if (selected.length >= maxSeats) return SeatToggleResult.limitReached;

    selected.add(seat.showtimeSeatId);
    _emit(_state.copyWith(selectedSeatIds: selected));
    return SeatToggleResult.selected;
  }

  void clearSelection() {
    if (_state.selectedSeatIds.isEmpty) return;
    _emit(_state.copyWith(selectedSeatIds: const {}));
  }

  /// Giữ các ghế đang chọn trước khi sang bước chọn bắp nước: server chuyển
  /// ghế sang PENDING để tài khoản khác không chọn được. Nếu đã giữ đúng các
  /// ghế này thì dùng lại hold cũ; chọn lại khác thì server thay hold cũ.
  ///
  /// Trả thông báo lỗi, hoặc `null` khi [SeatSelectionState.hold] đã sẵn sàng.
  Future<String?> holdSelectedSeats() async {
    final seatMap = _state.seatMap;
    final seatIds = [
      for (final seat in _state.selectedSeats) seat.showtimeSeatId,
    ];
    if (seatMap == null || seatIds.isEmpty || _state.isHolding) return null;
    if (_state.hold != null && setEquals(_heldSeatIds, seatIds.toSet())) {
      return null;
    }

    _emit(_state.copyWith(isHolding: true));
    final result = await _holdRepository.holdSeats(
      showtimeId: seatMap.showtimeId,
      seatIds: seatIds,
    );

    switch (result) {
      case Success<SeatHold>(:final data):
        if (_disposed) {
          // Màn hình đã đóng trong lúc chờ: nhả ngay để không giữ ghế vô ích.
          unawaited(_holdRepository.releaseHold(data.holdId));
          return null;
        }
        _emit(_state.copyWith(isHolding: false, hold: data));
        return null;
      case FailureResult<SeatHold>(:final failure):
        _emit(_state.copyWith(isHolding: false));
        return failure.message;
    }
  }

  void _emit(SeatSelectionState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // ViewModel gắn với route ghế: rời màn hình (back) là bỏ đặt, nên nhả hold
    // thay vì chờ server hết hạn. Các bước sau được push lên trên nên màn
    // hình này vẫn còn trong stack và hold được giữ.
    final hold = _state.hold;
    if (hold != null) unawaited(_holdRepository.releaseHold(hold.holdId));
    super.dispose();
  }
}
