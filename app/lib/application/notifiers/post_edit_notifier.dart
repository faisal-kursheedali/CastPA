import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:castpa/application/notifiers/post_list_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';

enum SaveState { idle, saving, saved, deleted, error }

enum SubmitResult { draft, pending, removed }

class PostEditState {
  final Post post;
  final SaveState saveState;
  final String? saveError;
  final bool isPolishing;
  final String? polishError;
  final bool isSubmitting;
  final bool includeTrendingTags;
  final bool includeCategoryTags;

  const PostEditState({
    required this.post,
    this.saveState = SaveState.idle,
    this.saveError,
    this.isPolishing = false,
    this.polishError,
    this.isSubmitting = false,
    this.includeTrendingTags = true,
    this.includeCategoryTags = true,
  });

  PostEditState copyWith({
    Post? post,
    SaveState? saveState,
    String? saveError,
    bool? isPolishing,
    String? polishError,
    bool? isSubmitting,
    bool? includeTrendingTags,
    bool? includeCategoryTags,
    bool clearPolishError = false,
    bool clearSaveError = false,
  }) {
    return PostEditState(
      post: post ?? this.post,
      saveState: saveState ?? this.saveState,
      saveError: clearSaveError ? null : saveError ?? this.saveError,
      isPolishing: isPolishing ?? this.isPolishing,
      polishError: clearPolishError ? null : polishError ?? this.polishError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      includeTrendingTags: includeTrendingTags ?? this.includeTrendingTags,
      includeCategoryTags: includeCategoryTags ?? this.includeCategoryTags,
    );
  }
}

class PostEditNotifier extends AutoDisposeNotifier<PostEditState> {
  static const _uuid = Uuid();
  Timer? _debounce;
  bool _isNew = false;

  @override
  PostEditState build() {
    ref.onDispose(() => _debounce?.cancel());
    _isNew = true;
    return PostEditState(
      post: Post(
        id: _uuid.v4(),
        dump: '',
        links: [],
        postBaseTags: [],
        categoryBasePublishTags: [],
        trendsBasePublishTags: [],
        mediaIds: [],
        selectedPlatforms: [Platform.linkedin, Platform.x],
        publishedPlatforms: [],
        status: PostStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void loadPost(Post post) {
    _isNew = false;
    state = PostEditState(post: post);
  }

  /// Patches only publish-related fields after a manual copy-to-platform publish.
  /// Preserves all other state (checkbox selections, polish state, etc.).
  void applyPublishedPlatform(Platform platform) {
    final updatedPublished = [...state.post.publishedPlatforms, platform];
    final isFullyPublished = state.post.selectedPlatforms.every((p) => updatedPublished.contains(p));
    final newStatus = isFullyPublished ? PostStatus.published : PostStatus.partialPublished;
    state = state.copyWith(
      post: state.post.copyWith(
        publishedPlatforms: updatedPublished,
        status: newStatus,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // dump change → ensure status is draft (safe default for preview)
  void updateDump(String dump) => _updateAndScheduleSave(
    state.post.copyWith(dump: dump, updatedAt: DateTime.now()),
  );

  // Platform content changes → mark embedding stale; if pending, revert to draft so publish is re-gated
  void updateLinkedinContent(String content) => _updateAndScheduleSave(
    state.post.copyWith(
      linkedinContent: content,
      isEmbedded: false,
      status: state.post.status == PostStatus.pending ? PostStatus.draft : null,
      updatedAt: DateTime.now(),
    ),
  );

  void updateTwitterContent(String content) => _updateAndScheduleSave(
    state.post.copyWith(
      twitterContent: content,
      isEmbedded: false,
      status: state.post.status == PostStatus.pending ? PostStatus.draft : null,
      updatedAt: DateTime.now(),
    ),
  );

  void updateLinks(List<String> links) => _updateAndScheduleSave(
    state.post.copyWith(links: links, updatedAt: DateTime.now()),
  );

  void updateSelectedPlatforms(List<Platform> platforms) => _updateAndScheduleSave(
    state.post.copyWith(selectedPlatforms: platforms, updatedAt: DateTime.now()),
  );

  void updateCategoryId(String? categoryId) => _updateAndScheduleSave(
    state.post.copyWith(categoryId: categoryId, updatedAt: DateTime.now()),
  );

  void updatePostBaseTags(List<String> tags) => _updateAndScheduleSave(
    state.post.copyWith(postBaseTags: tags, updatedAt: DateTime.now()),
  );

  void updateCategoryBasePublishTags(List<String> tags) => _updateAndScheduleSave(
    state.post.copyWith(categoryBasePublishTags: tags, updatedAt: DateTime.now()),
  );

  void updateTrendsBasePublishTags(List<String> tags) => _updateAndScheduleSave(
    state.post.copyWith(trendsBasePublishTags: tags, updatedAt: DateTime.now()),
  );

  void setIncludeTrendingTags(bool value, List<String> resolvedTrendTags) {
    state = state.copyWith(includeTrendingTags: value);
    _updateAndScheduleSave(
      state.post.copyWith(
        trendsBasePublishTags: value ? resolvedTrendTags : [],
        updatedAt: DateTime.now(),
      ),
    );
  }

  void setIncludeCategoryTags(bool value, List<String> resolvedCategoryTags) {
    state = state.copyWith(includeCategoryTags: value);
    _updateAndScheduleSave(
      state.post.copyWith(
        categoryBasePublishTags: value ? resolvedCategoryTags : [],
        updatedAt: DateTime.now(),
      ),
    );
  }

  void updateMediaIds(List<String> ids) => _updateAndScheduleSave(
    state.post.copyWith(mediaIds: ids, updatedAt: DateTime.now()),
  );

  // Returns how many of the selectedPlatforms have non-empty content.
  int _filledPlatformCount(Post post) {
    return post.selectedPlatforms.where((p) {
      switch (p) {
        case Platform.linkedin:
          return post.linkedinContent?.isNotEmpty ?? false;
        case Platform.x:
          return post.twitterContent?.isNotEmpty ?? false;
      }
    }).length;
  }

  void _updateAndScheduleSave(Post post) {
    state = state.copyWith(post: post, saveState: SaveState.idle);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    final hasContent = state.post.hasContent;
    if (!hasContent && _isNew) return;

    state = state.copyWith(saveState: SaveState.saving, clearSaveError: true);
    try {
      final repo = ref.read(postRepositoryProvider);
      if (_isNew) {
        await repo.createPost(state.post);
        _isNew = false;
        ref.invalidate(postListProvider);
        state = state.copyWith(saveState: SaveState.saved);
      } else {
        await repo.updatePost(state.post);
        ref.invalidate(postListProvider);
        state = state.copyWith(saveState: SaveState.saved);
      }
    } catch (e) {
      state = state.copyWith(saveState: SaveState.error, saveError: e.toString());
    }
  }

  Future<void> forceSave() => _save();

  // Polish: fill platform fields + tags from Gemini. No embedding here.
  Future<void> polish() async {
    final post = state.post;
    if (post.dump.isEmpty) {
      state = state.copyWith(polishError: 'Please add some content to the dump first.');
      return;
    }
    if (post.selectedPlatforms.isEmpty) {
      state = state.copyWith(polishError: 'Please select at least one platform.');
      return;
    }
    final gemini = ref.read(geminiServiceProvider);
    if (gemini.apiKey.isEmpty) {
      state = state.copyWith(polishError: 'Please configure your Gemini API key in Settings.');
      return;
    }

    state = state.copyWith(isPolishing: true, clearPolishError: true);
    try {
      final result = await gemini.polishPost(
        dump: post.dump,
        forLinkedIn: post.selectedPlatforms.contains(Platform.linkedin),
        forX: post.selectedPlatforms.contains(Platform.x),
      );

      if (result.hasError) {
        state = state.copyWith(isPolishing: false, polishError: result.error);
        return;
      }

      final updated = post.copyWith(
        linkedinContent: result.linkedinContent ?? post.linkedinContent,
        twitterContent: result.twitterContent ?? post.twitterContent,
        postBaseTags: result.tags.isNotEmpty
            ? result.tags.map((t) => t.trim().replaceAll(' ', '_')).toList()
            : post.postBaseTags,
        status: PostStatus.draft,
        isEmbedded: false, // content changed, embedding stale
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(post: updated, isPolishing: false);
      await _save();
    } catch (e) {
      state = state.copyWith(isPolishing: false, polishError: 'Polish failed: $e');
    }
  }

  // Submit: only place that sets status and triggers embedding.
  //
  // dump only / partial platforms → draft, no embedding
  // all platforms filled         → pending + embedding, isEmbedded = true
  Future<SubmitResult?> submit() async {
    final post = state.post;

    // Nothing at all → soft-delete so it disappears from all lists
    final hasAnything = post.dump.isNotEmpty ||
        (post.linkedinContent?.isNotEmpty ?? false) ||
        (post.twitterContent?.isNotEmpty ?? false);
    if (!hasAnything) {
      if (!_isNew) {
        final updated = post.copyWith(isRemoved: true, updatedAt: DateTime.now());
        state = state.copyWith(post: updated);
        await _save();
        return SubmitResult.removed;
      }
      return SubmitResult.removed;
    }

    // Guard against re-submitting already published posts.
    if (post.status == PostStatus.published || post.status == PostStatus.partialPublished) return null;

    final filled = _filledPlatformCount(post);
    final total = post.selectedPlatforms.length;
    final allFilled = total > 0 && filled == total;

    if (!allFilled) {
      // draft — no embedding needed
      final updated = post.copyWith(status: PostStatus.draft, updatedAt: DateTime.now());
      state = state.copyWith(post: updated, isSubmitting: false);
      await _save();
      return SubmitResult.draft;
    }

    // All platforms filled → compute local embedding then mark pending
    state = state.copyWith(isSubmitting: true, clearPolishError: true);
    try {
      final embService = ref.read(embeddingServiceProvider);

      final rawContent = post.linkedinContent ?? post.twitterContent!;

      final allTags = post.postBaseTags.join(' ');

      // Append all tags to full content before chunking
      final contentWithTags = allTags.isNotEmpty ? '$rawContent $allTags' : rawContent;

      final vec = await embService.embedChunked(contentWithTags);
      final embedding = vec.isNotEmpty ? vec.join(',') : post.embedding;

      final updated = post.copyWith(
        status: PostStatus.pending,
        embedding: embedding,
        isEmbedded: vec.isNotEmpty,
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(post: updated, isSubmitting: false);
      await _save();
      return SubmitResult.pending;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, polishError: 'Submit failed: $e');
      return null;
    }
  }


  Future<bool> discardIfEmpty() async {
    if (_isNew && !state.post.hasContent) return true;
    _debounce?.cancel();
    await _save();
    return false;
  }
}

final postEditProvider =
    NotifierProvider.autoDispose<PostEditNotifier, PostEditState>(PostEditNotifier.new);
