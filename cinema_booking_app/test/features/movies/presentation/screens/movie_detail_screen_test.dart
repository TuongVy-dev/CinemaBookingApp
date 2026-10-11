import 'package:cinema_booking_app/core/errors/failures.dart';
import 'package:cinema_booking_app/core/network/api_result.dart';
import 'package:cinema_booking_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:cinema_booking_app/features/movies/presentation/screens/movie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../movie_test_fakes.dart';

Widget _buildApp(FakeMovieRepository repository, String movieId) {
  final router = GoRouter(
    initialLocation: '/movies/$movieId',
    routes: [
      GoRoute(
        path: '/movies',
        builder: (context, state) => const Text('movie list'),
        routes: [
          GoRoute(
            path: ':movieId',
            builder: (context, state) =>
                MovieDetailScreen(movieId: state.pathParameters['movieId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/showtimes/:movieId',
        builder: (context, state) =>
            Text('showtimes:${state.pathParameters['movieId']}'),
      ),
    ],
  );
  return Provider<MovieRepository>.value(
    value: repository,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository());

  testWidgets('renders movie information from repository', (tester) async {
    repository.detailResult = ApiResult.success(
      buildMovie(releaseDate: DateTime(2026, 9, 2)),
    );

    usePhoneViewport(tester);
    await tester.pumpWidget(_buildApp(repository, 'MV000001'));
    await tester.pumpAndSettle();

    expect(repository.requestedMovieIds, ['MV000001']);
    expect(find.text('DUNE: PART TWO'), findsOneWidget);
    expect(find.text('120 phút'), findsOneWidget);
    expect(find.text('Khoa học viễn tưởng · Phiêu lưu'), findsOneWidget);
    expect(find.text('Tóm tắt Dune: Part Two'), findsOneWidget);
    expect(find.text('02/09/2026'), findsOneWidget);
    expect(find.text('T13'), findsNWidgets(2));
  });

  testWidgets('select showtime passes movieId to showtime route', (
    tester,
  ) async {
    repository.detailResult = ApiResult.success(buildMovie(id: 'MV000009'));

    usePhoneViewport(tester);
    await tester.pumpWidget(_buildApp(repository, 'MV000009'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn suất chiếu'));
    await tester.pumpAndSettle();

    expect(find.text('showtimes:MV000009'), findsOneWidget);
  });

  testWidgets('not found hides retry', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(_buildApp(repository, 'missing'));
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy phim.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('connection error can be retried', (tester) async {
    repository.detailResult = ApiResult.failure(
      const Failure('Không thể kết nối máy chủ. Vui lòng thử lại.'),
    );
    usePhoneViewport(tester);
    await tester.pumpWidget(_buildApp(repository, 'MV000001'));
    await tester.pumpAndSettle();

    repository.detailResult = ApiResult.success(buildMovie());
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('DUNE: PART TWO'), findsOneWidget);
    expect(repository.requestedMovieIds, ['MV000001', 'MV000001']);
  });

  testWidgets('back without history returns to movie list', (tester) async {
    repository.detailResult = ApiResult.success(buildMovie());
    usePhoneViewport(tester);
    await tester.pumpWidget(_buildApp(repository, 'MV000001'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    expect(find.text('movie list'), findsOneWidget);
  });
}
