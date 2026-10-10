import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/bookings_and_payment/domain/entities/booking_summary.dart';
import 'package:cinema_booking_app/features/bookings_and_payment/domain/repositories/booking_summary_repository.dart';
import 'package:cinema_booking_app/features/bookings_and_payment/presentation/view_models/booking_summary_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the server-calculated booking quote', () async {
    final viewModel = BookingSummaryViewModel(_FakeBookingRepository());

    await viewModel.preview(
      const BookingSelection(
        showtimeId: 'ST000001',
        showtimeSeatIds: ['SS000001'],
      ),
    );

    expect(viewModel.error, isNull);
    expect(viewModel.quote?.total, 120000);
  });
}

class _FakeBookingRepository implements BookingSummaryRepository {
  @override
  Future<ApiResult<BookingQuote>> preview(BookingSelection selection) async =>
      ApiResult.success(
        const BookingQuote(
          ticketItems: [],
          concessionItems: [],
          ticketSubtotal: 120000,
          concessionSubtotal: 0,
          subtotal: 120000,
          discountAmount: 0,
          total: 120000,
        ),
      );
}
