import 'package:go_router/go_router.dart';

import '../features/customer/presentation/screens/concession_cart_screen.dart';
import '../features/customer/presentation/screens/concession_catalog_screen.dart';
import '../features/customer/presentation/screens/catalog_session_screen.dart';

final cinemaRouter = GoRouter(
  initialLocation: '/concessions',
  routes: [
    GoRoute(
      path: '/concessions',
      builder: (context, state) => const ConcessionCatalogScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const ConcessionCartScreen(),
    ),
    GoRoute(
      path: '/catalog-login',
      builder: (context, state) => const CatalogSessionScreen(),
    ),
  ],
);
