import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/cinema_models.dart';
import '../../domain/repositories/concession_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../../showtime_and_seat/domain/entities/seat_hold.dart';
import '../../../showtime_and_seat/domain/entities/seat_map.dart';
import '../../../showtime_and_seat/domain/repositories/seat_map_repository.dart';

enum ConcessionFilter { all, popcorn, drink }

class ConcessionsViewModel extends ChangeNotifier {
  ConcessionsViewModel(this.repository, {this.seatMapRepository});
  final ConcessionRepository repository;
  final SeatMapRepository? seatMapRepository;

  int? ticketSubtotal;
  String? ticketError;
  bool ticketLoading = false;
  int _ticketRequest = 0;

  int? get previewTotal {
    final tickets = ticketSubtotal;
    return tickets == null ? null : tickets + foodSubtotal;
  }

  List<CinemaConcession> catalog = [];
  Map<String, int> cart = {};
  String? error;

  bool _loading = false;
  bool _disposed = false;
  int _loadRequest = 0;
  String? _sessionKey;
  bool _sessionInitialized = false;

  ConcessionFilter _filter = ConcessionFilter.all;

  ConcessionFilter get filter => _filter;

  List<CinemaConcession> get filteredCatalog {
    final prefix = switch (_filter) {
      ConcessionFilter.all => null,
      ConcessionFilter.popcorn => 'PC',
      ConcessionFilter.drink => 'DR',
    };

    return List<CinemaConcession>.unmodifiable(
      prefix == null
          ? catalog
          : catalog.where((item) => item.id.startsWith(prefix)),
    );
  }

  void setFilter(ConcessionFilter value) {
    if (_disposed || _filter == value) {
      return;
    }

    _filter = value;
    notifyListeners();
  }

  void syncSession(String? sessionKey) {
    if (_disposed || (_sessionInitialized && _sessionKey == sessionKey)) {
      return;
    }

    _sessionInitialized = true;
    _sessionKey = sessionKey;

    Future<void>.microtask(() async {
      if (_disposed || _sessionKey != sessionKey) {
        return;
      }

      reset(clearCatalog: true);

      if (sessionKey == null) {
        error = 'Đăng nhập trước để tải danh mục bắp/nước.';
        notifyListeners();
        return;
      }

      await load();
    });
  }

  bool get busy => _loading;

  int get count => cart.values.fold(0, (sum, quantity) => sum + quantity);

  // Tạm tính hiển thị, chưa phải báo giá backend xác nhận.
  int get foodSubtotal =>
      catalog.fold(0, (sum, item) => sum + item.price * (cart[item.id] ?? 0));
  Future<void> loadTicketPreview(SeatHold? hold) async {
    if (_disposed) {
      return;
    }

    final request = ++_ticketRequest;

    ticketSubtotal = null;
    ticketError = null;
    ticketLoading = false;

    if (hold == null) {
      notifyListeners();
      return;
    }

    if (hold.isExpiredAt(DateTime.now())) {
      ticketError = 'Thời gian giữ ghế đã hết. Vui lòng chọn ghế lại.';
      notifyListeners();
      return;
    }

    final source = seatMapRepository;
    if (source == null) {
      ticketError = 'Chưa cấu hình nguồn dữ liệu giá ghế.';
      notifyListeners();
      return;
    }

    ticketLoading = true;
    notifyListeners();

    try {
      final result = await source.getSeatMap(hold.showtimeId);

      if (_disposed || request != _ticketRequest) {
        return;
      }

      switch (result) {
        case Success<SeatMap>(:final data):
          final ids = hold.seatIds.toSet();
          final seats = data.seats
              .where((seat) => ids.contains(seat.showtimeSeatId))
              .toList();

          if (data.showtimeId != hold.showtimeId ||
              ids.isEmpty ||
              ids.length != hold.seatIds.length ||
              seats.length != ids.length) {
            ticketError = 'Không tìm đủ thông tin các ghế đã chọn.';
            return;
          }

          var subtotal = 0;

          for (final seat in seats) {
            final price = seat.price;

            if (price == null ||
                !price.isFinite ||
                price < 0 ||
                price != price.toInt()) {
              ticketError = 'Chưa có giá hợp lệ cho ghế ${seat.code}.';
              return;
            }

            subtotal += price.toInt();
          }

          ticketSubtotal = subtotal;

        case FailureResult<SeatMap>(:final failure):
          ticketError = failure.message;
      }
    } catch (_) {
      if (!_disposed && request == _ticketRequest) {
        ticketError = 'Không tải được giá ghế. Vui lòng thử lại.';
      }
    } finally {
      if (!_disposed && request == _ticketRequest) {
        ticketLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> load() async {
    if (_disposed) {
      return;
    }

    final request = ++_loadRequest;
    _loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await repository.listConcessions();

      if (_disposed || request != _loadRequest) {
        return;
      }

      catalog = List.unmodifiable(result);
    } catch (e) {
      if (!_disposed && request == _loadRequest) {
        error = e is AppFailure
            ? e.message
            : 'Không tải được danh mục. Vui lòng thử lại.';
      }
    } finally {
      if (!_disposed && request == _loadRequest) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void setQuantity(String id, int quantity) {
    if (_disposed) {
      return;
    }

    if (quantity > 0 && !catalog.any((item) => item.id == id)) {
      error = 'Món này không có trong danh mục hiện tại.';
      notifyListeners();
      return;
    }

    final next = {...cart};

    if (quantity <= 0) {
      next.remove(id);
    } else {
      next[id] = quantity.clamp(1, 10).toInt();
    }

    cart = next;
    notifyListeners();
  }

  void reset({bool clearCatalog = false}) {
    if (_disposed) {
      return;
    }
    _ticketRequest++;
    ticketSubtotal = null;
    ticketError = null;
    ticketLoading = false;
    _loadRequest++;
    _loading = false;
    cart = {};
    error = null;
    _filter = ConcessionFilter.all;

    if (clearCatalog) {
      catalog = [];
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _loadRequest++;
    _ticketRequest++;
    super.dispose();
  }
}
