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
      fullEmbedding = await _embeddingService.embed(rawTrendingTopics.join(' '));
      for (final topic in rawTrendingTopics) {
        final v = await _embeddingService.embed(topic);
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

  /// Fetches global trending topics from Google Trends RSS (tech/edu/AI filtered).
  /// Falls back to Gemini-generated global trends if the RSS call fails.
  Future<List<String>> _fetchGlobalTrendTopics() async {
    final googleResults = await _fetchFromGoogleTrendsRss();
    if (googleResults.isNotEmpty) return googleResults;
    return _geminiService.fetchGlobalTrendTopics();
  }

  /// Google Trends daily RSS — no API key required.
  /// Filters to topics relevant to tech, AI, learning, and education.
  /// Returns raw topic strings before any transformation.
  Future<List<String>> _fetchFromGoogleTrendsRss() async {
    try {
      final uri = Uri.parse(
        'https://trends.google.com/trends/trendingsearches/daily/rss?geo=US',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'CastPA/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final titleMatches = RegExp(
        r'<item>.*?<title><!\[CDATA\[(.*?)\]\]></title>',
        dotAll: true,
      ).allMatches(response.body);

      final allTitles = titleMatches
          .map((m) => m.group(1)?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();

      if (allTitles.isEmpty) return [];

      // Keep only topics in tech, AI, learning, and education space.
      const relevantKeywords = {
        'ai', 'ml', 'tech', 'software', 'code', 'coding', 'programming',
        'developer', 'engineering', 'data', 'cloud', 'open source',
        'learning', 'education', 'course', 'tutorial', 'university',
        'research', 'science', 'startup', 'product',
      };

      final filtered = allTitles.where((title) {
        final lower = title.toLowerCase();
        return relevantKeywords.any((kw) => lower.contains(kw));
      }).toList();

      // If nothing matches the filter, return top 15 general trends.
      // Lowercase only — no other transformation applied here.
      return (filtered.isNotEmpty ? filtered : allTitles.take(15).toList())
          .map((t) => t.toLowerCase())
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Normalises raw topic strings: lowercase and spaces → underscores.
  List<String> _normaliseTopics(List<String> raw) =>
      raw.map((t) => t.toLowerCase().replaceAll(RegExp(r'\s+'), '_')).toList();
}
