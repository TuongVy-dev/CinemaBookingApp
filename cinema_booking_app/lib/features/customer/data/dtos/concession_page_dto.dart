import 'concession_dto.dart';

class ConcessionPageDto {
  const ConcessionPageDto({
    required this.content,
    required this.pageNumber,
    required this.size,
    required this.totalElement,
    required this.totalPage,
    required this.last,
  });

  final List<ConcessionDto> content;
  final int pageNumber;
  final int size;
  final int totalElement;
  final int totalPage;
  final bool last;

  factory ConcessionPageDto.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>;

    return ConcessionPageDto(
      content: content
          .map((item) => ConcessionDto.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      pageNumber: json['pageNumber'] as int,
      size: json['size'] as int,
      totalElement: json['totalElement'] as int,
      totalPage: json['totalPage'] as int,
      last: json['last'] as bool,
    );
  }
}
