import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/application/notifiers/publish_notifier.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/presentation/screens/post/post_edit_tab.dart' show mediaItemsByIdsProvider;
import 'package:castpa/presentation/widgets/preview/linkedin_preview_card.dart';
import 'package:castpa/presentation/widgets/preview/x_preview_card.dart';

class PostPreviewTab extends ConsumerWidget {
  final bool showPublishActions;

  const PostPreviewTab({
    super.key,
    this.showPublishActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(postEditProvider);
    final post = editState.post;
    final fileService = ref.watch(mediaFileServiceProvider);
    final mediaIds = ref.watch(postEditProvider.select((s) => s.post.mediaIds));
    final mediaItems = ref.watch(mediaItemsByIdsProvider(mediaIds.join(','))).valueOrNull ?? [];
    final mediaPaths = mediaItems.map((m) => fileService.getMediaFilePath(m.storedFilename)).toList();

    final hasLinkedIn = post.selectedPlatforms.contains(Platform.linkedin);
    final hasAnyContent =
        (hasLinkedIn && (post.linkedinContent?.isNotEmpty ?? false)) ||
        (post.twitterContent?.isNotEmpty ?? false);
    final isPending = post.status == PostStatus.pending || post.status == PostStatus.partialPublished;

    // Use tags already stored on the post (synced by _TagSelectionSection checkboxes)
    final allTags = [
      ...post.postBaseTags,
      ...post.categoryBasePublishTags,
      ...post.trendsBasePublishTags,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasAnyContent)
            _EmptyPreviewState()
          else ...[
            if (hasLinkedIn && (post.linkedinContent?.isNotEmpty ?? false)) ...[
              _PreviewHeader(
                label: 'LinkedIn Preview',
                content: allTags.isEmpty
                    ? post.linkedinContent!
                    : '${post.linkedinContent!}\n\n${allTags.map((t) => t.startsWith('#') ? t : '#$t').join(' ')}',
              ),
              LinkedInPreviewCard(
                content: post.linkedinContent!,
                tags: allTags,
                mediaPaths: mediaPaths,
              ),
              const SizedBox(height: 24),
            ],
            if (post.twitterContent?.isNotEmpty ?? false) ...[
              _PreviewHeader(
                label: 'X Preview',
                content: allTags.isEmpty
                    ? post.twitterContent!
                    : '${post.twitterContent!}\n\n${allTags.map((t) => t.startsWith('#') ? t : '#$t').join(' ')}',
              ),
              XPreviewCard(
                content: post.twitterContent!,
                tags: allTags,
                mediaPaths: mediaPaths,
              ),
              const SizedBox(height: 24),
            ],
          ],
          if (showPublishActions &&
              post.status != PostStatus.published) ...[
            const Divider(),
            const SizedBox(height: 12),
            _PublishSection(post: post, canPublish: isPending),
          ],
          if (post.status == PostStatus.published)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Published to all platforms', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

}

class _EmptyPreviewState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.auto_awesome, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No preview yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              'Polish your content in the Edit tab,\nthen tap "Submit" to generate the preview.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatefulWidget {
  final String label;
  final String content;
  const _PreviewHeader({required this.label, required this.content});

  @override
  State<_PreviewHeader> createState() => _PreviewHeaderState();
}

class _PreviewHeaderState extends State<_PreviewHeader> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          )),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _copied
                ? Icon(Icons.check, key: const ValueKey('check'), size: 18, color: Colors.green)
                : IconButton(
                    key: const ValueKey('copy'),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy content',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _copy,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PublishSection extends ConsumerStatefulWidget {
  final dynamic post;
  final bool canPublish;

  const _PublishSection({required this.post, required this.canPublish});

  @override
  ConsumerState<_PublishSection> createState() => _PublishSectionState();
}

class _PublishSectionState extends ConsumerState<_PublishSection> {
  List<String> _validationIssues(dynamic post) {
    final issues = <String>[];
    if (post.categoryId == null || (post.categoryId as String).isEmpty) {
      issues.add('No category selected — go to Edit tab and pick one.');
    }
    final platforms = post.selectedPlatforms as List<Platform>;
    for (final p in platforms) {
      final missing = switch (p) {
        Platform.linkedin => post.linkedinContent == null || (post.linkedinContent as String).isEmpty,
        Platform.x => post.twitterContent == null || (post.twitterContent as String).isEmpty,
      };
      if (missing) issues.add('${p.displayName} has no polished content — use Polish with AI in Edit tab.');
    }
    return issues;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final remaining = post.remainingTargets as List<Platform>;
    final publishState = ref.watch(publishNotifierProvider);

    if (remaining.isEmpty) return const SizedBox.shrink();

    final label = remaining.length == 1
        ? 'Publish to ${remaining.first.displayName}'
        : remaining.length == post.selectedPlatforms.length
            ? 'Publish to ${remaining.map((p) => p.displayName).join(' and ')}'
            : 'Publish to remaining platforms';

    final isPublishing = publishState.status == PublishStatus.publishing;
    final issues = widget.canPublish ? _validationIssues(post) : <String>[];
    final blocked = !widget.canPublish || issues.isNotEmpty || isPublishing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publish Targets', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ...post.selectedPlatforms.map<Widget>((p) {
          final published = post.publishedPlatforms.contains(p);
          final isRemaining = remaining.contains(p);
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: published || isRemaining,
            title: Text(p.displayName),
            subtitle: published ? const Text('Already published', style: TextStyle(color: Colors.green, fontSize: 12)) : null,
            enabled: false,
            onChanged: null,
          );
        }),
        const SizedBox(height: 8),
        if (!widget.canPublish)
          _IssueBox(issues: const ['Post is still a draft — submit it first to enable publishing.'], color: Colors.orange)
        else if (issues.isNotEmpty)
          _IssueBox(issues: issues, color: Colors.red),
        if (publishState.status == PublishStatus.error && publishState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _IssueBox(issues: [publishState.error!], color: Colors.red),
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: blocked ? null : () => _confirmAndPublish(context),
            icon: isPublishing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(isPublishing ? 'Publishing...' : label),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndPublish(BuildContext context) async {
    final remaining = widget.post.remainingTargets as List<Platform>;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Publish'),
        content: Text('Publish to: ${remaining.map((p) => p.displayName).join(', ')}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publish')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(publishNotifierProvider.notifier).publish(widget.post);
    if (!context.mounted) return;

    if (result.status == PublishStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Published to ${result.succeededPlatforms.map((p) => p.displayName).join(', ')}'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload the post
      ref.invalidate(postEditProvider);
    }
  }
}

class _IssueBox extends StatelessWidget {
  final List<String> issues;
  final Color color;

  const _IssueBox({required this.issues, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: issues.map((msg) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(child: Text(msg, style: TextStyle(fontSize: 13, color: color))),
          ],
        )).toList(),
      ),
    );
  }
}
