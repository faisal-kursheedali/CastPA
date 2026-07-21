import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';

class RagDebugScreen extends ConsumerWidget {
  const RagDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(postEditProvider);
    final post = editState.post;
    final debug = editState.ragDebugData;

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Post Base Tags', post.postBaseTags.map((t) => '#$t').toList()),
            const Divider(height: 32),

            if (debug == null)
              const Text('No RAG data yet. Polish or add tags to generate.', style: TextStyle(color: Colors.grey))
            else ...[
              // Per-tag results
              Text('Per-Tag Top 5', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...debug.perTagResults.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  ...entry.value.map((s) => _scoreRow(s)),
                  const SizedBox(height: 12),
                ],
              )),

              const Divider(height: 32),

              // Merged
              Text('Merged (deduplicated, sorted)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...debug.merged.map((s) => _scoreRow(s)),

              const Divider(height: 32),

              // Final top K
              Text('Final Selected (top ${debug.final5.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...debug.final5.map((s) => _scoreRow(s, highlight: true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) => Text(title, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('None', style: TextStyle(color: Colors.grey, fontSize: 13))
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
      ],
    );
  }

  Widget _scoreRow(RagTagScore s, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              s.score.toStringAsFixed(4),
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: highlight ? Colors.green : Colors.grey.shade600,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${s.tag}',
            style: TextStyle(
              fontSize: 13,
              color: highlight ? null : Colors.grey.shade700,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
