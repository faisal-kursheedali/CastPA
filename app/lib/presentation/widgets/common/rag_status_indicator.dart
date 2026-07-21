import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/presentation/screens/post/rag_debug_screen.dart';

class RagStatusIndicator extends ConsumerWidget {
  final RagStatus ragStatus;

  const RagStatusIndicator({super.key, required this.ragStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _onTap(context, ref),
      onLongPress: () {
        if (ragStatus == RagStatus.idle) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Run a RAG filter first to view debug data. Tap the icon to start.')),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RagDebugScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: switch (ragStatus) {
          RagStatus.processing => const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          RagStatus.done => const Icon(Icons.tag, size: 18, color: Colors.green),
          RagStatus.empty => const Icon(Icons.tag, size: 18, color: Colors.red),
          RagStatus.idle => const Icon(Icons.tag, size: 18, color: Colors.grey),
        },
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    final editState = ref.read(postEditProvider);
    if (editState.post.postBaseTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No post base tags to filter')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-run RAG Filter?'),
        content: const Text(
          'This will re-calculate trending tag suggestions based on your post tags. '
          'Your current trending tag selection will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _runRagFilter(ref);
            },
            child: const Text('Re-filter'),
          ),
        ],
      ),
    );
  }

  Future<void> _runRagFilter(WidgetRef ref) async {
    final notifier = ref.read(postEditProvider.notifier);
    final trending = ref.read(latestTrendingProvider).valueOrNull;
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    final topK = settings?.trendTagsPerPost ?? 5;
    await notifier.filterTrendingTagsByRag(trending, topK: topK);
  }
}
