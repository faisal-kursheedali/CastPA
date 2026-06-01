import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:castpa/application/notifiers/post_list_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/domain/entities/post.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/entities/trending.dart';

const _kThresholdKey = 'trend_score_threshold';

class TrendScoreScreen extends ConsumerStatefulWidget {
  const TrendScoreScreen({super.key});

  @override
  ConsumerState<TrendScoreScreen> createState() => _TrendScoreScreenState();
}

class _TrendScoreScreenState extends ConsumerState<TrendScoreScreen> {
  // Status tabs
  PostStatus _selectedStatus = PostStatus.pending;
  final _statuses = [PostStatus.pending, PostStatus.partialPublished, PostStatus.published];

  // Scored posts per status (cached)
  final Map<PostStatus, List<({Post post, double score})>> _scoredMap = {};

  Trending? _trending;
  bool _loading = true;
  String? _error;

  // Threshold
  final _thresholdCtrl = TextEditingController(text: '85');
  double get _threshold => (double.tryParse(_thresholdCtrl.text) ?? 85.0) / 100.0;

  List<({Post post, double score})> get _currentScored => _scoredMap[_selectedStatus] ?? [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadThreshold();
      _compute();
    });
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_kThresholdKey);
    if (saved != null) {
      setState(() => _thresholdCtrl.text = saved.toStringAsFixed(0));
    }
  }

  Future<void> _saveThreshold(String value) async {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kThresholdKey, parsed);
  }

  Future<void> _compute() async {
    setState(() { _loading = true; _error = null; });
    try {
      final trending = await ref.read(trendingRepositoryProvider).getMostRecent();
      if (trending == null || trending.trendTopics.isEmpty) {
        setState(() {
          _error = 'No trending data — fetch trends on the Home screen first.';
          _loading = false;
        });
        return;
      }

      final embeddingService = ref.read(embeddingServiceProvider);
      final trendVec = trending.fullEmbedding;
      final eachVecs = trending.eachEmbedding;
      final useEmbedding = trendVec.isNotEmpty;

      final newMap = <PostStatus, List<({Post post, double score})>>{};

      for (final status in _statuses) {
        final posts = ref.read(postListProvider(status)).valueOrNull ?? [];
        final scored = <({Post post, double score})>[];

        for (final post in posts) {
          double score = 0.0;
          if (useEmbedding) {
            if (post.embedding != null && post.embedding!.isNotEmpty) {
              try {
                final vec = post.embedding!.split(',').map(double.parse).toList();
                final fullSim = embeddingService.cosineSimilarity(vec, trendVec);
                if (eachVecs.isEmpty) {
                  score = fullSim;
                } else {
                  final maxTopicSim = eachVecs
                      .map((tv) => embeddingService.cosineSimilarity(vec, tv))
                      .reduce((a, b) => a > b ? a : b);
                  score = 0.5 * fullSim + 0.5 * maxTopicSim;
                }
              } catch (_) {}
            }
          } else {
            final trendQuery = [
              ...trending.trendTopics,
              ...trending.categoryTopics.values.expand((v) => v),
            ].join(' ');
            final postText = [
              post.linkedinContent ?? '',
              post.dump,
              ...post.postBaseTags,
            ].where((s) => s.isNotEmpty).join(' ');
            final scores = embeddingService.rankAgainst([postText], trendQuery);
            score = scores.isNotEmpty ? scores[0] : 0.0;
          }
          scored.add((post: post, score: score));
        }

        scored.sort((a, b) => b.score.compareTo(a.score));
        newMap[status] = scored;
      }

      setState(() {
        _trending = trending;
        _scoredMap.addAll(newMap);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  double get _aboveThresholdPct {
    final list = _currentScored;
    if (list.isEmpty) return 0.0;
    final above = list.where((e) => e.score >= _threshold).length;
    return above / list.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trend Score'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recompute',
            onPressed: _compute,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ))
              : CustomScrollView(
                  slivers: [
                    // ── Status tabs ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: SegmentedButton<PostStatus>(
                          expandedInsets: EdgeInsets.zero,
                          segments: _statuses.map((s) => ButtonSegment(
                            value: s,
                            label: Text(s.displayName, style: const TextStyle(fontSize: 12)),
                          )).toList(),
                          selected: {_selectedStatus},
                          onSelectionChanged: (val) =>
                              setState(() => _selectedStatus = val.first),
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ),

                    // ── Circular progress + threshold field ───────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                _CircularScore(pct: _aboveThresholdPct),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${(_aboveThresholdPct * 100).toStringAsFixed(0)}% of posts above threshold',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_currentScored.where((e) => e.score >= _threshold).length} of ${_currentScored.length} posts',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 72,
                                  child: TextField(
                                    controller: _thresholdCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      labelText: 'Min %',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onChanged: (v) {
                                      setState(() {});
                                      _saveThreshold(v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Trending topics box ───────────────────────────────
                    SliverToBoxAdapter(
                      child: _TrendingTopicsBox(trending: _trending!),
                    ),

                    // ── Count label ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_currentScored.length} ${_currentScored.length == 1 ? 'post' : 'posts'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Score list ────────────────────────────────────────
                    _currentScored.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(
                              child: Text('No posts', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            sliver: SliverList.builder(
                              itemCount: _currentScored.length,
                              itemBuilder: (ctx, i) {
                                final item = _currentScored[i];
                                return _ScoreRow(
                                  rank: i + 1,
                                  post: item.post,
                                  score: item.score,
                                  threshold: _threshold,
                                );
                              },
                            ),
                          ),
                  ],
                ),
    );
  }
}

// ── Circular score indicator ──────────────────────────────────────────────────

class _CircularScore extends StatelessWidget {
  final double pct; // 0.0 – 1.0
  const _CircularScore({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 0.7 ? Colors.green : pct >= 0.4 ? Colors.orange : Colors.red;
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(60, 60),
            painter: _ArcPainter(pct: pct, color: color),
          ),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double pct;
  final Color color;
  const _ArcPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background track
    canvas.drawArc(rect, -pi / 2, 2 * pi, false,
        Paint()..color = color.withAlpha(40)..style = PaintingStyle.stroke..strokeWidth = 6);

    // Filled arc
    if (pct > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * pct, false,
          Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct || old.color != color;
}

// ── Trending topics box ───────────────────────────────────────────────────────

class _TrendingTopicsBox extends StatelessWidget {
  final Trending trending;
  const _TrendingTopicsBox({required this.trending});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topics = trending.rawTrendingTopics.isNotEmpty
        ? trending.rawTrendingTopics
        : trending.trendTopics;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                'Trending Topics',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                trending.platform,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: topics.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 11)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Score row ─────────────────────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  final int rank;
  final Post post;
  final double score;
  final double threshold;

  const _ScoreRow({
    required this.rank,
    required this.post,
    required this.score,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (score * 100).toStringAsFixed(1);
    final aboveThreshold = score >= threshold;
    final color = score >= 0.6
        ? Colors.green
        : score >= 0.35
            ? Colors.orange
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: aboveThreshold
            ? BorderSide(color: Colors.green.withAlpha(120), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/post/${post.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Score badge
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Post content
              Expanded(
                child: Text(
                  post.linkedinContent?.isNotEmpty == true
                      ? post.linkedinContent!
                      : post.dump.isNotEmpty ? post.dump : '(No content)',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
