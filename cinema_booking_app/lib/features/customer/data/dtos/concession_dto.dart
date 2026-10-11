class ConcessionDto {
  const ConcessionDto({
    required this.concessionId,
    required this.name,
    required this.price,
    required this.description,
    required this.img,
  });

  final String concessionId;
  final String name;
  final num price;
  final String description;
  final String img;

  factory ConcessionDto.fromJson(Map<String, dynamic> json) {
    final id = json['concessionId'];
    final name = json['name'];
    final price = json['price'];

    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        price is! num ||
        !price.isFinite ||
        price < 0) {
      throw const FormatException('Dữ liệu bắp/nước không hợp lệ.');
    }

    return ConcessionDto(
      concessionId: id,
      name: name,
      price: price,
      description: json['description'] as String? ?? '',
      img: json['img'] as String? ?? '',
    );
  }
}
