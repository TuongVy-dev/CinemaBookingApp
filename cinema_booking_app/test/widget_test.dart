import 'package:cinema_booking_app/app/app.dart';
import 'package:cinema_booking_app/app/app_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Hiện yêu cầu đăng nhập và mở giỏ trống', (tester) async {
    await tester.pumpWidget(const AppProviders(child: CinemaApp()));
    await tester.pumpAndSettle();

    expect(find.text('BẮP & NƯỚC'), findsOneWidget);
    expect(
      find.text('Đăng nhập trước để tải danh mục bắp/nước.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Xem giỏ (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Giỏ bắp nước trống'), findsOneWidget);
  });
}
