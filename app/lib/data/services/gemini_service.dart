import 'dart:convert';
import 'package:http/http.dart' as http;

class PolishResult {
  final String? linkedinContent;
  final String? twitterContent;
  final List<String> tags;
  final String? error;

  const PolishResult({
    this.linkedinContent,
    this.twitterContent,
    required this.tags,
    this.error,
  });

  bool get hasError => error != null;
}

class EmbeddingResult {
  final List<double> embedding;
  final String? error;

  const EmbeddingResult({required this.embedding, this.error});
  bool get hasError => error != null;
}

class GeminiService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const _model = 'gemini-2.5-flash-lite';
  static const _embeddingModel = 'text-embedding-004';

  final String apiKey;

  GeminiService(this.apiKey);

  Future<PolishResult> polishPost({
    required String dump,
    required bool forLinkedIn,
    required bool forX,
  }) async {
    if (apiKey.isEmpty) {
      return const PolishResult(
        tags: [],
        error: 'No Gemini API key configured.',
      );
    }

    final platforms = [
      if (forLinkedIn) 'LinkedIn',
      if (forX) 'X (Twitter)',
    ].join(', ');

    final prompt =
        '''
You are a professional content writer. Transform the raw dump below into polished social media posts.

Raw dump: """$dump"""

Instructions:
- Write for: $platforms
${forLinkedIn ? '- LinkedIn: Professional, engaging, up to 3000 characters, include relevant hashtags at end' : ''}
${forX ? '- X (Twitter): Concise, punchy, max 280 characters, include 1-2 hashtags inline' : ''}
- Extract 3-6 relevant post-specific tags (without # symbol) from the content

Return ONLY valid JSON in this exact format:
{
  "linkedin_content": ${forLinkedIn ? '"..."' : 'null'},
  "twitter_content": ${forX ? '"..."' : 'null'},
  "tags": ["tag1", "tag2"]
}
''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2048},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('Gemini API error: ${response.body}');
        return PolishResult(
          tags: [],
          error: 'Gemini API error: ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text =
          body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text == null) {
        return const PolishResult(
          tags: [],
          error: 'Empty response from Gemini',
        );
      }

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) {
        return const PolishResult(
          tags: [],
          error: 'Could not parse Gemini response',
        );
      }

      final parsed = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      final tags =
          (parsed['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];

      return PolishResult(
        linkedinContent: parsed['linkedin_content'] as String?,
        twitterContent: parsed['twitter_content'] as String?,
        tags: tags,
      );
    } catch (e) {
      print('Error in polishPost: $e');
      return PolishResult(tags: [], error: 'Error: $e');
    }
  }

  Future<EmbeddingResult> generateEmbedding(String text) async {
    if (apiKey.isEmpty) {
      return const EmbeddingResult(embedding: [], error: 'No API key');
    }
    if (text.isEmpty) {
      return const EmbeddingResult(embedding: [], error: 'Empty text');
    }

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1/models/$_embeddingModel:embedContent?key=$apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'content': {
                'parts': [
                  {'text': text},
                ],
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return EmbeddingResult(
          embedding: [],
          error: 'Embedding API error: ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final values = (body['embedding']?['values'] as List?)
          ?.map((v) => (v as num).toDouble())
          .toList();

      return EmbeddingResult(embedding: values ?? []);
    } catch (e) {
      return EmbeddingResult(embedding: [], error: 'Embedding error: $e');
    }
  }

  /// For each category, returns related trending hashtags/search terms.
  /// e.g. "DSA" → ["dsa", "dsa_learning", "gfg", "codechef", "leetcode"]
  Future<Map<String, List<String>>> fetchTrendTopicsForCategories(
    List<String> categories,
  ) async {
    if (apiKey.isEmpty) return {};
    if (categories.isEmpty) return {};

    final categoriesList = categories.join(', ');
    final prompt = '''
You are a social media trend analyst. For each of the following content categories, return related trending hashtags, search terms, and community names that are currently popular on platforms like LinkedIn, X (Twitter), and Instagram.

Categories: $categoriesList

Rules:
- Return 4-6 related terms per category
- Include hashtag-style terms (no # symbol), community names, and platform-specific trending keywords
- Terms should be lowercase with underscores for spaces (e.g. "dsa_learning", "open_source")
- Focus on what creators and learners in that space actually search/follow
- Return ONLY valid JSON: an object where each key is a category name and the value is an array of strings

Example:
{
  "DSA": ["dsa", "dsa_learning", "gfg", "codechef", "leetcode", "competitive_programming"],
  "Python": ["python", "python_tips", "django", "fastapi", "python_projects"]
}

Return ONLY the JSON object, nothing else.
''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 1024},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) return {};

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text =
          body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text == null) return {};

      final objMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (objMatch == null) return {};

      final parsed = jsonDecode(objMatch.group(0)!) as Map<String, dynamic>;
      return parsed.map(
        (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
      );
    } catch (e) {
      return {};
    }
  }

  /// Returns globally trending topics in tech, AI, learning, and education —
  /// not tied to any specific user category. Used as fallback when Google Trends RSS fails.
  Future<List<String>> fetchGlobalTrendTopics() async {
    if (apiKey.isEmpty) return [];

    const prompt = '''
You are a social media trend analyst. List the currently popular trending topics, hashtags, and search terms in the areas of: technology, artificial intelligence, software engineering, online learning, and education.

Rules:
- Return 15-20 terms total
- Lowercase with spaces (e.g. "generative ai", "open source")
- Include a mix: broad topics, tools, movements, and community hashtags
- Return ONLY a valid JSON array of strings, nothing else
''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 512},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text =
          body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text == null) return [];

      final arrayMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (arrayMatch == null) return [];

      final parsed = jsonDecode(arrayMatch.group(0)!) as List;
      return parsed.map((e) => e.toString()).toSet().toList();
    } catch (_) {
      return [];
    }
  }
}
