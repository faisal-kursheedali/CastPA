import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/presentation/widgets/common/weekly_progress_ring.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  DateTime get _weekStart {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final publishTarget = settings?.publishPerWeek ?? 3;

    final publishedThisWeek = ref.watch(
      _publishedThisWeekProvider(_weekStart),
    );

    final published = publishedThisWeek.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Castpa', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? _WideLayout(published: published, target: publishTarget)
              : _NarrowLayout(published: published, target: publishTarget),
        );
      }),
    );
  }
}

final _publishedThisWeekProvider = FutureProvider.autoDispose.family((ref, DateTime weekStart) {
  return ref.watch(postRepositoryProvider).getPostsPublishedInWeek(weekStart);
});

class _WideLayout extends StatelessWidget {
  final int published;
  final int target;
  const _WideLayout({required this.published, required this.target});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _HeaderCard(published: published, target: target),
              const SizedBox(height: 16),
              const _CreateCard(),
              const SizedBox(height: 16),
              const _TrendingCard(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(flex: 1, child: _ShortcutsPanel()),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final int published;
  final int target;
  const _NarrowLayout({required this.published, required this.target});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderCard(published: published, target: target),
        const SizedBox(height: 16),
        const _CreateCard(),
        const SizedBox(height: 16),
        const _TrendingCard(),
        const SizedBox(height: 16),
        const _ShortcutsPanel(),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int published;
  final int target;
  const _HeaderCard({required this.published, required this.target});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.push('/queue/published?week=true'),
              child: WeeklyProgressRing(published: published, target: target),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/queue/pending'),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Publish Post'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push('/queue/draft'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Complete Drafts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push('/post/new'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.add_circle_outline, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'Create New Post',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Capture your idea now', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutsPanel extends StatelessWidget {
  const _ShortcutsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Quick Access', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        _ShortcutTile(
          icon: Icons.pending_actions_outlined,
          label: 'Pending',
          color: Colors.orange,
          onTap: () => context.push('/queue/pending'),
        ),
        _ShortcutTile(
          icon: Icons.check_circle_outline,
          label: 'Published',
          color: Colors.green,
          onTap: () => context.push('/queue/published'),
        ),
        _ShortcutTile(
          icon: Icons.category_outlined,
          label: 'Category Manager',
          color: Colors.purple,
          onTap: () => context.push('/categories'),
        ),
      ],
    );
  }
}

class _TrendingCard extends ConsumerStatefulWidget {
  const _TrendingCard();

  @override
  ConsumerState<_TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends ConsumerState<_TrendingCard> {
  bool _fetching = false;

  Future<void> _fetch() async {
    setState(() => _fetching = true);
    try {
      await ref.read(trendingServiceProvider).forceFetch();
      ref.invalidate(latestTrendingProvider);
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trending = ref.watch(latestTrendingProvider).valueOrNull;
    final autoFetching = ref.watch(trendingInitProvider).isLoading;
    final isLoading = _fetching || autoFetching;

    final hasTrendTopics = trending != null && trending.trendTopics.isNotEmpty;
    final hasCategoryTopics = trending != null &&
        trending.categoryTopics.values.any((list) => list.isNotEmpty);

    String lastFetchLabel = 'Never fetched';
    if (trending != null) {
      final d = trending.addedDate;
      lastFetchLabel =
          'Last fetched: ${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Trending Topics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : OutlinedButton.icon(
                          onPressed: _fetch,
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Fetch'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            textStyle: theme.textTheme.labelSmall,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(lastFetchLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            _ActivityRow(
              label: 'Trend Topics',
              status: isLoading ? _ActivityStatus.loading : (hasTrendTopics ? _ActivityStatus.ok : _ActivityStatus.empty),
            ),
            const SizedBox(height: 6),
            _ActivityRow(
              label: 'Category Topics',
              status: isLoading ? _ActivityStatus.loading : (hasCategoryTopics ? _ActivityStatus.ok : _ActivityStatus.empty),
            ),
            if (!isLoading && trending?.fetchError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trending!.fetchError!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ActivityStatus { ok, empty, loading }

class _ActivityRow extends StatelessWidget {
  final String label;
  final _ActivityStatus status;

  const _ActivityRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget icon;
    switch (status) {
      case _ActivityStatus.ok:
        icon = const Icon(Icons.check_circle, color: Colors.green, size: 18);
      case _ActivityStatus.empty:
        icon = Icon(Icons.cancel, color: theme.colorScheme.error, size: 18);
      case _ActivityStatus.loading:
        icon = const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
