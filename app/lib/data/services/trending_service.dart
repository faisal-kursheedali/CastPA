import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:castpa/domain/entities/trending.dart';
import 'package:castpa/domain/repositories/category_repository.dart';
import 'package:castpa/domain/repositories/trending_repository.dart';
import 'package:castpa/data/services/gemini_service.dart';
import 'package:castpa/data/services/embedding_service.dart';

class TrendingService {
  final TrendingRepository _trendingRepo;
  final CategoryRepository _categoryRepo;
  final GeminiService _geminiService;
  final EmbeddingService _embeddingService;
  static const _uuid = Uuid();

  TrendingService(
    this._trendingRepo,
    this._categoryRepo,
    this._geminiService,
    this._embeddingService,
  );

  Future<Trending> getOrFetchCurrentWeek() async {
    final recent = await _trendingRepo.getMostRecent();
    if (recent != null && recent.isCurrentWeek) return recent;
    return _fetchAndStore();
  }

  Future<Trending> forceFetch() => _fetchAndStore();

  Future<Trending> _fetchAndStore() async {
    final categories = await _categoryRepo.getAllCategories();
    final categoryNames = categories.map((c) => c.name).toList();

    final errors = <String>[];

    // Fetch global trends and category topics in parallel.
    final globalFuture = _fetchGlobalTrendTopics();
    final categoryFuture = _geminiService.fetchTrendTopicsForCategories(
      categoryNames,
    );

    List<String> rawTrendingTopics = [];
    List<String> trendTopics = [];
    Map<String, List<String>> categoryTopics = {};

    try {
      rawTrendingTopics = await globalFuture;
      trendTopics = _normaliseTopics(rawTrendingTopics);
    } catch (e) {
      errors.add('Trend fetch failed: $e');
    }

    try {
      final raw = await categoryFuture;
      categoryTopics = raw.map((k, v) => MapEntry(k.toUpperCase(), v));
    } catch (e) {
      errors.add('Category fetch failed: $e');
    }

    if (_geminiService.apiKey.isEmpty) {
      errors.add('Gemini API key not configured');
    }

    if (trendTopics.isEmpty && errors.isEmpty) {
      errors.add('No trend topics returned — Gemini quota may be exhausted');
    }
    if (categoryTopics.isEmpty && errors.isEmpty) {
      errors.add('No category topics returned — Gemini quota may be exhausted');
    }

    final platform = trendTopics.isNotEmpty ? 'google_trends+gemini' : 'gemini';

    // Embed locally using MiniLM (or empty if model not yet added).
    List<double> fullEmbedding = [];
    final List<List<double>> eachEmbedding = [];
    if (rawTrendingTopics.isNotEmpty) {
      fullEmbedding = await _embeddingService.embedChunked(
        rawTrendingTopics.join(' '),
      );
      for (final topic in rawTrendingTopics) {
        final v = await _embeddingService.embedChunked(topic);
        eachEmbedding.add(v);
      }
    }

    final trending = Trending(
      id: _uuid.v4(),
      trendTopics: trendTopics,
      rawTrendingTopics: rawTrendingTopics,
      categoryTopics: categoryTopics,
      addedDate: DateTime.now(),
      fullEmbedding: fullEmbedding,
      eachEmbedding: eachEmbedding,
      platform: platform,
      fetchError: errors.isEmpty ? null : errors.join(' | '),
    );

    await _trendingRepo.saveTrending(trending);
    return trending;
  }

  /// Fetches dev.to trending article tags directly as topics — no processing needed.
  /// Falls back to HN titles → Gemini → Gemini global topics.
  Future<List<String>> _fetchGlobalTrendTopics() async {
    final devToTags = await _fetchFromDevTo();
    if (devToTags.isNotEmpty) return devToTags;

    // Fallback: HN titles → Gemini keyword extraction
    final hnTitles = await _fetchFromHackerNews();
    if (hnTitles.isNotEmpty) {
      final keywords = await _geminiService.extractKeywordsFromTitles(hnTitles);
      if (keywords.isNotEmpty) return keywords;
    }

    return _geminiService.fetchGlobalTrendTopics();
  }

  /// Fetches top trending articles from dev.to and returns tags directly as topics.
  /// No API key required, no Gemini processing needed.
  Future<List<String>> _fetchFromDevTo() async {
    try {
      final uri = Uri.parse('https://dev.to/api/articles?top=50&per_page=70');
      final response = await http
          .get(uri, headers: {'User-Agent': 'CastPA/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final articles = jsonDecode(response.body) as List<dynamic>;

      return articles
          .expand((a) => (a['tag_list'] as List<dynamic>? ?? []))
          .map((t) => t.toString().toLowerCase().trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetches current front-page story titles from Hacker News via Algolia API.
  Future<List<String>> _fetchFromHackerNews() async {
    try {
      final uri = Uri.parse(
        'https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=30',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'CastPA/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final hits = body['hits'] as List<dynamic>? ?? [];

      return hits
          .map((h) => (h['title'] as String? ?? '').trim())
          .where((t) => t.isNotEmpty)
          .map((t) => t.toLowerCase())
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Google Trends RSS — kept for future use when Google restores category filtering.
  /// Currently not called since category params are ignored by the new endpoint.
  /// Fetches Google Trends RSS from tech/science/education category feeds directly.
  /// Using category-specific feeds means Google filters out politics, sports,
  /// entertainment at source — no manual keyword filtering needed.
  // ignore: unused_element
  Future<List<String>> _fetchFromGoogleTrendsRss() async {
    // Category codes: Science & Tech (5), Computers & Electronics (299),
    // Internet & Telecom (174), Education (958).
    const categories = ['5', '299', '174', '958'];

    final results = await Future.wait(
      categories.map((cat) => _fetchRssCategory(cat)),
    );

    final all = results
        .expand((topics) => topics)
        .map((t) => t.toLowerCase().trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();

    return all;
  }

  /// Fetches a single Google Trends RSS category feed and returns raw titles.
  Future<List<String>> _fetchRssCategory(String cat) async {
    try {
      final uri = Uri.parse(
        'https://trends.google.com/trends/trendingsearches/daily/rss?geo=US&cat=$cat',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'CastPA/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      return RegExp(
            r'<item>.*?<title><!\[CDATA\[(.*?)\]\]></title>',
            dotAll: true,
          )
          .allMatches(response.body)
          .map((m) => m.group(1)?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Normalises raw topic strings: lowercase and spaces → underscores.
  List<String> _normaliseTopics(List<String> raw) =>
      raw.map((t) => t.toLowerCase().replaceAll(RegExp(r'\s+'), '_')).toList();
}
