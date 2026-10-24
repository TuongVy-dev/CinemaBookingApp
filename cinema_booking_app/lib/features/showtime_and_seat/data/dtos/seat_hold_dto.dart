import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_hold.dart';

/// Ánh xạ `SeatHoldResponseDTO` của `POST /api/customer/seat-holds`.
class SeatHoldDto {
  const SeatHoldDto({
    required this.holdId,
    required this.showtimeId,
    required this.seatIds,
    required this.expiresAt,
    required this.serverTime,
  });

  final String holdId;
  final String showtimeId;
  final List<String> seatIds;
  final String expiresAt;
  final String serverTime;

  factory SeatHoldDto.fromJson(Map<String, dynamic> json) {
    final seatIds = json['seatIds'];
    if (seatIds is! List) {
      throw const FormatException('Expected a list of seatIds.');
    }
    return SeatHoldDto(
      holdId: json['holdId'] as String,
      showtimeId: json['showtimeId'] as String,
      seatIds: seatIds.cast<String>().toList(growable: false),
      expiresAt: json['expiresAt'] as String,
      serverTime: json['serverTime'] as String,
    );
  }

  SeatHold toEntity() => SeatHold(
    holdId: holdId,
    showtimeId: showtimeId,
    seatIds: seatIds,
    expiresAt: _parseInstant(expiresAt),
    serverTime: _parseInstant(serverTime),
  );

  /// Server gửi ISO-8601 có offset nên giá trị là thời điểm tuyệt đối.
  static DateTime _parseInstant(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('Invalid timestamp: $value');
    return parsed;
  }
}
