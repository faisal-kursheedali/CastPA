import 'package:castpa/domain/entities/publish_record.dart';

abstract interface class PublishRepository {
  Future<List<PublishRecord>> getRecordsByPost(String postId);
  Future<String> createRecord(PublishRecord record);
}
