import 'package:cinema_booking_app/features/showtime_and_seat/domain/entities/seat_map.dart';

/// Ánh xạ `CashierSeatMapResponseDTO` của `GET /api/showtimes/{id}/seats`.
class SeatMapDto {
  const SeatMapDto({
    required this.showtimeId,
    required this.movieTitle,
    required this.seats,
    this.movieId,
    this.roomId,
    this.templateId,
    this.showDate,
    this.startTime,
  });

  final String showtimeId;
  final String? movieId;
  final String movieTitle;
  final String? roomId;
  final String? templateId;
  final String? showDate;
  final String? startTime;
  final List<SeatDto> seats;

  factory SeatMapDto.fromJson(Map<String, dynamic> json) {
    final seats = json['seats'];
    if (seats is! List) {
      throw const FormatException('Expected a list of seats.');
    }
    return SeatMapDto(
      showtimeId: json['showtimeId'] as String,
      movieId: json['movieId'] as String?,
      movieTitle: json['movieTitle'] as String? ?? '',
      roomId: json['roomId'] as String?,
      templateId: json['templateId'] as String?,
      showDate: json['showDate'] as String?,
      startTime: json['startTime'] as String?,
      seats: seats
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Invalid seat item.');
            }
            return SeatDto.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false),
    );
  }

  SeatMap toEntity() => SeatMap(
    showtimeId: showtimeId,
    movieId: movieId,
    movieTitle: movieTitle,
    roomId: roomId,
    templateId: templateId,
    showDate: showDate == null ? null : DateTime.tryParse(showDate!),
    startTime: startTime,
    seats: seats.map((seat) => seat.toEntity()).toList(growable: false),
  );
}

class SeatDto {
  const SeatDto({
    required this.showtimeSeatId,
    required this.templateSeatId,
    required this.rowLabel,
    required this.seatNumber,
    required this.seatType,
    required this.status,
    this.seatCode,
    this.price,
  });

  final String showtimeSeatId;
  final String templateSeatId;
  final String rowLabel;
  final int seatNumber;
  final String? seatCode;
  final String seatType;
  final String status;
  final num? price;

  factory SeatDto.fromJson(Map<String, dynamic> json) => SeatDto(
    showtimeSeatId: json['showtimeSeatId'] as String,
    templateSeatId: json['templateSeatId'] as String,
    rowLabel: json['rowLabel'] as String,
    seatNumber: (json['seatNumber'] as num).toInt(),
    seatCode: json['seatCode'] as String?,
    seatType: json['seatType'] as String? ?? '',
    status: json['status'] as String? ?? '',
    price: json['price'] as num?,
  );

  Seat toEntity() => Seat(
    showtimeSeatId: showtimeSeatId,
    templateSeatId: templateSeatId,
    rowLabel: rowLabel,
    seatNumber: seatNumber,
    code: seatCode ?? '$rowLabel$seatNumber',
    type: switch (seatType.toUpperCase()) {
      'STANDARD' => SeatType.standard,
      'VIP' => SeatType.vip,
      _ => SeatType.unknown,
    },
    status: switch (status.toUpperCase()) {
      'AVAILABLE' => SeatStatus.available,
      'PENDING' => SeatStatus.pending,
      'UNAVAILABLE' => SeatStatus.unavailable,
      _ => SeatStatus.unknown,
    },
    price: price,
  );
}
