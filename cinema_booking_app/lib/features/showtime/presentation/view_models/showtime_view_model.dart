import 'package:flutter/material.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/showtime/domain/entities/showtime.dart';
import 'package:cinema_booking_app/features/showtime/presentation/states/showtime_state.dart';
import 'package:cinema_booking_app/features/showtime/domain/repositories/showtime_repository.dart';

class ShowtimeViewModel extends ChangeNotifier {
  ShowtimeViewModel(this._repository);

  final ShowtimeRepository _repository;

  ShowtimeState _state = const ShowtimeState();
  ShowtimeState get state => _state;

  int _requestNumber = 0;

  Future<void> load(String movieId, DateTime date) async {
    final requestNumber = ++_requestNumber;

    _state = const ShowtimeState(isLoading: true);
    notifyListeners();

    final result = await _repository.getByMovieAndDate(
      movieId: movieId,
      date: date,
    );

    if (requestNumber != _requestNumber) return;

    switch (result) {
      case Success<List<Showtime>>(:final data):
        _state = ShowtimeState(showtimes: data);
      case FailureResult<List<Showtime>>(:final failure):
        _state = ShowtimeState(errorMessage: failure.message);
    }

    notifyListeners();
  }
}
