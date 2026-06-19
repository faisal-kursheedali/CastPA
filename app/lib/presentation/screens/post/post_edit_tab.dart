import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/data/services/media_file_service.dart';
import 'package:castpa/application/notifiers/category_notifier.dart';
import 'package:castpa/application/notifiers/recording_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/category.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/media_item.dart';
import 'package:castpa/presentation/widgets/common/media_item_widget.dart';
import 'package:castpa/presentation/widgets/post/tag_chips_editor.dart';

class PostEditTab extends ConsumerStatefulWidget {
  final bool readOnly;
  final bool tagOnlyEdit;

  const PostEditTab({
    super.key,
    this.readOnly = false,
    this.tagOnlyEdit = false,
  });

  @override
  ConsumerState<PostEditTab> createState() => _PostEditTabState();
}

class _PostEditTabState extends ConsumerState<PostEditTab> {
  late TextEditingController _dumpCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _twitterCtrl;
  late TextEditingController _linkCtrl;
  bool _initialized = false;
  int _xTapCount = 0;

  // Polish config
  bool _polishConfigOpen = false;
  String _hookType = 'auto';
  String _structure = 'auto';
  String _endWithQuestion = 'auto';

  static const _hookSuggestions = {
    'fear': 'pas',
    'aspiration': 'bab',
    'contrarian': 'contrarian',
  };
  static const _structureSuggestions = {
    'pas': 'fear',
    'bab': 'aspiration',
    'contrarian': 'contrarian',
  };

  void _onHookChanged(String? value) {
    if (value == null) return;
    setState(() {
      _hookType = value;
      if (value != 'auto' && _hookSuggestions.containsKey(value)) {
        _structure = _hookSuggestions[value]!;
      }
    });
  }

  void _onStructureChanged(String? value) {
    if (value == null) return;
    setState(() {
      _structure = value;
      if (value != 'auto' && _structureSuggestions.containsKey(value)) {
        _hookType = _structureSuggestions[value]!;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _dumpCtrl = TextEditingController();
    _linkedinCtrl = TextEditingController();
    _twitterCtrl = TextEditingController();
    _linkCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _dumpCtrl.dispose();
    _linkedinCtrl.dispose();
    _twitterCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(PostEditState editState) {
    if (!_initialized) {
      _dumpCtrl.text = editState.post.dump;
      _linkedinCtrl.text = editState.post.linkedinContent ?? '';
      _twitterCtrl.text = editState.post.twitterContent ?? '';
      _initialized = true;
    }
  }

  void _syncAfterPolish(PostEditState next) {
    _linkedinCtrl.text = next.post.linkedinContent ?? '';
    _twitterCtrl.text = next.post.twitterContent ?? '';
  }

  void _addLink() {
    final link = _linkCtrl.text.trim();
    if (link.isEmpty) return;
    final state = ref.read(postEditProvider);
    ref.read(postEditProvider.notifier).updateLinks([...state.post.links, link]);
    _linkCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(postEditProvider);
    _syncControllers(editState);

    ref.listen(postEditProvider, (prev, next) {
      if (prev?.isPolishing == true && !next.isPolishing) {
        _syncAfterPolish(next);
      }
    });

    final post = editState.post;
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final isPolishing = editState.isPolishing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dump
          if (!widget.tagOnlyEdit) ...[
            _sectionLabel('Dump'),
            TextField(
              controller: _dumpCtrl,
              maxLines: 6,
              readOnly: widget.readOnly,
              decoration: const InputDecoration(
                hintText: 'Capture your raw idea here...',
                alignLabelWithHint: true,
              ),
              onChanged: (v) => ref.read(postEditProvider.notifier).updateDump(v),
            ),
            if (!widget.readOnly) ...[
              const SizedBox(height: 8),
              _RecordingBar(dumpCtrl: _dumpCtrl),
            ],
            const SizedBox(height: 16),
            // Links
            _sectionLabel('Links'),
            ...post.links.asMap().entries.map((entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link, size: 18),
              title: Text(entry.value, overflow: TextOverflow.ellipsis),
              trailing: widget.readOnly
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        final links = [...post.links]..removeAt(entry.key);
                        ref.read(postEditProvider.notifier).updateLinks(links);
                      },
                    ),
            )),
            if (!widget.readOnly) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _linkCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Add link URL',
                        prefixIcon: Icon(Icons.link),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addLink(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addLink,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Platforms
            _sectionLabel('Platforms'),
            Row(
              children: Platform.values.map((p) {
                final selected = post.selectedPlatforms.contains(p);
                final isX = p == Platform.x;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: isX
                      ? GestureDetector(
                          onTap: widget.readOnly
                              ? null
                              : () {
                                  setState(() => _xTapCount++);
                                  if (_xTapCount >= 5) {
                                    setState(() => _xTapCount = 0);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('X publishing coming soon!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          child: FilterChip(
                            label: Text(p.displayName),
                            selected: false,
                            onSelected: null,
                          ),
                        )
                      : FilterChip(
                          label: Text(p.displayName),
                          selected: selected,
                          onSelected: widget.readOnly
                              ? null
                              : (val) {
                                  final platforms = [...post.selectedPlatforms];
                                  if (val) {
                                    platforms.add(p);
                                  } else {
                                    platforms.remove(p);
                                  }
                                  ref.read(postEditProvider.notifier).updateSelectedPlatforms(platforms);
                                },
                        ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Category
            _sectionLabel('Category'),
            DropdownButtonFormField<String>(
              value: post.categoryId,
              items: [
                const DropdownMenuItem(value: null, child: Text('No category')),
                ...categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Row(children: [
                    Text(c.name),
                    if (!c.isActive) const Text(' (inactive)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                )),
              ],
              onChanged: widget.readOnly
                  ? null
                  : (val) => ref.read(postEditProvider.notifier).updateCategoryId(val),
              decoration: const InputDecoration(hintText: 'Select category'),
            ),
            const SizedBox(height: 16),
            // Media
            _sectionLabel('Media'),
            _MediaSection(readOnly: widget.readOnly),
            const SizedBox(height: 16),
          ],
          // Platform content fields
          if (!widget.tagOnlyEdit) ...[
            if (post.selectedPlatforms.contains(Platform.linkedin)) ...[
              _sectionLabel('LinkedIn Content'),
              TextField(
                controller: _linkedinCtrl,
                maxLines: 8,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  hintText: 'LinkedIn post content...',
                  alignLabelWithHint: true,
                ),
                onChanged: (v) => ref.read(postEditProvider.notifier).updateLinkedinContent(v),
              ),
              const SizedBox(height: 16),
            ],
            _sectionLabel('X (Twitter) Content'),
            TextField(
              controller: _twitterCtrl,
              maxLines: 4,
              readOnly: widget.readOnly,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: 'X post content (max 280 chars)...',
                alignLabelWithHint: true,
              ),
              onChanged: (v) => ref.read(postEditProvider.notifier).updateTwitterContent(v),
            ),
            const SizedBox(height: 16),
          ],
          // Tag checkboxes + tags
          _TagSelectionSection(
            selectedCategoryId: post.categoryId,
            categories: categories,
            readOnly: widget.readOnly,
          ),
          const SizedBox(height: 24),
          // Polish config + button
          if (!widget.readOnly && !widget.tagOnlyEdit) ...[
            // Collapsible config header
            InkWell(
              onTap: () => setState(() => _polishConfigOpen = !_polishConfigOpen),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(_polishConfigOpen ? Icons.expand_less : Icons.expand_more,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Polish Configuration',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
            if (_polishConfigOpen) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _PolishDropdown(
                      label: 'Hook',
                      value: _hookType,
                      items: const {
                        'auto': 'Auto (AI picks best)',
                        'contrarian': 'Contrarian',
                        'curiosity': 'Curiosity',
                        'fear': 'Fear',
                        'stat': 'Stat',
                        'aspiration': 'Aspiration',
                      },
                      onChanged: _onHookChanged,
                    ),
                    const SizedBox(height: 10),
                    _PolishDropdown(
                      label: 'Structure',
                      value: _structure,
                      items: const {
                        'auto': 'Auto (AI picks best)',
                        'pas': 'PAS — Problem → Agitate → Solution',
                        'bab': 'BAB — Before → After → Bridge',
                        'contrarian': 'Contrarian — Claim → Points → Takeaway',
                      },
                      onChanged: _onStructureChanged,
                    ),
                    const SizedBox(height: 10),
                    _PolishDropdown(
                      label: 'End with question',
                      value: _endWithQuestion,
                      items: const {
                        'auto': 'Auto (if it fits naturally)',
                        'yes': 'Yes — always',
                        'no': 'No — never',
                      },
                      onChanged: (v) => setState(() => _endWithQuestion = v ?? 'auto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (editState.polishError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(editState.polishError!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isPolishing ? null : () => ref.read(postEditProvider.notifier).polish(
                  hookType: _hookType,
                  structure: _structure,
                  endWithQuestion: _endWithQuestion,
                ),
                icon: isPolishing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(isPolishing ? 'Polishing...' : 'Polish with AI'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: editState.isSubmitting ? null : () => _handleSubmit(context, ref),
                icon: editState.isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(editState.isSubmitting ? 'Generating preview...' : 'Submit'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(postEditProvider.notifier).submit();
    if (!context.mounted) return;
    switch (result) {
      case SubmitResult.pending:
        Navigator.of(context).pop();
      case SubmitResult.removed:
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post removed — no content found.')),
        );
      case SubmitResult.draft:
      case null:
        break;
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

// Key is comma-joined IDs string — List<String> has no value equality so can't be used as family key.
final mediaItemsByIdsProvider = FutureProvider.family<List<MediaItem>, String>((ref, joinedIds) async {
  if (joinedIds.isEmpty) return [];
  final ids = joinedIds.split(',');
  return ref.read(mediaRepositoryProvider).getMediaByIds(ids);
});

class _MediaSection extends ConsumerWidget {
  final bool readOnly;

  const _MediaSection({required this.readOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileService = ref.watch(mediaFileServiceProvider);
    final mediaIds = ref.watch(postEditProvider.select((s) => s.post.mediaIds));
    final mediaAsync = ref.watch(mediaItemsByIdsProvider(mediaIds.join(',')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mediaAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
          data: (mediaItems) => mediaItems.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mediaItems.map<Widget>((item) => _MediaThumb(
                    item: item,
                    filePath: fileService.getMediaFilePath(item.storedFilename),
                    onRemove: readOnly ? null : () {
                      final ids = List<String>.from(mediaIds)..remove(item.id);
                      ref.read(postEditProvider.notifier).updateMediaIds(ids);
                    },
                  )).toList(),
                )
              : const SizedBox.shrink(),
        ),
        if (!readOnly) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Upload'),
                onPressed: () => _uploadFile(context, ref),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('From Library'),
                onPressed: () => _pickFromLibrary(context, ref),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _uploadFile(BuildContext context, WidgetRef ref) async {
    try {
      final fileService = ref.read(mediaFileServiceProvider);
      if (fileService.mediaFolderPath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync folder not configured')),
        );
        return;
      }
      final result = await fileService.pickAndSaveFile();
      if (!context.mounted) return;
      switch (result) {
        case PickFileCancelled():
          return;
        case PickFilePermissionDenied(:final isPermanentlyDenied):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPermanentlyDenied
                    ? 'Storage permission permanently denied. Enable it in Settings.'
                    : 'Storage permission denied.',
              ),
              action: isPermanentlyDenied
                  ? SnackBarAction(label: 'Settings', onPressed: openAppSettings)
                  : null,
            ),
          );
          return;
        case PickFileSuccess(:final items):
          final mediaRepo = ref.read(mediaRepositoryProvider);
          final currentIds = ref.read(postEditProvider).post.mediaIds;
          final ids = List<String>.from(currentIds);
          for (final item in items) {
            await mediaRepo.addMedia(item);
            ids.add(item.id);
          }
          ref.read(postEditProvider.notifier).updateMediaIds(ids);
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickFromLibrary(BuildContext context, WidgetRef ref) async {
    final fileService = ref.read(mediaFileServiceProvider);
    final allMedia = await ref.read(mediaRepositoryProvider).getAllMedia()
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));
    if (!context.mounted) return;

    final currentIds = ref.read(postEditProvider).post.mediaIds;
    final selected = await showDialog<List<MediaItem>>(
      context: context,
      builder: (_) => _MediaLibraryDialog(
        allMedia: allMedia,
        currentIds: List<String>.from(currentIds),
        fileService: fileService,
      ),
    );

    if (selected != null) {
      final ids = selected.map((m) => m.id).toList();
      ref.read(postEditProvider.notifier).updateMediaIds(ids);
    }
  }
}

class _MediaThumb extends StatelessWidget {
  final MediaItem item;
  final String filePath;
  final VoidCallback? onRemove;

  const _MediaThumb({required this.item, required this.filePath, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MediaThumbWidget(path: filePath, size: 72),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _MediaLibraryDialog extends StatefulWidget {
  final List<MediaItem> allMedia;
  final List<String> currentIds;
  final MediaFileService fileService;

  const _MediaLibraryDialog({
    required this.allMedia,
    required this.currentIds,
    required this.fileService,
  });

  @override
  State<_MediaLibraryDialog> createState() => _MediaLibraryDialogState();
}

class _MediaLibraryDialogState extends State<_MediaLibraryDialog> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.currentIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Media Library'),
      content: SizedBox(
        width: 360,
        child: widget.allMedia.isEmpty
            ? const Center(child: Text('No media in library'))
            : GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: widget.allMedia.length,
                itemBuilder: (_, i) {
                  final item = widget.allMedia[i];
                  final selected = _selectedIds.contains(item.id);
                  final selIndex = _selectedIds.indexOf(item.id);
                  final filePath = widget.fileService.getMediaFilePath(item.storedFilename);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedIds.remove(item.id);
                      } else {
                        _selectedIds.add(item.id);
                      }
                    }),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaThumbWidget(path: filePath),
                        if (selected) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                '${selIndex + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final byId = {for (final m in widget.allMedia) m.id: m};
            Navigator.pop(context, _selectedIds.map((id) => byId[id]).whereType<MediaItem>().toList());
          },
          child: const Text('Select'),
        ),
      ],
    );
  }

}

class _TagSelectionSection extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final List<Category> categories;
  final bool readOnly;

  const _TagSelectionSection({
    required this.selectedCategoryId,
    required this.categories,
    required this.readOnly,
  });

  @override
  ConsumerState<_TagSelectionSection> createState() => _TagSelectionSectionState();
}

class _TagSelectionSectionState extends ConsumerState<_TagSelectionSection> {
  // Resolved tags from trending data (source of truth for syncing back)
  List<String> _resolvedCategoryTags = [];
  List<String> _resolvedTrendTags = [];

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(latestTrendingProvider);
    final trending = trendingAsync.valueOrNull;
    final editState = ref.watch(postEditProvider);
    final post = editState.post;
    final includeTrending = editState.includeTrendingTags;
    final includeCategory = editState.includeCategoryTags;

    final selectedCategory = widget.selectedCategoryId == null
        ? null
        : widget.categories.where((c) => c.id == widget.selectedCategoryId).firstOrNull;

    final categoryTags = selectedCategory == null
        ? <String>[]
        : (trending?.categoryTopics[selectedCategory.name.toUpperCase()] ?? []);

    final trendTags = trending?.trendTopics.map((t) => t.replaceAll(' ', '_')).toList() ?? [];

    // Keep resolved tags up to date for use in callbacks
    _resolvedCategoryTags = categoryTags;
    _resolvedTrendTags = trendTags;

    // Sync resolved tags into the post whenever the source data changes,
    // respecting the current checkbox state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(postEditProvider.notifier);
      final expectedCategory = includeCategory ? categoryTags : <String>[];
      final expectedTrend = includeTrending ? trendTags : <String>[];
      if (expectedCategory.join() != post.categoryBasePublishTags.join()) {
        notifier.updateCategoryBasePublishTags(expectedCategory);
      }
      if (expectedTrend.join() != post.trendsBasePublishTags.join()) {
        notifier.updateTrendsBasePublishTags(expectedTrend);
      }
    });

    final hasCategorySelected = widget.selectedCategoryId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post base tags editor
        TagChipsEditor(
          label: 'Post Base Tags',
          tags: post.postBaseTags,
          readOnly: widget.readOnly,
          onChanged: (tags) => ref.read(postEditProvider.notifier).updatePostBaseTags(tags),
        ),
        const SizedBox(height: 8),

        // Trending tags checkbox
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: includeTrending,
          title: const Text('Include Trending Tags'),
          subtitle: trendTags.isEmpty ? const Text('No trending tags available', style: TextStyle(fontSize: 12)) : null,
          enabled: !widget.readOnly && trendTags.isNotEmpty,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: widget.readOnly || trendTags.isEmpty
              ? null
              : (val) => ref
                  .read(postEditProvider.notifier)
                  .setIncludeTrendingTags(val ?? false, _resolvedTrendTags),
        ),

        // Category tags checkbox — only visible when a category is selected
        if (hasCategorySelected)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: includeCategory,
            title: const Text('Include Category Tags'),
            subtitle: categoryTags.isEmpty ? const Text('No category tags available', style: TextStyle(fontSize: 12)) : null,
            enabled: !widget.readOnly && categoryTags.isNotEmpty,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: widget.readOnly || categoryTags.isEmpty
                ? null
                : (val) => ref
                    .read(postEditProvider.notifier)
                    .setIncludeCategoryTags(val ?? false, _resolvedCategoryTags),
          ),

        // Show selected tag chips
        if (includeTrending && trendTags.isNotEmpty) ...[
          const SizedBox(height: 4),
          TagChipsEditor(
            label: 'Trending Tags',
            tags: trendTags,
            readOnly: true,
          ),
        ],
        if (hasCategorySelected && includeCategory && categoryTags.isNotEmpty) ...[
          const SizedBox(height: 4),
          TagChipsEditor(
            label: 'Category Tags',
            tags: categoryTags,
            readOnly: true,
          ),
        ],
      ],
    );
  }
}

class _RecordingBar extends ConsumerWidget {
  final TextEditingController dumpCtrl;

  const _RecordingBar({required this.dumpCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = ref.watch(recordingProvider);
    final notifier = ref.read(recordingProvider.notifier);

    // When a transcript arrives, append it to the dump field
    ref.listen(recordingProvider, (prev, next) {
      if (next.transcript != null && next.transcript != prev?.transcript) {
        final current = dumpCtrl.text;
        final appended = current.isEmpty
            ? next.transcript!
            : '$current\n${next.transcript!}';
        dumpCtrl.text = appended;
        dumpCtrl.selection = TextSelection.collapsed(offset: appended.length);
        ref.read(postEditProvider.notifier).updateDump(appended);
        notifier.clearTranscript();
      }
    });

    final theme = Theme.of(context);

    if (recording.isIdle) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: notifier.startRecording,
          icon: const Icon(Icons.mic, size: 18),
          label: const Text('Record'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    if (recording.isRecording) {
      return Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text('Recording…', style: theme.textTheme.bodySmall),
          const Spacer(),
          TextButton.icon(
            onPressed: notifier.cancelRecording,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: notifier.stopAndTranscribe,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Done'),
            style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      );
    }

    if (recording.isTranscribing) {
      return Row(
        children: [
          const SizedBox(width: 2, height: 2, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text('Transcribing…', style: theme.textTheme.bodySmall),
        ],
      );
    }

    // error state
    if (recording.error != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              recording.error!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: notifier.cancelRecording,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Dismiss'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _PolishDropdown extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _PolishDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            isDense: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: items.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
