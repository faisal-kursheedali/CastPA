import 'dart:convert';
import 'package:http/http.dart' as http;

class PolishResult {
  final String? linkedinContent;
  final String? twitterContent;
  final List<String> tags;
  final String? error;
  final String? hookType;
  final String? structureUsed;
  final bool? endsWithQuestion;

  const PolishResult({
    this.linkedinContent,
    this.twitterContent,
    required this.tags,
    this.error,
    this.hookType,
    this.structureUsed,
    this.endsWithQuestion,
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

  static const _hookPatterns = {
    'contrarian': 'Pattern: [Common practice] is wrong. Here\'s why.',
    'curiosity':  'Pattern: Most [audience] miss this about [topic].',
    'fear':       'Pattern: This [mistake] will [consequence].',
    'stat':       'Pattern: [Number]% of [audience] don\'t know [fact].',
    'aspiration': 'Pattern: [Small change] → [big result].',
  };

  static const _structureDetails = {
    'pas':        'Problem → Agitate → Solution.',
    'bab':        'Before → After → Bridge.',
    'contrarian': 'Bold claim → Supporting points → Takeaway.',
  };

  Future<PolishResult> polishPost({
    required String dump,
    required bool forLinkedIn,
    required bool forX,
    String hookType = 'auto',
    String structure = 'auto',
    String endWithQuestion = 'auto',
  }) async {
    if (apiKey.isEmpty) {
      return const PolishResult(
        tags: [],
        error: 'No Gemini API key configured.',
      );
    }

    final hookInstruction = hookType == 'auto'
        ? 'Pick best hook type for content: contrarian, curiosity, fear, stat, or aspiration.'
        : 'Must use $hookType hook. ${_hookPatterns[hookType] ?? ''}';

    final structureInstruction = structure == 'auto'
        ? 'Pick best structure: PAS, BAB, or Contrarian.'
        : 'Must use ${structure.toUpperCase()}. ${_structureDetails[structure] ?? ''}';

    final questionInstruction = endWithQuestion == 'auto'
        ? 'End with question only if it fits naturally.'
        : endWithQuestion == 'yes'
            ? 'Always end with a question to drive comments.'
            : 'Do not end with a question.';

    final prompt = '''
You are a developer content writer for LinkedIn and X (Twitter).

Raw dump: """$dump"""

CONTENT RULES:
- Hook: first 1-2 lines only, max 12 words
  $hookInstruction
- Structure: entire post follows one structure — DO NOT write structure labels (Before:/After:/Bridge:/Problem:/Solution:/etc.) in the post
  $structureInstruction
- Emoji bullets only (✅ 🔹 ⚡ →), no markdown
- Short paragraphs, max 2-3 lines, jump lines between them
- No hashtags anywhere in content
- If dump contains a link, place it near end after main content
- $questionInstruction

${forLinkedIn ? '''LINKEDIN:
- First 210 characters must contain hook only
- Optimal length: 900-1200 characters''' : ''}

${forX ? '''X (TWITTER):
- Max 220 characters
- Hook: first 1-2 words, max 8 words
- Condense full LinkedIn post into one punchy thought
- If dump has link, place at end
- $questionInstruction''' : ''}

Extract 3-10 tags tightly specific to this post's content.
- Minimum 3, maximum 10
- Must be specific to what this post is actually about — not the platform, industry, or broad field
- No generic single-word tags (learning, tips, growth, career, success)
- No platform tags (blogging, medium, writing, linkedin, twitter)
- No broad category tags (tech, programming, software, engineering)
- Lowercase, underscores for spaces (e.g. system_design, react_hooks)
- Must be terms a reader would actually search for

Return ONLY valid JSON, no extra text:
{
  "linkedin_content": ${forLinkedIn ? '"..."' : 'null'},
  "twitter_content": ${forX ? '"..."' : 'null'},
  "tags": ["tag1", "tag2", "tag3", "...up to 10"],
  "hook_type": "detected hook type",
  "structure_used": "PAS|BAB|Contrarian",
  "ends_with_question": true
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
        hookType: parsed['hook_type'] as String?,
        structureUsed: parsed['structure_used'] as String?,
        endsWithQuestion: parsed['ends_with_question'] as bool?,
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

  /// Takes raw Hacker News story titles and extracts clean tech/AI topic keywords.
  Future<List<String>> extractKeywordsFromTitles(List<String> titles) async {
    if (apiKey.isEmpty || titles.isEmpty) return [];

    final titlesText = titles.map((t) => '- $t').join('\n');
    final prompt = '''
You are a tech trend analyst. From the following Hacker News story titles, extract the key technology and AI topics being discussed.

Titles:
$titlesText

Rules:
- Return only topics relevant to: AI, software engineering, programming, cloud, startups, education, research
- Each topic should be a short phrase (2-4 words max), lowercase (e.g. "llm agents", "open source ai")
- Ignore politics, sports, entertainment, food, crime
- Return 10-20 topics max
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
              'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 512},
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
