import '../../../../core/config/api_config.dart';
import '../../domain/entities/movie.dart';
import '../dtos/movie_dto.dart';

// Backend lưu thể loại dạng chuỗi tự do (vd. "Hành động, Phiêu lưu").
final _genreSeparator = RegExp(r'\s*[,/|·;]\s*');

extension MovieDtoMapper on MovieDto {
  Movie toEntity() => Movie(
    id: movieId,
    title: title,
    genres: (genre ?? '')
        .split(_genreSeparator)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false),
    summary: summary?.trim() ?? '',
    durationMinutes: duration ?? 0,
    ageRating: ageRating?.trim() ?? '',
    releaseDate: _parseDate(releaseDate),
    posterUrl: ApiConfig.resolveAssetUrl(img),
    trailerUrl: (trailer?.trim().isEmpty ?? true) ? null : trailer!.trim(),
  );
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}
