import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/providers/repository_providers.dart';

class TrendingDetailScreen extends ConsumerWidget {
  const TrendingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(latestTrendingProvider);
    final trending = trendingAsync.valueOrNull;

    if (trending == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trending Details')),
        body: const Center(child: Text('No trending data available')),
      );
    }

    final rawTags = trending.rawTrendingTopics;
    final filteredTags = trending.trendTopics;
    final removedTags = rawTags.where((t) => !filteredTags.contains(t)).toList();
    final hasFetchError = trending.fetchError != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy as JSON',
            onPressed: () {
              final json = jsonEncode({
                'addedDate': trending.addedDate.toIso8601String(),
                'platform': trending.platform,
                'trendFetchSuccess': rawTags.isNotEmpty,
                'geminiFilterSuccess': trending.geminiFilterSuccess,
                'fetchError': trending.fetchError,
                'rawTags': rawTags,
                'filteredTags': filteredTags,
                'removedTags': removedTags,
              });
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusRow(
              label: 'Trend Fetch',
              success: rawTags.isNotEmpty,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Gemini Filter',
              success: trending.geminiFilterSuccess,
            ),
            if (hasFetchError) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trending.fetchError!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _TagSection(
              title: 'Raw Tags (${rawTags.length})',
              subtitle: 'Fetched from dev.to trending articles',
              tags: rawTags,
            ),
            const SizedBox(height: 16),
            _TagSection(
              title: 'Filtered Tags (${filteredTags.length})',
              subtitle: 'Gemini filter output — tags kept for use',
              tags: filteredTags,
            ),
            if (removedTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              _TagSection(
                title: 'Removed Tags (${removedTags.length})',
                subtitle: 'dev.to tags removed by Gemini filter',
                tags: removedTags,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool success;

  const _StatusRow({required this.label, required this.success});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          success ? Icons.check_circle : Icons.cancel,
          color: success ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> tags;
  final Color? color;

  const _TagSection({required this.title, this.subtitle, required this.tags, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 8),
        if (tags.isEmpty)
          const Text('None', style: TextStyle(fontSize: 12, color: Colors.grey))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }
}
