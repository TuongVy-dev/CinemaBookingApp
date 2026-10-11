import 'package:cinema_booking_app/features/showtime/domain/entities/showtime.dart';

class ShowtimeState {
  const ShowtimeState({
    this.isLoading = false,
    this.errorMessage,
    this.showtimes = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Showtime> showtimes;
}