import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_map.dart';

class SeatSelectionState {
  const SeatSelectionState({
    this.isLoading = false,
    this.errorMessage,
    this.seatMap,
    this.selectedSeatIds = const {},
  });

  final bool isLoading;
  final String? errorMessage;
  final SeatMap? seatMap;

  /// `showtimeSeatId` của các ghế đang chọn trên UI (chưa phải hold).
  final Set<String> selectedSeatIds;

  /// Ghế đã chọn, theo thứ tự xuất hiện trên sơ đồ.
  List<Seat> get selectedSeats => [
    for (final seat in seatMap?.seats ?? const <Seat>[])
      if (selectedSeatIds.contains(seat.showtimeSeatId)) seat,
  ];

  SeatSelectionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    SeatMap? seatMap,
    Set<String>? selectedSeatIds,
  }) => SeatSelectionState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    seatMap: seatMap ?? this.seatMap,
    selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
  );
}
