import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/cinema_widgets.dart';
import '../features/account/presentation/screens/account_screen.dart';
import '../features/account/presentation/screens/login_registration_screen.dart';
import '../features/account/presentation/screens/reset_password_screen.dart';
import '../features/bookings_and_payment/domain/entities/booking_summary.dart';
import '../features/bookings_and_payment/presentation/screens/booking_created_screen.dart';
import '../features/bookings_and_payment/presentation/screens/booking_summary_debug_screen.dart';
import '../features/bookings_and_payment/presentation/screens/booking_summary_screen.dart';

import '../features/showtime/presentation/screens/showtime_screen.dart';
import '../features/showtime/presentation/screens/movie_demo_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginRegistrationScreen(),
    ),
    GoRoute(
      path: '/movies',
      builder: (context, state) => const MoviesDemoScreen(),
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
      path: '/showtimes/:movieId',
      builder: (context, state) => ShowtimeSelectionScreen(
        movieId: state.pathParameters['movieId']!,
        movieTitle: state.extra as String? ?? 'Chọn suất chiếu',
        movieDuration: 130,
        ageRating: 'T16',
      ),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const _FeaturePlaceholder(title: 'Tickets'),
    ),
    GoRoute(
      path: '/booking-summary',
      builder: (context, state) {
        final selection = state.extra;
        if (selection is BookingSelection) {
          return BookingSummaryScreen(selection: selection);
        }
        return const _FeaturePlaceholder(title: 'Booking summary');
      },
    ),
    GoRoute(
      path: '/booking-summary-debug',
      builder: (context, state) => const BookingSummaryDebugScreen(),
    ),
    GoRoute(
      path: '/booking-created',
      builder: (context, state) {
        final booking = state.extra;
        if (booking is CreatedBooking) {
          return BookingCreatedScreen(booking: booking);
        }
        return const _FeaturePlaceholder(title: 'Đặt vé');
      },
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
