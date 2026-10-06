import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/cinema_models.dart';
import '../../domain/repositories/concession_repository.dart';

class ConcessionsViewModel extends ChangeNotifier {
  ConcessionsViewModel(this.repository);

  final ConcessionRepository repository;

  List<CinemaConcession> catalog = [];
  Map<String, int> cart = {};
  String? error;

  bool _loading = false;
  bool _disposed = false;
  int _loadRequest = 0;

  bool get busy => _loading;

  int get count => cart.values.fold(0, (sum, quantity) => sum + quantity);

  // Tạm tính hiển thị, chưa phải báo giá backend xác nhận.
  int get foodSubtotal =>
      catalog.fold(0, (sum, item) => sum + item.price * (cart[item.id] ?? 0));

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

    _loadRequest++;
    _loading = false;
    cart = {};
    error = null;

    if (clearCatalog) {
      catalog = [];
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _loadRequest++;
    super.dispose();
  }
}
