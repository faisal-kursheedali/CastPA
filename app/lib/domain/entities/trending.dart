class Trending {
  final String id;
  final List<String> trendTopics;
  /// Raw trend topics as received from the source, before any transformation.
  final List<String> rawTrendingTopics;
  /// Map of category name → related hashtags/search terms for that category.
  final Map<String, List<String>> categoryTopics;
  final DateTime addedDate;
  final List<double> fullEmbedding;
  final List<List<double>> eachEmbedding;
  final String platform;
  final String? fetchError;

  const Trending({
    required this.id,
    required this.trendTopics,
    required this.rawTrendingTopics,
    required this.categoryTopics,
    required this.addedDate,
    required this.fullEmbedding,
    required this.eachEmbedding,
    this.platform = 'gemini',
    this.fetchError,
  });

  bool get isCurrentWeek {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return addedDate.isAfter(weekStart) && addedDate.isBefore(weekEnd);
  }
}
