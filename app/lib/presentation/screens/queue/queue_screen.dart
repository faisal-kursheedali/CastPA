import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:castpa/application/notifiers/post_list_notifier.dart';
import 'package:castpa/application/notifiers/category_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/category.dart';

enum _SortMode { date, trend }

class QueueScreen extends ConsumerStatefulWidget {
  final PostStatus status;
  final List<PostStatus> extraStatuses;
  final bool filterCurrentWeek;

  const QueueScreen({
    super.key,
    required this.status,
    this.extraStatuses = const [],
    this.filterCurrentWeek = false,
  });

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  bool _isTableView = false;
  _SortMode _sortMode = _SortMode.date;
  bool _sortAsc = false;
  Set<String> _selectedCategoryIds = {};
  String? _timeFilter; // 'today', 'week', 'month'
  bool _isFetchingTrend = false;
  List<Post>? _trendSortedPosts;

  @override
  void initState() {
    super.initState();
    if (widget.filterCurrentWeek) _timeFilter = 'week';
  }

  List<Post> _applyFilters(List<Post> posts, List<Category> categories) {
    var filtered = posts;

    if (_selectedCategoryIds.isNotEmpty) {
      filtered = filtered
          .where((p) => _selectedCategoryIds.contains(p.categoryId))
          .toList();
    }

    final now = DateTime.now();
    if (_timeFilter == 'today') {
      filtered = filtered
          .where(
            (p) =>
                p.updatedAt.year == now.year &&
                p.updatedAt.month == now.month &&
                p.updatedAt.day == now.day,
          )
          .toList();
    } else if (_timeFilter == 'week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      filtered = filtered.where((p) => p.updatedAt.isAfter(weekStart)).toList();
    } else if (_timeFilter == 'month') {
      filtered = filtered
          .where(
            (p) =>
                p.updatedAt.year == now.year && p.updatedAt.month == now.month,
          )
          .toList();
    }

    return filtered;
  }

  List<Post> _applySort(List<Post> posts) {
    if (_sortMode == _SortMode.trend && _trendSortedPosts != null) {
      final order = {for (int i = 0; i < _trendSortedPosts!.length; i++) _trendSortedPosts![i].id: i};
      final sorted = [...posts]..sort((a, b) {
        final ia = order[a.id] ?? 999999;
        final ib = order[b.id] ?? 999999;
        return _sortAsc ? ib.compareTo(ia) : ia.compareTo(ib);
      });
      return sorted;
    }
    final sorted = [...posts];
    sorted.sort((a, b) {
      int cmp = b.updatedAt.compareTo(a.updatedAt);
      return _sortAsc ? -cmp : cmp;
    });
    return sorted;
  }

  Future<List<Post>> _sortByTrend(List<Post> posts) async {
    setState(() => _isFetchingTrend = true);
    try {
      final trending = await ref.read(trendingRepositoryProvider).getMostRecent();

      if (trending == null || trending.trendTopics.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No trending data available — fetch new on the Home screen.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return posts;
      }

      final embeddingService = ref.read(embeddingServiceProvider);
      final trendVec = trending.fullEmbedding;
      final useStored = trendVec.isNotEmpty;

      late List<double> scores;

      if (useStored) {
        // Combine full-embedding similarity with max per-topic similarity for better RAG signal.
        final eachVecs = trending.eachEmbedding;
        scores = posts.map((p) {
          if (p.embedding == null || p.embedding!.isEmpty) return 0.0;
          try {
            final vec = p.embedding!.split(',').map(double.parse).toList();
            final fullSim = embeddingService.cosineSimilarity(vec, trendVec);
            if (eachVecs.isEmpty) return fullSim;
            final maxTopicSim = eachVecs
                .map((tv) => embeddingService.cosineSimilarity(vec, tv))
                .reduce((a, b) => a > b ? a : b);
            // Weight: 50% full-corpus embedding + 50% best single-topic match.
            return 0.5 * fullSim + 0.5 * maxTopicSim;
          } catch (_) {
            return 0.0;
          }
        }).toList();
      } else {
        // TF-IDF fallback — build shared corpus and rank on-the-fly
        final trendQuery = [
          ...trending.trendTopics,
          ...trending.categoryTopics.values.expand((v) => v),
        ].join(' ');
        final postTexts = posts.map((p) => [
          p.linkedinContent ?? '',
          p.twitterContent ?? '',
          p.dump,
          ...p.postBaseTags,
          ...p.trendsBasePublishTags,
        ].where((s) => s.isNotEmpty).join(' ')).toList();
        scores = embeddingService.rankAgainst(postTexts, trendQuery);
      }

      final scored = List.generate(posts.length, (i) => (posts[i], scores[i]));
      scored.sort((a, b) => b.$2.compareTo(a.$2));

      final result = scored.map((e) => e.$1).toList();
      if (mounted) {
        setState(() => _trendSortedPosts = result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sorted by trending relevance.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return result;
    } finally {
      if (mounted) setState(() => _isFetchingTrend = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postListProvider(widget.status));
    final extraPostsAsync = [
      for (final s in widget.extraStatuses) ref.watch(postListProvider(s)),
    ];
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    // Merge primary + extra posts, deduplicated by id
    final mergedPostsAsync = postsAsync.whenData((primary) {
      final all = [...primary];
      for (final extra in extraPostsAsync) {
        final list = extra.valueOrNull ?? [];
        for (final p in list) {
          if (!all.any((e) => e.id == p.id)) all.add(p);
        }
      }
      return all;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.status.displayName),
        actions: [
          if (_isFetchingTrend)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: Icon(_isTableView ? Icons.list : Icons.table_rows_outlined),
            tooltip: _isTableView ? 'List view' : 'Table view',
            onPressed: () => setState(() => _isTableView = !_isTableView),
          ),
          PopupMenuButton<_SortMode>(
            icon: const Icon(Icons.sort),
            onSelected: (mode) async {
              if (mode == _SortMode.trend) {
                final posts = mergedPostsAsync.valueOrNull ?? [];
                final cats = categoriesAsync.valueOrNull ?? [];
                final filtered = _applyFilters(posts, cats);
                await _sortByTrend(filtered);
              } else {
                setState(() => _trendSortedPosts = null);
              }
              setState(() => _sortMode = mode);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _SortMode.date,
                child: Text('Sort by Date'),
              ),
              if (widget.status == PostStatus.pending ||
                  widget.status == PostStatus.partialPublished)
                const PopupMenuItem(
                  value: _SortMode.trend,
                  child: Text('Sort by Trend'),
                ),
            ],
          ),
          IconButton(
            icon: Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => setState(() => _sortAsc = !_sortAsc),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            timeFilter: _timeFilter,
            selectedCategoryIds: _selectedCategoryIds,
            categories: categoriesAsync.valueOrNull ?? [],
            onTimeFilterChanged: (f) => setState(() => _timeFilter = f),
            onCategoryChanged: (ids) =>
                setState(() => _selectedCategoryIds = ids),
          ),
          Expanded(
            child: mergedPostsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) {
                print('Error loading posts: $e');
                return Center(child: Text('Error: $e'));
              },
              data: (posts) {
                final cats = categoriesAsync.valueOrNull ?? [];
                var filtered = _applyFilters(posts, cats);
                filtered = _applySort(filtered);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                if (_isTableView) {
                  return _PostTable(posts: filtered, categories: cats);
                }
                return _PostList(posts: filtered, categories: cats);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? timeFilter;
  final Set<String> selectedCategoryIds;
  final List<Category> categories;
  final void Function(String?) onTimeFilterChanged;
  final void Function(Set<String>) onCategoryChanged;

  const _FilterBar({
    required this.timeFilter,
    required this.selectedCategoryIds,
    required this.categories,
    required this.onTimeFilterChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Today',
            selected: timeFilter == 'today',
            onTap: () =>
                onTimeFilterChanged(timeFilter == 'today' ? null : 'today'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Week',
            selected: timeFilter == 'week',
            onTap: () =>
                onTimeFilterChanged(timeFilter == 'week' ? null : 'week'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Month',
            selected: timeFilter == 'month',
            onTap: () =>
                onTimeFilterChanged(timeFilter == 'month' ? null : 'month'),
          ),
          const SizedBox(width: 16),
          if (categories.isNotEmpty)
            _CategoryFilterButton(
              categories: categories,
              selectedIds: selectedCategoryIds,
              onChanged: onCategoryChanged,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  final List<Category> categories;
  final Set<String> selectedIds;
  final void Function(Set<String>) onChanged;

  const _CategoryFilterButton({
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        selectedIds.isEmpty ? 'Category' : '${selectedIds.length} categories',
      ),
      selected: selectedIds.isNotEmpty,
      onSelected: (_) async {
        final result = await showDialog<Set<String>>(
          context: context,
          builder: (_) => _CategoryMultiSelectDialog(
            categories: categories,
            selectedIds: selectedIds,
          ),
        );
        if (result != null) onChanged(result);
      },
    );
  }
}

class _CategoryMultiSelectDialog extends StatefulWidget {
  final List<Category> categories;
  final Set<String> selectedIds;

  const _CategoryMultiSelectDialog({
    required this.categories,
    required this.selectedIds,
  });

  @override
  State<_CategoryMultiSelectDialog> createState() =>
      _CategoryMultiSelectDialogState();
}

class _CategoryMultiSelectDialogState
    extends State<_CategoryMultiSelectDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Category'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.categories.map((c) {
            return CheckboxListTile(
              value: _selected.contains(c.id),
              title: Row(
                children: [
                  Text(c.name),
                  if (!c.isActive) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '(inactive)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              onChanged: (val) {
                setState(() {
                  if (val == true)
                    _selected.add(c.id);
                  else
                    _selected.remove(c.id);
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _PostList extends StatelessWidget {
  final List<Post> posts;
  final List<Category> categories;

  const _PostList({required this.posts, required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (ctx, i) =>
          _PostCard(post: posts[i], categories: categories),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final List<Category> categories;

  const _PostCard({required this.post, required this.categories});

  @override
  Widget build(BuildContext context) {
    final category = categories
        .where((c) => c.id == post.categoryId)
        .firstOrNull;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/post/${post.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: post.status),
                  const Spacer(),
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.dump.isEmpty ? '(No dump)' : post.dump,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final p in post.selectedPlatforms)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _PlatformBadge(
                        platform: p,
                        published: post.publishedPlatforms.contains(p),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _formatDate(post.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _PostTable extends StatelessWidget {
  final List<Post> posts;
  final List<Category> categories;

  const _PostTable({required this.posts, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Dump')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Platforms')),
            DataColumn(label: Text('Updated')),
          ],
          rows: posts.map((post) {
            final category = categories
                .where((c) => c.id == post.categoryId)
                .firstOrNull;
            return DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      post.dump.isEmpty ? '(empty)' : post.dump,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () => context.push('/post/${post.id}'),
                ),
                DataCell(_StatusBadge(status: post.status)),
                DataCell(Text(category?.name ?? '-')),
                DataCell(
                  Text(
                    post.selectedPlatforms.map((p) => p.displayName).join(', '),
                  ),
                ),
                DataCell(Text('${post.updatedAt.month}/${post.updatedAt.day}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PostStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case PostStatus.draft:
        return Colors.grey;
      case PostStatus.pending:
        return Colors.orange;
      case PostStatus.partialPublished:
        return Colors.blue;
      case PostStatus.published:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final Platform platform;
  final bool published;

  const _PlatformBadge({required this.platform, required this.published});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: published
            ? Colors.green.withAlpha(30)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (published) const Icon(Icons.check, size: 10, color: Colors.green),
          Text(
            platform.displayName,
            style: TextStyle(
              fontSize: 10,
              color: published ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
