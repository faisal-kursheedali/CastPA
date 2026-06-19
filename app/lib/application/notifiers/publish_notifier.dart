import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/application/providers/bootstrap_provider.dart';
import 'package:castpa/application/notifiers/post_list_notifier.dart';
import 'package:castpa/data/services/media_file_service.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/publish_record.dart';

enum PublishStatus { idle, publishing, success, error }

class PublishState {
  final PublishStatus status;
  final String? error;
  final List<Platform> succeededPlatforms;

  const PublishState({
    this.status = PublishStatus.idle,
    this.error,
    this.succeededPlatforms = const [],
  });
}

class PublishNotifier extends AutoDisposeNotifier<PublishState> {
  static const _uuid = Uuid();

  @override
  PublishState build() => const PublishState();

  Future<PublishState> publish(Post post) async {
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    final config = ref.read(bootstrapConfigProvider).valueOrNull;
    final deviceId = config?.deviceId ?? '';

    final targets = post.remainingTargets;
    if (targets.isEmpty) {
      final s = const PublishState(status: PublishStatus.error, error: 'No remaining targets.');
      state = s;
      return s;
    }

    state = const PublishState(status: PublishStatus.publishing);

    final allTags = [
      ...post.postBaseTags,
      ...post.categoryBasePublishTags,
      ...post.trendsBasePublishTags,
    ].map((t) => t.startsWith('#') ? t : '#$t').toSet().toList();

    String appendTags(String? content) {
      if (content == null || content.isEmpty) return content ?? '';
      if (allTags.isEmpty) return content;
      return '$content\n\n${allTags.join(' ')}';
    }

    // Resolve mediaIds → absolute file paths (images only).
    // TODO: add video upload support for both LinkedIn and X —
    // LinkedIn requires a separate video asset registration flow (different from image URN upload),
    // X requires chunked media upload via POST media/upload with INIT/APPEND/FINALIZE commands.
    final mediaFileService = ref.read(mediaFileServiceProvider);
    final mediaItems = await ref.read(mediaRepositoryProvider).getMediaByIds(post.mediaIds);
    final mediaFilePaths = mediaItems
        .where((m) => MediaFileService.isImage(m.storedFilename))
        .where((m) => mediaFileService.fileExists(m.storedFilename))
        .map((m) => mediaFileService.getMediaFilePath(m.storedFilename))
        .toList();

    final results = await ref.read(publishServiceProvider).publish(
      targets: targets,
      linkedinContent: appendTags(post.linkedinContent),
      twitterContent: appendTags(post.twitterContent),
      linkedinToken: settings?.linkedinAuthToken,
      xToken: settings?.xAuthToken,
      mediaFilePaths: mediaFilePaths,
    );

    final succeeded = results.where((r) => r.success).map((r) => r.platform).toList();
    final errors = results.where((r) => !r.success).map((r) => '${r.platform.displayName}: ${r.error}').toList();

    // Persist publish records
    final publishRepo = ref.read(publishRepositoryProvider);
    final postRepo = ref.read(postRepositoryProvider);

    for (final platform in succeeded) {
      await publishRepo.createRecord(PublishRecord(
        id: _uuid.v4(),
        postId: post.id,
        publishedDate: DateTime.now(),
        platforms: [platform],
        deviceId: deviceId,
      ));
    }

    // Update post
    final updatedPublished = [...post.publishedPlatforms, ...succeeded];
    final isFullyPublished = post.selectedPlatforms
        .every((p) => updatedPublished.contains(p));

    PostStatus newStatus;
    if (isFullyPublished) {
      newStatus = PostStatus.published;
    } else if (updatedPublished.isNotEmpty) {
      newStatus = PostStatus.partialPublished;
    } else {
      newStatus = post.status;
    }

    final updatedPost = post.copyWith(
      publishedPlatforms: updatedPublished,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await postRepo.updatePost(updatedPost);

    // Refresh all list views that may be showing this post
    for (final s in PostStatus.values) {
      ref.invalidate(postListProvider(s));
    }

    final newState = PublishState(
      status: succeeded.isNotEmpty ? PublishStatus.success : PublishStatus.error,
      error: errors.isNotEmpty ? errors.join('\n') : null,
      succeededPlatforms: succeeded,
    );
    state = newState;
    return newState;
  }

  /// Marks a single platform as published without calling the API.
  /// Used by the "Copy to Platform" feature where the user posts manually.
  Future<void> markAsPublishedManually(Post post, Platform platform) async {
    final config = ref.read(bootstrapConfigProvider).valueOrNull;
    final deviceId = config?.deviceId ?? '';

    final publishRepo = ref.read(publishRepositoryProvider);
    final postRepo = ref.read(postRepositoryProvider);

    await publishRepo.createRecord(PublishRecord(
      id: _uuid.v4(),
      postId: post.id,
      publishedDate: DateTime.now(),
      platforms: [platform],
      deviceId: deviceId,
    ));

    final updatedPublished = [...post.publishedPlatforms, platform];
    final isFullyPublished = post.selectedPlatforms.every((p) => updatedPublished.contains(p));

    final newStatus = isFullyPublished
        ? PostStatus.published
        : updatedPublished.isNotEmpty
            ? PostStatus.partialPublished
            : post.status;

    final updatedPost = post.copyWith(
      publishedPlatforms: updatedPublished,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await postRepo.updatePost(updatedPost);

    for (final s in PostStatus.values) {
      ref.invalidate(postListProvider(s));
    }

    state = PublishState(
      status: PublishStatus.success,
      succeededPlatforms: [platform],
    );
  }
}

final publishNotifierProvider =
    NotifierProvider.autoDispose<PublishNotifier, PublishState>(PublishNotifier.new);
