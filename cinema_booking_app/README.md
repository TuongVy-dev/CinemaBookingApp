# cinema_booking_app

## Kết nối backend

App dùng `http://10.0.2.2:8081` trên Android Emulator và `http://localhost:8081`
trên Windows/Web. Nếu chạy trên điện thoại Android thật, `localhost` là chính
điện thoại; hãy dùng địa chỉ IPv4 LAN của máy đang chạy Spring Boot:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081
```

Thay `192.168.1.10` bằng IPv4 của máy backend. Máy tính và điện thoại cần cùng
mạng, và cổng `8081` phải được phép truy cập từ mạng LAN. API danh sách phim là
`GET /api/public/movies?status=now-showing`.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
