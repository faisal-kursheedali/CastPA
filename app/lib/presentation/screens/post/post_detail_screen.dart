import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/presentation/screens/post/post_edit_tab.dart';
import 'package:castpa/presentation/screens/post/post_preview_tab.dart';
import 'package:castpa/presentation/widgets/common/rag_status_indicator.dart';
import 'package:castpa/presentation/widgets/common/save_status_indicator.dart';

final _postDetailProvider = FutureProvider.autoDispose.family<Post?, String>((
  ref,
  id,
) {
  return ref.watch(postRepositoryProvider).getPostById(id);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _postLoaded = false;
  int _lockedEditTapCount = 0;
  bool _tagOnlyUnlocked = false;
  bool _fullUnlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLockedTap(PostStatus status) {
    if (status != PostStatus.partialPublished) return;
    _lockedEditTapCount++;
    if (_lockedEditTapCount >= 10) {
      setState(() => _fullUnlocked = true);
      _lockedEditTapCount = 0;
    } else if (_lockedEditTapCount >= 5) {
      setState(() => _tagOnlyUnlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(_postDetailProvider(widget.postId));

    return postAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (post) {
        if (post == null)
          return const Scaffold(body: Center(child: Text('Post not found')));

        // Load post into edit notifier once
        if (!_postLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(postEditProvider.notifier).loadPost(post);
          });
          _postLoaded = true;
        }

        final editState = ref.watch(postEditProvider);
        // Read status from postEditProvider so AppBar updates instantly
        // when copy-to-platform patches the state (e.g. pending → partialPublished).
        final status = editState.post.status == PostStatus.draft && post.status != PostStatus.draft
            ? post.status
            : editState.post.status;
        final isPublished = status == PostStatus.published;
        final isPartialPublished = status == PostStatus.partialPublished;
        final isLocked = isPublished || (isPartialPublished && !_fullUnlocked);
        final isTagOnly =
            isPartialPublished && _tagOnlyUnlocked && !_fullUnlocked;

        final saveState = editState.saveState;

        ref.listen(postEditProvider, (_, next) {
          if (next.saveState == SaveState.deleted && context.mounted) {
            Navigator.of(context).pop();
          }
        });


        return Scaffold(
          appBar: AppBar(
            title: Text(status.displayName),
            actions: [if (!isLocked) RagStatusIndicator(ragStatus: editState.ragStatus), if (!isLocked) SaveStatusIndicator(saveState: saveState)],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Preview'),
                Tab(text: 'Edit'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              const PostPreviewTab(showPublishActions: true),
              isLocked
                  ? GestureDetector(
                      onTap: () => _handleLockedTap(status),
                      child: _LockedEditMessage(
                        isPartialPublished: isPartialPublished,
                        tapCount: _lockedEditTapCount,
                      ),
                    )
                  : PostEditTab(readOnly: isPublished, tagOnlyEdit: isTagOnly),
            ],
          ),
        );
      },
    );
  }
}

class _LockedEditMessage extends StatelessWidget {
  final bool isPartialPublished;
  final int tapCount;

  const _LockedEditMessage({
    required this.isPartialPublished,
    required this.tapCount,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isPartialPublished ? 'Edit Locked' : 'Post Published',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (isPartialPublished) ...[
              Text(
                'Tap 5 times to unlock tag editing\nTap 10 times for full edit',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              if (tapCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$tapCount taps',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ] else
              Text(
                'This post has been fully published.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
