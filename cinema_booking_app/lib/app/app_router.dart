import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/cinema_widgets.dart';
import '../features/account/presentation/screens/account_screen.dart';
import '../features/account/presentation/screens/login_registration_screen.dart';
import '../features/account/presentation/screens/reset_password_screen.dart';
import '../features/movies/presentation/screens/movie_detail_screen.dart';
import '../features/movies/presentation/screens/movie_discovery_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginRegistrationScreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: '/reset-password/:id/:timestamp/:token',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final timestamp =
            int.tryParse(state.pathParameters['timestamp'] ?? '') ?? 0;
        final token = state.pathParameters['token'] ?? '';
        return ResetPasswordScreen(
          id: id,
          resetTimestamp: timestamp,
          resetCode: token,
        );
      },
    ),
    GoRoute(
      path: '/movies',
      builder: (context, state) => const MovieDiscoveryScreen(),
      routes: [
        GoRoute(
          path: ':movieId',
          builder: (context, state) =>
              MovieDetailScreen(movieId: state.pathParameters['movieId']!),
        ),
      ],
    ),
    // Placeholder cho TV3; MovieDetailScreen chỉ truyền movieId.
    GoRoute(
      path: '/showtimes/:movieId',
      builder: (context, state) =>
          const _FeaturePlaceholder(title: 'Showtimes'),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const _FeaturePlaceholder(title: 'Tickets'),
    ),
  ],
);

class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const AsyncStateView(
      icon: Icons.movie_outlined,
      message: 'Tính năng đang được phát triển.',
    ),
    bottomNavigationBar: CinemaBottomNavigation(
      selectedIndex: title == 'Movies' ? 0 : 1,
      onItemSelected: (idx) {
        if (idx == 0) {
          context.go('/movies');
        } else if (idx == 1) {
          context.go('/tickets');
        } else {
          context.go('/account');
        }
      },
    ),
  );
}
