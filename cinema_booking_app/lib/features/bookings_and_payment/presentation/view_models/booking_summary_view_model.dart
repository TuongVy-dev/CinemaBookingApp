import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../data/repositories/booking_summary_repository_impl.dart';
import '../../data/services/booking_summary_api_service.dart';
import '../../domain/entities/booking_summary.dart';
import '../../domain/repositories/booking_summary_repository.dart';

class BookingSummaryViewModel extends ChangeNotifier {
  BookingSummaryViewModel([BookingSummaryRepository? repository])
    : _repository =
          repository ??
          BookingSummaryRepositoryImpl(
            BookingSummaryApiService(dio: ApiClient.instance.dio),
          );

  final BookingSummaryRepository _repository;
  BookingQuote? _quote;
  String? _error;
  bool _loading = false;

  BookingQuote? get quote => _quote;
  String? get error => _error;
  bool get loading => _loading;

  Future<void> preview(BookingSelection selection) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.preview(selection);
    if (result case Success<BookingQuote>(:final data)) {
      _quote = data;
    } else {
      _quote = null;
      _error = (result as FailureResult<BookingQuote>).failure.message;
    }
    _loading = false;
    notifyListeners();
  }
}
