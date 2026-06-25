import 'package:castpa/domain/entities/enums.dart';

class Post {
  final String id;
  final String dump;
  final String? linkedinContent;
  final String? twitterContent;
  final String? linkedinFirstComment;
  final String? twitterFirstComment;
  final bool linkInFirstComment;
  final String? embedding;
  final String? postBaseTagsEmbedding;
  final bool isEmbedded;
  final bool isRemoved;
  final String? categoryId;
  final List<String> links;
  final List<String> postBaseTags;
  final List<String> trendsBasePublishTags;
  final List<String> userAddedTrendTags;
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
    this.linkedinFirstComment,
    this.twitterFirstComment,
    this.linkInFirstComment = true,
    this.embedding,
    this.postBaseTagsEmbedding,
    this.isEmbedded = false,
    this.isRemoved = false,
    this.categoryId,
    required this.links,
    required this.postBaseTags,
    required this.trendsBasePublishTags,
    this.userAddedTrendTags = const [],
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
    String? linkedinFirstComment,
    String? twitterFirstComment,
    bool? linkInFirstComment,
    String? embedding,
    String? postBaseTagsEmbedding,
    bool? isEmbedded,
    bool? isRemoved,
    String? categoryId,
    List<String>? links,
    List<String>? postBaseTags,
    List<String>? trendsBasePublishTags,
    List<String>? userAddedTrendTags,
    List<String>? mediaIds,
    List<Platform>? selectedPlatforms,
    List<Platform>? publishedPlatforms,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCategoryId = false,
    bool clearLinkedinContent = false,
    bool clearTwitterContent = false,
    bool clearLinkedinFirstComment = false,
    bool clearTwitterFirstComment = false,
    bool clearEmbedding = false,
    bool clearPostBaseTagsEmbedding = false,
  }) {
    return Post(
      id: id ?? this.id,
      dump: dump ?? this.dump,
      linkedinContent: clearLinkedinContent ? null : linkedinContent ?? this.linkedinContent,
      twitterContent: clearTwitterContent ? null : twitterContent ?? this.twitterContent,
      linkedinFirstComment: clearLinkedinFirstComment ? null : linkedinFirstComment ?? this.linkedinFirstComment,
      twitterFirstComment: clearTwitterFirstComment ? null : twitterFirstComment ?? this.twitterFirstComment,
      linkInFirstComment: linkInFirstComment ?? this.linkInFirstComment,
      embedding: clearEmbedding ? null : embedding ?? this.embedding,
      postBaseTagsEmbedding: clearPostBaseTagsEmbedding ? null : postBaseTagsEmbedding ?? this.postBaseTagsEmbedding,
      isEmbedded: isEmbedded ?? this.isEmbedded,
      isRemoved: isRemoved ?? this.isRemoved,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      links: links ?? this.links,
      postBaseTags: postBaseTags ?? this.postBaseTags,
      trendsBasePublishTags: trendsBasePublishTags ?? this.trendsBasePublishTags,
      userAddedTrendTags: userAddedTrendTags ?? this.userAddedTrendTags,
      mediaIds: mediaIds ?? this.mediaIds,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      publishedPlatforms: publishedPlatforms ?? this.publishedPlatforms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
