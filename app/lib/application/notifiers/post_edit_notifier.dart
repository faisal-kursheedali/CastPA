import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:castpa/application/notifiers/post_list_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/trending.dart';

enum SaveState { idle, saving, saved, deleted, error }

enum SubmitResult { draft, pending, removed }

enum RagStatus { idle, processing, done, empty }

class RagTagScore {
  final String tag;
  final double score;
  const RagTagScore(this.tag, this.score);
}

class RagDebugData {
  final Map<String, List<RagTagScore>> perTagResults;
  final List<RagTagScore> merged;
  final List<RagTagScore> final5;
  const RagDebugData({this.perTagResults = const {}, this.merged = const [], this.final5 = const []});
}

class PostEditState {
  final Post post;
  final SaveState saveState;
  final String? saveError;
  final bool isPolishing;
  final String? polishError;
  final bool isSubmitting;
  final Set<String> selectedTrendTags;
  final Set<String> ragSuggestedTags;
  final RagStatus ragStatus;
  final RagDebugData? ragDebugData;

  const PostEditState({
    required this.post,
    this.saveState = SaveState.idle,
    this.saveError,
    this.isPolishing = false,
    this.polishError,
    this.isSubmitting = false,
    this.selectedTrendTags = const {},
    this.ragSuggestedTags = const {},
    this.ragStatus = RagStatus.idle,
    this.ragDebugData,
  });

  PostEditState copyWith({
    Post? post,
    SaveState? saveState,
    String? saveError,
    bool? isPolishing,
    String? polishError,
    bool? isSubmitting,
    Set<String>? selectedTrendTags,
    Set<String>? ragSuggestedTags,
    RagStatus? ragStatus,
    RagDebugData? ragDebugData,
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
      selectedTrendTags: selectedTrendTags ?? this.selectedTrendTags,
      ragSuggestedTags: ragSuggestedTags ?? this.ragSuggestedTags,
      ragStatus: ragStatus ?? this.ragStatus,
      ragDebugData: ragDebugData ?? this.ragDebugData,
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
    state = PostEditState(
      post: post,
      ragSuggestedTags: post.trendsBasePublishTags.toSet().difference(post.userAddedTrendTags.toSet()),
      selectedTrendTags: {...post.trendsBasePublishTags, ...post.userAddedTrendTags},
    );
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
    state.post.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      updatedAt: DateTime.now(),
    ),
  );

  void updatePostBaseTags(List<String> tags) {
    _updateAndScheduleSave(
      state.post.copyWith(postBaseTags: tags, updatedAt: DateTime.now()),
    );
    _embedAndFilterTags(tags);
  }

  Future<void> _embedAndFilterTags(List<String> tags) async {
    if (tags.isEmpty) {
      state = state.copyWith(
        selectedTrendTags: {},
        ragSuggestedTags: {},
        ragStatus: RagStatus.empty,
        ragDebugData: const RagDebugData(),
      );
      _updateAndScheduleSave(
        state.post.copyWith(
          postBaseTagsEmbedding: '[]',
          trendsBasePublishTags: [],
          userAddedTrendTags: [],
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

    state = state.copyWith(ragStatus: RagStatus.processing);

    // Embed each tag individually and store as JSON array of arrays
    final embService = ref.read(embeddingServiceProvider);
    final allEmbeddings = <List<double>>[];
    for (final tag in tags) {
      final tagText = tag
          .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}')
          .replaceAll('_', ' ')
          .toLowerCase()
          .trim();
      final vec = await embService.embedChunked(tagText);
      allEmbeddings.add(vec);
    }

    final embJson = jsonEncode(allEmbeddings);
    _updateAndScheduleSave(
      state.post.copyWith(postBaseTagsEmbedding: embJson, updatedAt: DateTime.now()),
    );

    final trendingRepo = ref.read(trendingRepositoryProvider);
    final trending = await trendingRepo.getMostRecent();
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final settings = await settingsRepo.getSettings();
    await filterTrendingTagsByRag(trending, topK: settings.trendTagsPerPost);
  }

  void updateTrendsBasePublishTags(List<String> tags) => _updateAndScheduleSave(
    state.post.copyWith(trendsBasePublishTags: tags, updatedAt: DateTime.now()),
  );

  void removeRagSuggestedTag(String tag) {
    final rag = Set<String>.from(state.ragSuggestedTags)..remove(tag);
    _updateTrendSets(rag, state.post.userAddedTrendTags);
  }

  void addUserTrendTag(String tag) {
    final userAdded = [...state.post.userAddedTrendTags, tag];
    _updateTrendSets(state.ragSuggestedTags, userAdded);
  }

  void removeUserTrendTag(String tag) {
    final userAdded = state.post.userAddedTrendTags.where((t) => t != tag).toList();
    _updateTrendSets(state.ragSuggestedTags, userAdded);
  }

  void _updateTrendSets(Set<String> rag, List<String> userAdded) {
    final allSelected = {...rag, ...userAdded};
    state = state.copyWith(ragSuggestedTags: rag, selectedTrendTags: allSelected);
    _updateAndScheduleSave(
      state.post.copyWith(
        userAddedTrendTags: userAdded,
        trendsBasePublishTags: allSelected.toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> filterTrendingTagsByRag(Trending? trending, {int? topK}) async {
    if (trending == null) return;
    final post = state.post;
    if (post.postBaseTags.isEmpty) return;

    final embStr = post.postBaseTagsEmbedding;
    if (embStr == null || embStr.isEmpty || embStr == '[]') return;

    state = state.copyWith(ragStatus: RagStatus.processing);
    final embService = ref.read(embeddingServiceProvider);
    final trendTags = trending.trendTopics
        .map((t) => t.replaceAll(' ', '_'))
        .toList();

    // Parse cached per-tag embeddings
    final List<dynamic> rawEmbeddings = jsonDecode(embStr);
    final tagEmbeddings = rawEmbeddings
        .map((e) => (e as List<dynamic>).map((v) => (v as num).toDouble()).toList())
        .toList();

    final mergedScores = <String, double>{};
    final perTagDebug = <String, List<RagTagScore>>{};
    const perTagTopN = 5;

    for (int t = 0; t < post.postBaseTags.length && t < tagEmbeddings.length; t++) {
      final tagVec = tagEmbeddings[t];
      if (tagVec.isEmpty) continue;

      final postTagWords = post.postBaseTags[t]
          .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}')
          .toLowerCase()
          .split(RegExp(r'[_\s]+'))
          .where((w) => w.isNotEmpty)
          .toSet();

      final tagScores = <String, double>{};
      for (int i = 0; i < trendTags.length; i++) {
        final trendWords = trendTags[i]
            .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}')
            .toLowerCase()
            .split(RegExp(r'[_\s]+'))
            .where((w) => w.isNotEmpty)
            .toSet();
        final keywordMatch = trendWords.intersection(postTagWords).isNotEmpty ? 0.5 : 0.0;

        double embScore = 0.0;
        if (i < trending.eachEmbedding.length && trending.eachEmbedding[i].isNotEmpty) {
          embScore = embService.cosineSimilarity(tagVec, trending.eachEmbedding[i]);
        }
        tagScores[trendTags[i]] = embScore + keywordMatch;
      }

      final sorted = tagScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.take(perTagTopN).toList();
      perTagDebug[post.postBaseTags[t]] = top.map((e) => RagTagScore(e.key, e.value)).toList();
      for (final entry in top) {
        if (!mergedScores.containsKey(entry.key) || entry.value > mergedScores[entry.key]!) {
          mergedScores[entry.key] = entry.value;
        }
      }
    }

    final finalSorted = mergedScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final mergedDebug = finalSorted.map((e) => RagTagScore(e.key, e.value)).toList();
    final topCount = topK ?? 5;
    final suggested = finalSorted.take(topCount).map((e) => e.key).toSet();
    final finalDebug = finalSorted.take(topCount).map((e) => RagTagScore(e.key, e.value)).toList();

    // Remove any user-added tags that RAG now suggests (no duplicates)
    final userAdded = state.post.userAddedTrendTags
        .where((t) => !suggested.contains(t))
        .toList();
    final allSelected = {...suggested, ...userAdded};

    state = state.copyWith(
      selectedTrendTags: allSelected,
      ragSuggestedTags: suggested,
      ragStatus: suggested.isEmpty ? RagStatus.empty : RagStatus.done,
      ragDebugData: RagDebugData(perTagResults: perTagDebug, merged: mergedDebug, final5: finalDebug),
    );
    _updateAndScheduleSave(
      state.post.copyWith(
        trendsBasePublishTags: allSelected.toList(),
        userAddedTrendTags: userAdded,
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
  Future<void> polish({
    String hookType = 'auto',
    String structure = 'auto',
    String endWithQuestion = 'auto',
  }) async {
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
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      final result = await gemini.polishPost(
        dump: post.dump,
        forLinkedIn: post.selectedPlatforms.contains(Platform.linkedin),
        forX: post.selectedPlatforms.contains(Platform.x),
        hookType: hookType,
        structure: structure,
        endWithQuestion: endWithQuestion,
        postTagMode: settings.postTagMode,
        postTagMin: settings.postTagMin,
        postTagMax: settings.postTagMax,
        postTagExact: settings.postTagExact,
      );

      if (result.hasError) {
        state = state.copyWith(isPolishing: false, polishError: result.error);
        return;
      }

      final newTags = result.tags.isNotEmpty
          ? result.tags.map((t) => t.trim().replaceAll(' ', '_')).toList()
          : post.postBaseTags;

      // Embed each tag individually
      final embService = ref.read(embeddingServiceProvider);
      final allEmbeddings = <List<double>>[];
      for (final tag in newTags) {
        final tagText = tag
            .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}')
            .replaceAll('_', ' ')
            .toLowerCase()
            .trim();
        final vec = await embService.embedChunked(tagText);
        allEmbeddings.add(vec);
      }

      final updated = post.copyWith(
        linkedinContent: result.linkedinContent ?? post.linkedinContent,
        twitterContent: result.twitterContent ?? post.twitterContent,
        postBaseTags: newTags,
        postBaseTagsEmbedding: jsonEncode(allEmbeddings),
        status: PostStatus.draft,
        isEmbedded: false,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(post: updated, isPolishing: false);
      await _save();

      // RAG-filter trending tags using the fresh tag embeddings
      final trendingRepo = ref.read(trendingRepositoryProvider);
      final trending = await trendingRepo.getMostRecent();
      await filterTrendingTagsByRag(trending, topK: settings.trendTagsPerPost);
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

      // RAG-filter trending tags using the fresh embedding
      final trendingRepo = ref.read(trendingRepositoryProvider);
      final trending = await trendingRepo.getMostRecent();
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      await filterTrendingTagsByRag(trending, topK: settings.trendTagsPerPost);

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
