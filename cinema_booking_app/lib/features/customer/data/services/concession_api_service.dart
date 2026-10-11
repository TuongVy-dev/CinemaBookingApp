import '../../../../core/network/api_client.dart';
import '../dtos/concession_page_dto.dart';

class ConcessionApiService {
  ConcessionApiService(this.client);

  final ApiClient client;

  Future<ConcessionPageDto> fetchPage({int page = 1, int pageSize = 20}) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Trang phải bắt đầu từ 1.');
    }

    if (pageSize < 1 || pageSize > 20) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Số sản phẩm mỗi trang phải từ 1 đến 20.',
      );
    }

    final response = await client.dio.get<Map<String, dynamic>>(
      '/api/concessions',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    final json = response.data;

    if (json == null) {
      throw const FormatException('API danh mục trả về dữ liệu trống.');
    }

    return ConcessionPageDto.fromJson(json);
  }
}
