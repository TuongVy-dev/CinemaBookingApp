import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/account/presentation/view_models/account_view_model.dart';
import '../features/bookings_and_payment/presentation/view_models/booking_summary_view_model.dart';
import '../features/movies/data/repositories/movie_repository_impl.dart';
import '../features/movies/data/services/movie_api_service.dart';
import '../features/movies/domain/repositories/movie_repository.dart';
import '../features/movies/presentation/view_models/movie_discovery_view_model.dart';

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
      Provider<MovieRepository>(
        create: (_) => MovieRepositoryImpl(MovieApiService()),
      ),
      // Tạo lười: chỉ tải danh sách phim khi màn hình phim được mở lần đầu.
      ChangeNotifierProvider<MovieDiscoveryViewModel>(
        create: (context) =>
            MovieDiscoveryViewModel(context.read<MovieRepository>())..load(),
      ),
    ],
    child: child,
  );
}
