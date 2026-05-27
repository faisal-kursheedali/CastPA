import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/trending.dart' as domain;
import 'package:castpa/domain/repositories/trending_repository.dart';
import 'package:castpa/core/utils/json_utils.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  final AppDatabase _db;

  TrendingRepositoryImpl(this._db);

  domain.Trending _fromRow(Trending row) {
    return domain.Trending(
      id: row.id,
      trendTopics: parseStringList(row.trendTopicsJson),
      rawTrendingTopics: parseStringList(row.rawTrendingJson ?? '[]'),
      categoryTopics: parseStringMap(row.categoryTopicsJson),
      addedDate: row.addedDate,
      fullEmbedding: parseDoubleList(row.fullEmbeddingJson),
      eachEmbedding: parseDoubleMatrix(row.eachEmbeddingJson),
      platform: row.platform,
      fetchError: row.fetchError,
    );
  }

  @override
  Future<domain.Trending?> getMostRecent() async {
    final rows = await (_db.select(_db.trendings)
          ..orderBy([(t) => OrderingTerm.desc(t.addedDate)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<String> saveTrending(domain.Trending trending) async {
    await _db.into(_db.trendings).insert(TrendingsCompanion(
      id: Value(trending.id),
      trendTopicsJson: Value(encodeStringList(trending.trendTopics)),
      rawTrendingJson: Value(encodeStringList(trending.rawTrendingTopics)),
      categoryTopicsJson: Value(encodeStringMap(trending.categoryTopics)),
      addedDate: Value(trending.addedDate),
      fullEmbeddingJson: Value(encodeDoubleList(trending.fullEmbedding)),
      eachEmbeddingJson: Value(encodeDoubleMatrix(trending.eachEmbedding)),
      platform: Value(trending.platform),
      fetchError: Value(trending.fetchError),
    ));
    return trending.id;
  }
}
