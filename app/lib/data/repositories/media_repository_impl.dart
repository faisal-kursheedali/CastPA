import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/media_item.dart';
import 'package:castpa/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final AppDatabase _db;

  MediaRepositoryImpl(this._db);

  MediaItem _fromRow(MediaData row) {
    return MediaItem(
      id: row.id,
      originalFilename: row.originalFilename,
      storedFilename: row.storedFilename,
      addedDate: row.addedDate,
    );
  }

  @override
  Future<List<MediaItem>> getAllMedia() async {
    final rows = await _db.select(_db.media).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<MediaItem?> getMediaById(String id) async {
    final row = await (_db.select(_db.media)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<String> addMedia(MediaItem media) async {
    await _db.into(_db.media).insert(MediaCompanion(
      id: Value(media.id),
      originalFilename: Value(media.originalFilename),
      storedFilename: Value(media.storedFilename),
      addedDate: Value(media.addedDate),
    ));
    return media.id;
  }

  @override
  Future<void> deleteMedia(String id) async {
    await (_db.delete(_db.media)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<MediaItem>> getMediaByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (_db.select(_db.media)
          ..where((t) => t.id.isIn(ids)))
        .get();
    return rows.map(_fromRow).toList();
  }
}
