import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/publish_record.dart';
import 'package:castpa/domain/repositories/publish_repository.dart';
import 'package:castpa/core/utils/json_utils.dart';

class PublishRepositoryImpl implements PublishRepository {
  final AppDatabase _db;

  PublishRepositoryImpl(this._db);

  PublishRecord _fromRow(Publishe row) {
    return PublishRecord(
      id: row.id,
      postId: row.postId,
      publishedDate: row.publishedDate,
      platforms: parseStringList(row.platformsJson)
          .map((k) => Platform.fromKey(k))
          .whereType<Platform>()
          .toList(),
      deviceId: row.deviceId,
    );
  }

  @override
  Future<List<PublishRecord>> getRecordsByPost(String postId) async {
    final rows = await (_db.select(_db.publishes)
          ..where((t) => t.postId.equals(postId)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<String> createRecord(PublishRecord record) async {
    await _db.into(_db.publishes).insert(PublishesCompanion(
      id: Value(record.id),
      postId: Value(record.postId),
      publishedDate: Value(record.publishedDate),
      platformsJson: Value(encodeStringList(record.platforms.map((p) => p.key).toList())),
      deviceId: Value(record.deviceId),
    ));
    return record.id;
  }
}
