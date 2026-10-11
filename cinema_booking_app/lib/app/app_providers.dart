import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../features/account/presentation/view_models/account_view_model.dart';
import '../features/bookings_and_payment/presentation/view_models/booking_summary_view_model.dart';
import '../features/customer/data/repositories/concession_api_repository.dart';
import '../features/customer/data/services/concession_api_service.dart';
import '../features/customer/domain/repositories/concession_repository.dart';
import '../features/customer/presentation/view_models/concession_view_model.dart';
import '../features/movies/data/repositories/movie_repository_impl.dart';
import '../features/movies/data/services/movie_api_service.dart';
import '../features/movies/domain/repositories/movie_repository.dart';
import '../features/movies/presentation/view_models/movie_discovery_view_model.dart';

import '../features/showtime/presentation/view_models/showtime_view_model.dart';
import '../features/showtime/data/repositories/showtime_repository_impl.dart';
import '../features/showtime/data/services/showtime_api_service.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: ApiClient.instance),
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
      Provider<MovieRepository>(
        create: (_) => MovieRepositoryImpl(MovieApiService()),
      ),
      ChangeNotifierProvider<MovieDiscoveryViewModel>(
        create: (context) =>
            MovieDiscoveryViewModel(context.read<MovieRepository>())..load(),
      ),
      Provider<ConcessionRepository>(
        create: (context) {
          final client = context.read<ApiClient>();

          return ConcessionApiRepository(
            service: ConcessionApiService(client),
            backendBaseUrl: Uri.parse(client.dio.options.baseUrl),
          );
        },
      ),
      ChangeNotifierProxyProvider<AccountViewModel, ConcessionsViewModel>(
        create: (context) =>
            ConcessionsViewModel(context.read<ConcessionRepository>()),
        update: (context, account, previous) {
          final catalog = previous!;
          final session = account.userSession;
          final sessionKey = account.loggedIn && session != null
              ? '${session.userId ?? ''}:${session.username}'
              : null;

          catalog.syncSession(sessionKey);
          return catalog;
        },
      ),
    ],
    child: child,
  );
}
