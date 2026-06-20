import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/post.dart' as domain;
import 'package:castpa/domain/repositories/post_repository.dart';
import 'package:castpa/core/utils/json_utils.dart';

class PostRepositoryImpl implements PostRepository {
  final AppDatabase _db;

  PostRepositoryImpl(this._db);

  domain.Post _fromRow(Post row) {
    return domain.Post(
      id: row.id,
      dump: row.dump,
      linkedinContent: row.linkedinContent,
      twitterContent: row.twitterContent,
      embedding: row.embedding,
      postBaseTagsEmbedding: row.postBaseTagsEmbedding,
      isEmbedded: row.isEmbedded,
      isRemoved: row.isRemoved,
      categoryId: row.categoryId,
      links: parseStringList(row.linksJson),
      postBaseTags: parseStringList(row.postBaseTagsJson),
      trendsBasePublishTags: parseStringList(row.trendsBasePublishTagsJson),
      userAddedTrendTags: parseStringList(row.userAddedTrendTagsJson),
      mediaIds: parseStringList(row.mediaIdsJson),
      selectedPlatforms: parseStringList(row.selectedPlatformsJson)
          .map((k) => Platform.fromKey(k))
          .whereType<Platform>()
          .toList(),
      publishedPlatforms: parseStringList(row.publishedPlatformsJson)
          .map((k) => Platform.fromKey(k))
          .whereType<Platform>()
          .toList(),
      status: PostStatus.fromKey(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PostsCompanion _toCompanion(domain.Post post) {
    return PostsCompanion(
      id: Value(post.id),
      dump: Value(post.dump),
      linkedinContent: Value(post.linkedinContent),
      twitterContent: Value(post.twitterContent),
      embedding: Value(post.embedding),
      postBaseTagsEmbedding: Value(post.postBaseTagsEmbedding),
      isEmbedded: Value(post.isEmbedded),
      isRemoved: Value(post.isRemoved),
      categoryId: Value(post.categoryId),
      linksJson: Value(encodeStringList(post.links)),
      postBaseTagsJson: Value(encodeStringList(post.postBaseTags)),
      categoryBasePublishTagsJson: const Value('[]'),
      trendsBasePublishTagsJson: Value(encodeStringList(post.trendsBasePublishTags)),
      userAddedTrendTagsJson: Value(encodeStringList(post.userAddedTrendTags)),
      mediaIdsJson: Value(encodeStringList(post.mediaIds)),
      selectedPlatformsJson: Value(encodeStringList(post.selectedPlatforms.map((p) => p.key).toList())),
      publishedPlatformsJson: Value(encodeStringList(post.publishedPlatforms.map((p) => p.key).toList())),
      status: Value(post.status.key),
      createdAt: Value(post.createdAt),
      updatedAt: Value(post.updatedAt),
    );
  }

  @override
  Future<List<domain.Post>> getAllPosts() async {
    final rows = await (_db.select(_db.posts)
          ..where((t) => t.isRemoved.equals(false)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<domain.Post>> getPostsByStatus(PostStatus status) async {
    final rows = await (_db.select(_db.posts)
          ..where((t) => t.status.equals(status.key) & t.isRemoved.equals(false)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<domain.Post?> getPostById(String id) async {
    final row = await (_db.select(_db.posts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<String> createPost(domain.Post post) async {
    await _db.into(_db.posts).insert(_toCompanion(post));
    return post.id;
  }

  @override
  Future<void> updatePost(domain.Post post) async {
    await _db.update(_db.posts).replace(_toCompanion(post));
  }

  @override
  Future<void> deletePost(String id) async {
    await (_db.delete(_db.posts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<domain.Post>> getPostsByCategory(String categoryId) async {
    final rows = await (_db.select(_db.posts)
          ..where((t) => t.categoryId.equals(categoryId) & t.isRemoved.equals(false)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<domain.Post>> getPostsPublishedInWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final rows = await (_db.select(_db.posts)
          ..where((t) =>
              (t.status.equals(PostStatus.published.key) |
               t.status.equals(PostStatus.partialPublished.key)) &
              t.isRemoved.equals(false) &
              t.updatedAt.isBiggerOrEqualValue(weekStart) &
              t.updatedAt.isSmallerThanValue(weekEnd)))
        .get();
    return rows.map(_fromRow).toList();
  }
}
