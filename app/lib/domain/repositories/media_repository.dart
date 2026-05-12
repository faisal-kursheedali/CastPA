import 'package:castpa/domain/entities/media_item.dart';

abstract interface class MediaRepository {
  Future<List<MediaItem>> getAllMedia();
  Future<MediaItem?> getMediaById(String id);
  Future<String> addMedia(MediaItem media);
  Future<void> deleteMedia(String id);
  Future<List<MediaItem>> getMediaByIds(List<String> ids);
}
