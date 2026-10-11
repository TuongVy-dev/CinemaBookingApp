import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/account/presentation/view_models/account_view_model.dart';
import '../features/bookings_and_payment/presentation/view_models/booking_summary_view_model.dart';

import '../features/showtime/presentation/view_models/showtime_view_model.dart';
import '../core/network/api_client.dart';
import '../features/showtime/data/repositories/showtime_repository_impl.dart';
import '../features/showtime/data/services/showtime_api_service.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AccountViewModel>(
        create: (_) => AccountViewModel()..checkSession(),
      ),
      ChangeNotifierProvider<BookingSummaryViewModel>(
        create: (_) => BookingSummaryViewModel(),
      ),
      ChangeNotifierProvider<ShowtimeViewModel>(
        create: (_) => ShowtimeViewModel(
          ShowtimeRepositoryImpl(
            ShowtimeApiService(dio: ApiClient.instance.dio),
          ),
        ),
      ),
    ],
    child: child,
  );
}
