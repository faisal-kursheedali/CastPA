import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';

abstract interface class PostRepository {
  Future<List<Post>> getAllPosts();
  Future<List<Post>> getPostsByStatus(PostStatus status);
  Future<Post?> getPostById(String id);
  Future<String> createPost(Post post);
  Future<void> updatePost(Post post);
  Future<void> deletePost(String id);
  Future<List<Post>> getPostsByCategory(String categoryId);
  Future<List<Post>> getPostsPublishedInWeek(DateTime weekStart);
}
