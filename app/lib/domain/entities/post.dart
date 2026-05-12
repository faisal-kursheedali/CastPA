import 'package:castpa/domain/entities/enums.dart';

class Post {
  final String id;
  final String dump;
  final String? linkedinContent;
  final String? twitterContent;
  final String? embedding;
  final bool isEmbedded;
  final bool isRemoved;
  final String? categoryId;
  final List<String> links;
  final List<String> postBaseTags;
  final List<String> categoryBasePublishTags;
  final List<String> trendsBasePublishTags;
  final List<String> mediaIds;
  final List<Platform> selectedPlatforms;
  final List<Platform> publishedPlatforms;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.dump,
    this.linkedinContent,
    this.twitterContent,
    this.embedding,
    this.isEmbedded = false,
    this.isRemoved = false,
    this.categoryId,
    required this.links,
    required this.postBaseTags,
    required this.categoryBasePublishTags,
    required this.trendsBasePublishTags,
    required this.mediaIds,
    required this.selectedPlatforms,
    required this.publishedPlatforms,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasContent =>
      dump.isNotEmpty ||
      (linkedinContent?.isNotEmpty ?? false) ||
      (twitterContent?.isNotEmpty ?? false);

  List<Platform> get remainingTargets =>
      selectedPlatforms.where((p) => !publishedPlatforms.contains(p)).toList();

  bool get isFullyPublished =>
      selectedPlatforms.isNotEmpty && remainingTargets.isEmpty;

  Post copyWith({
    String? id,
    String? dump,
    String? linkedinContent,
    String? twitterContent,
    String? embedding,
    bool? isEmbedded,
    bool? isRemoved,
    String? categoryId,
    List<String>? links,
    List<String>? postBaseTags,
    List<String>? categoryBasePublishTags,
    List<String>? trendsBasePublishTags,
    List<String>? mediaIds,
    List<Platform>? selectedPlatforms,
    List<Platform>? publishedPlatforms,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCategoryId = false,
    bool clearLinkedinContent = false,
    bool clearTwitterContent = false,
    bool clearEmbedding = false,
  }) {
    return Post(
      id: id ?? this.id,
      dump: dump ?? this.dump,
      linkedinContent: clearLinkedinContent ? null : linkedinContent ?? this.linkedinContent,
      twitterContent: clearTwitterContent ? null : twitterContent ?? this.twitterContent,
      embedding: clearEmbedding ? null : embedding ?? this.embedding,
      isEmbedded: isEmbedded ?? this.isEmbedded,
      isRemoved: isRemoved ?? this.isRemoved,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      links: links ?? this.links,
      postBaseTags: postBaseTags ?? this.postBaseTags,
      categoryBasePublishTags: categoryBasePublishTags ?? this.categoryBasePublishTags,
      trendsBasePublishTags: trendsBasePublishTags ?? this.trendsBasePublishTags,
      mediaIds: mediaIds ?? this.mediaIds,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      publishedPlatforms: publishedPlatforms ?? this.publishedPlatforms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
