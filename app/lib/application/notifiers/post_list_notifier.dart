import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';

class PostListNotifier extends FamilyAsyncNotifier<List<Post>, PostStatus> {
  @override
  Future<List<Post>> build(PostStatus arg) async {
    return ref.watch(postRepositoryProvider).getPostsByStatus(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getPostsByStatus(arg),
    );
  }
}

final postListProvider = AsyncNotifierProvider.family<PostListNotifier, List<Post>, PostStatus>(
  PostListNotifier.new,
);
