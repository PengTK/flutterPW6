import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  int year;

  @HiveField(2)
  String genre;

  @HiveField(3)
  String imageUrl;

  Movie({
    required this.title,
    required this.year,
    required this.genre,
    required this.imageUrl,
  });
}