import '../../domain/entities/cinema_models.dart';
import '../../domain/repositories/concession_repository.dart';
import '../mappers/concession_mapper.dart';
import '../services/concession_api_service.dart';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';

class ConcessionApiRepository implements ConcessionRepository {
  ConcessionApiRepository({
    required this.service,
    required this.backendBaseUrl,
  });

  final ConcessionApiService service;
  final Uri backendBaseUrl;

  @override
  Future<List<CinemaConcession>> listConcessions() async {
    try {
      return await _loadAllPages();
    } on AppFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      final type = error is FormatException || error is TypeError
          ? AppFailureType.invalidData
          : AppFailureType.unknown;

      throw _failure(type, error);
    }
  }

  Future<List<CinemaConcession>> _loadAllPages() async {
    final items = <CinemaConcession>[];
    var page = 1;

    while (true) {
      final result = await service.fetchPage(page: page, pageSize: 20);

      if (result.pageNumber != page) {
        throw const FormatException('API trả về sai số trang catalog.');
      }

      if (!result.last &&
          (result.content.isEmpty || page >= result.totalPage)) {
        throw const FormatException(
          'Thông tin phân trang catalog không hợp lệ.',
        );
      }

      items.addAll(
        result.content.map(
          (dto) => mapConcessionDto(dto, backendBaseUrl: backendBaseUrl),
        ),
      );

      if (result.last) {
        return List<CinemaConcession>.unmodifiable(items);
      }

      page++;
    }
  }

  AppFailure _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    var type = AppFailureType.unknown;

    if (status == 401) {
      type = AppFailureType.sessionExpired;
    } else if (status == 403) {
      type = AppFailureType.forbidden;
    } else if (status != null && status >= 500) {
      type = AppFailureType.server;
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.badCertificate) {
      type = AppFailureType.network;
    } else if (error.error is FormatException || error.error is TypeError) {
      type = AppFailureType.invalidData;
    }

    return _failure(type, error);
  }

  AppFailure _failure(AppFailureType type, Object cause) {
    final message = switch (type) {
      AppFailureType.sessionExpired => 'Bạn cần đăng nhập lại để xem danh mục.',
      AppFailureType.forbidden =>
        'Tài khoản không có quyền xem danh mục bắp/nước.',
      AppFailureType.network =>
        'Không kết nối được máy chủ. Kiểm tra mạng và thử lại.',
      AppFailureType.invalidData =>
        'Không đọc được dữ liệu danh mục. Vui lòng thử lại.',
      AppFailureType.server => 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.',
      AppFailureType.unknown => 'Không tải được danh mục. Vui lòng thử lại.',
    };

    return AppFailure(type: type, message: message, cause: cause);
  }
}
