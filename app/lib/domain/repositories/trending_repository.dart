import 'package:castpa/domain/entities/trending.dart';

abstract interface class TrendingRepository {
  Future<Trending?> getMostRecent();
  Future<String> saveTrending(Trending trending);
}
