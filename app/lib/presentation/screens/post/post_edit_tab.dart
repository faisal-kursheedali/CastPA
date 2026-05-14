import 'dart:io';
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
          // Tags
          TagChipsEditor(
            label: 'Post Base Tags',
            tags: post.postBaseTags,
            readOnly: widget.readOnly,
            onChanged: (tags) => ref.read(postEditProvider.notifier).updatePostBaseTags(tags),
          ),
          _TrendingTagsSection(
            selectedCategoryId: post.categoryId,
            categories: categories,
            currentCategoryTags: post.categoryBasePublishTags,
            currentTrendTags: post.trendsBasePublishTags,
          ),
          const SizedBox(height: 24),
          // Polish button
          if (!widget.readOnly && !widget.tagOnlyEdit) ...[
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
                onPressed: isPolishing ? null : () => ref.read(postEditProvider.notifier).polish(),
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
        case PickFileSuccess(:final item):
          final mediaRepo = ref.read(mediaRepositoryProvider);
          await mediaRepo.addMedia(item);
          final currentIds = ref.read(postEditProvider).post.mediaIds;
          final ids = List<String>.from(currentIds)..add(item.id);
          ref.read(postEditProvider.notifier).updateMediaIds(ids);
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickFromLibrary(BuildContext context, WidgetRef ref) async {
    final fileService = ref.read(mediaFileServiceProvider);
    final allMedia = await ref.read(mediaRepositoryProvider).getAllMedia();
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
    final isImg = MediaFileService.isImage(item.storedFilename);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: isImg
              ? Image.file(
                  File(filePath),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => _placeholder(isImg),
                )
              : _placeholder(isImg),
        ),
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

  Widget _placeholder(bool isImg) {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      child: Icon(
        isImg ? Icons.image_outlined : Icons.videocam_outlined,
        color: Colors.grey,
      ),
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
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.currentIds);
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
                  final filePath = widget.fileService.getMediaFilePath(item.storedFilename);
                  final isImg = MediaFileService.isImage(item.storedFilename);
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: isImg
                              ? Image.file(File(filePath), fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, s) => _libraryPlaceholder(isImg))
                              : _libraryPlaceholder(isImg),
                        ),
                        if (selected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        if (!isImg)
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.videocam, size: 16, color: Colors.white70),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            widget.allMedia.where((m) => _selectedIds.contains(m.id)).toList(),
          ),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _libraryPlaceholder(bool isImg) {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(isImg ? Icons.image_outlined : Icons.videocam_outlined, color: Colors.grey),
    );
  }
}

class _TrendingTagsSection extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final List<Category> categories;
  final List<String> currentCategoryTags;
  final List<String> currentTrendTags;

  const _TrendingTagsSection({
    required this.selectedCategoryId,
    required this.categories,
    required this.currentCategoryTags,
    required this.currentTrendTags,
  });

  @override
  ConsumerState<_TrendingTagsSection> createState() => _TrendingTagsSectionState();
}

class _TrendingTagsSectionState extends ConsumerState<_TrendingTagsSection> {
  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(latestTrendingProvider);
    final trending = trendingAsync.valueOrNull;

    final selectedCategory = widget.selectedCategoryId == null
        ? null
        : widget.categories.where((c) => c.id == widget.selectedCategoryId).firstOrNull;

    final categoryTags = selectedCategory == null
        ? <String>[]
        : (trending?.categoryTopics[selectedCategory.name.toUpperCase()] ?? []);

    final trendTags = trending?.trendTopics.map((t) => t.replaceAll(' ', '_')).toList() ?? [];

    // Sync resolved tags back into the post so publish_notifier can use them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(postEditProvider.notifier);
      if (categoryTags.join() != widget.currentCategoryTags.join()) {
        notifier.updateCategoryBasePublishTags(categoryTags);
      }
      if (trendTags.join() != widget.currentTrendTags.join()) {
        notifier.updateTrendsBasePublishTags(trendTags);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categoryTags.isNotEmpty)
          TagChipsEditor(
            label: 'Category Tags',
            tags: categoryTags,
            readOnly: true,
          ),
        TagChipsEditor(
          label: 'Trends Tags',
          tags: trendTags,
          readOnly: true,
        ),
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
