import 'package:castpa/domain/entities/enums.dart';

class PublishRecord {
  final String id;
  final String postId;
  final DateTime publishedDate;
  final List<Platform> platforms;
  final String deviceId;

  const PublishRecord({
    required this.id,
    required this.postId,
    required this.publishedDate,
    required this.platforms,
    required this.deviceId,
  });
}
