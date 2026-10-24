/// Lượt giữ ghế do server tạo. Đây là dữ liệu bàn giao cho các bước sau
/// (contract TV3 → TV4/TV5: `holdId`, `showtimeId`, `seatIds`, `expiresAt`,
/// `serverTime`).
class SeatHold {
  const SeatHold({
    required this.holdId,
    required this.showtimeId,
    required this.seatIds,
    required this.expiresAt,
    required this.serverTime,
  });

  final String holdId;
  final String showtimeId;

  /// `showtimeSeatId` của các ghế đang giữ.
  final List<String> seatIds;

  /// Hạn giữ theo đồng hồ server; so với [serverTime], không so với giờ máy.
  final DateTime expiresAt;
  final DateTime serverTime;
}
