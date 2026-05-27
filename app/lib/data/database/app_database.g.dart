// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dumpMeta = const VerificationMeta('dump');
  @override
  late final GeneratedColumn<String> dump = GeneratedColumn<String>(
    'dump',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linkedinContentMeta = const VerificationMeta(
    'linkedinContent',
  );
  @override
  late final GeneratedColumn<String> linkedinContent = GeneratedColumn<String>(
    'linkedin_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _twitterContentMeta = const VerificationMeta(
    'twitterContent',
  );
  @override
  late final GeneratedColumn<String> twitterContent = GeneratedColumn<String>(
    'twitter_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<String> embedding = GeneratedColumn<String>(
    'embedding',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linksJsonMeta = const VerificationMeta(
    'linksJson',
  );
  @override
  late final GeneratedColumn<String> linksJson = GeneratedColumn<String>(
    'links_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _postBaseTagsJsonMeta = const VerificationMeta(
    'postBaseTagsJson',
  );
  @override
  late final GeneratedColumn<String> postBaseTagsJson = GeneratedColumn<String>(
    'post_base_tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _categoryBasePublishTagsJsonMeta =
      const VerificationMeta('categoryBasePublishTagsJson');
  @override
  late final GeneratedColumn<String> categoryBasePublishTagsJson =
      GeneratedColumn<String>(
        'category_base_publish_tags_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _trendsBasePublishTagsJsonMeta =
      const VerificationMeta('trendsBasePublishTagsJson');
  @override
  late final GeneratedColumn<String> trendsBasePublishTagsJson =
      GeneratedColumn<String>(
        'trends_base_publish_tags_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _mediaIdsJsonMeta = const VerificationMeta(
    'mediaIdsJson',
  );
  @override
  late final GeneratedColumn<String> mediaIdsJson = GeneratedColumn<String>(
    'media_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _selectedPlatformsJsonMeta =
      const VerificationMeta('selectedPlatformsJson');
  @override
  late final GeneratedColumn<String> selectedPlatformsJson =
      GeneratedColumn<String>(
        'selected_platforms_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _publishedPlatformsJsonMeta =
      const VerificationMeta('publishedPlatformsJson');
  @override
  late final GeneratedColumn<String> publishedPlatformsJson =
      GeneratedColumn<String>(
        'published_platforms_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _isEmbeddedMeta = const VerificationMeta(
    'isEmbedded',
  );
  @override
  late final GeneratedColumn<bool> isEmbedded = GeneratedColumn<bool>(
    'is_embedded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_embedded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRemovedMeta = const VerificationMeta(
    'isRemoved',
  );
  @override
  late final GeneratedColumn<bool> isRemoved = GeneratedColumn<bool>(
    'is_removed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_removed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dump,
    linkedinContent,
    twitterContent,
    embedding,
    categoryId,
    linksJson,
    postBaseTagsJson,
    categoryBasePublishTagsJson,
    trendsBasePublishTagsJson,
    mediaIdsJson,
    selectedPlatformsJson,
    publishedPlatformsJson,
    status,
    isEmbedded,
    isRemoved,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Post> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dump')) {
      context.handle(
        _dumpMeta,
        dump.isAcceptableOrUnknown(data['dump']!, _dumpMeta),
      );
    }
    if (data.containsKey('linkedin_content')) {
      context.handle(
        _linkedinContentMeta,
        linkedinContent.isAcceptableOrUnknown(
          data['linkedin_content']!,
          _linkedinContentMeta,
        ),
      );
    }
    if (data.containsKey('twitter_content')) {
      context.handle(
        _twitterContentMeta,
        twitterContent.isAcceptableOrUnknown(
          data['twitter_content']!,
          _twitterContentMeta,
        ),
      );
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('links_json')) {
      context.handle(
        _linksJsonMeta,
        linksJson.isAcceptableOrUnknown(data['links_json']!, _linksJsonMeta),
      );
    }
    if (data.containsKey('post_base_tags_json')) {
      context.handle(
        _postBaseTagsJsonMeta,
        postBaseTagsJson.isAcceptableOrUnknown(
          data['post_base_tags_json']!,
          _postBaseTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('category_base_publish_tags_json')) {
      context.handle(
        _categoryBasePublishTagsJsonMeta,
        categoryBasePublishTagsJson.isAcceptableOrUnknown(
          data['category_base_publish_tags_json']!,
          _categoryBasePublishTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('trends_base_publish_tags_json')) {
      context.handle(
        _trendsBasePublishTagsJsonMeta,
        trendsBasePublishTagsJson.isAcceptableOrUnknown(
          data['trends_base_publish_tags_json']!,
          _trendsBasePublishTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('media_ids_json')) {
      context.handle(
        _mediaIdsJsonMeta,
        mediaIdsJson.isAcceptableOrUnknown(
          data['media_ids_json']!,
          _mediaIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('selected_platforms_json')) {
      context.handle(
        _selectedPlatformsJsonMeta,
        selectedPlatformsJson.isAcceptableOrUnknown(
          data['selected_platforms_json']!,
          _selectedPlatformsJsonMeta,
        ),
      );
    }
    if (data.containsKey('published_platforms_json')) {
      context.handle(
        _publishedPlatformsJsonMeta,
        publishedPlatformsJson.isAcceptableOrUnknown(
          data['published_platforms_json']!,
          _publishedPlatformsJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_embedded')) {
      context.handle(
        _isEmbeddedMeta,
        isEmbedded.isAcceptableOrUnknown(data['is_embedded']!, _isEmbeddedMeta),
      );
    }
    if (data.containsKey('is_removed')) {
      context.handle(
        _isRemovedMeta,
        isRemoved.isAcceptableOrUnknown(data['is_removed']!, _isRemovedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dump: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dump'],
      )!,
      linkedinContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_content'],
      ),
      twitterContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}twitter_content'],
      ),
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      linksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}links_json'],
      )!,
      postBaseTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_base_tags_json'],
      )!,
      categoryBasePublishTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_base_publish_tags_json'],
      )!,
      trendsBasePublishTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trends_base_publish_tags_json'],
      )!,
      mediaIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_ids_json'],
      )!,
      selectedPlatformsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_platforms_json'],
      )!,
      publishedPlatformsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_platforms_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isEmbedded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_embedded'],
      )!,
      isRemoved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_removed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final String id;
  final String dump;
  final String? linkedinContent;
  final String? twitterContent;
  final String? embedding;
  final String? categoryId;
  final String linksJson;
  final String postBaseTagsJson;
  final String categoryBasePublishTagsJson;
  final String trendsBasePublishTagsJson;
  final String mediaIdsJson;
  final String selectedPlatformsJson;
  final String publishedPlatformsJson;
  final String status;
  final bool isEmbedded;
  final bool isRemoved;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Post({
    required this.id,
    required this.dump,
    this.linkedinContent,
    this.twitterContent,
    this.embedding,
    this.categoryId,
    required this.linksJson,
    required this.postBaseTagsJson,
    required this.categoryBasePublishTagsJson,
    required this.trendsBasePublishTagsJson,
    required this.mediaIdsJson,
    required this.selectedPlatformsJson,
    required this.publishedPlatformsJson,
    required this.status,
    required this.isEmbedded,
    required this.isRemoved,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dump'] = Variable<String>(dump);
    if (!nullToAbsent || linkedinContent != null) {
      map['linkedin_content'] = Variable<String>(linkedinContent);
    }
    if (!nullToAbsent || twitterContent != null) {
      map['twitter_content'] = Variable<String>(twitterContent);
    }
    if (!nullToAbsent || embedding != null) {
      map['embedding'] = Variable<String>(embedding);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['links_json'] = Variable<String>(linksJson);
    map['post_base_tags_json'] = Variable<String>(postBaseTagsJson);
    map['category_base_publish_tags_json'] = Variable<String>(
      categoryBasePublishTagsJson,
    );
    map['trends_base_publish_tags_json'] = Variable<String>(
      trendsBasePublishTagsJson,
    );
    map['media_ids_json'] = Variable<String>(mediaIdsJson);
    map['selected_platforms_json'] = Variable<String>(selectedPlatformsJson);
    map['published_platforms_json'] = Variable<String>(publishedPlatformsJson);
    map['status'] = Variable<String>(status);
    map['is_embedded'] = Variable<bool>(isEmbedded);
    map['is_removed'] = Variable<bool>(isRemoved);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      dump: Value(dump),
      linkedinContent: linkedinContent == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinContent),
      twitterContent: twitterContent == null && nullToAbsent
          ? const Value.absent()
          : Value(twitterContent),
      embedding: embedding == null && nullToAbsent
          ? const Value.absent()
          : Value(embedding),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      linksJson: Value(linksJson),
      postBaseTagsJson: Value(postBaseTagsJson),
      categoryBasePublishTagsJson: Value(categoryBasePublishTagsJson),
      trendsBasePublishTagsJson: Value(trendsBasePublishTagsJson),
      mediaIdsJson: Value(mediaIdsJson),
      selectedPlatformsJson: Value(selectedPlatformsJson),
      publishedPlatformsJson: Value(publishedPlatformsJson),
      status: Value(status),
      isEmbedded: Value(isEmbedded),
      isRemoved: Value(isRemoved),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Post.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      id: serializer.fromJson<String>(json['id']),
      dump: serializer.fromJson<String>(json['dump']),
      linkedinContent: serializer.fromJson<String?>(json['linkedinContent']),
      twitterContent: serializer.fromJson<String?>(json['twitterContent']),
      embedding: serializer.fromJson<String?>(json['embedding']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      linksJson: serializer.fromJson<String>(json['linksJson']),
      postBaseTagsJson: serializer.fromJson<String>(json['postBaseTagsJson']),
      categoryBasePublishTagsJson: serializer.fromJson<String>(
        json['categoryBasePublishTagsJson'],
      ),
      trendsBasePublishTagsJson: serializer.fromJson<String>(
        json['trendsBasePublishTagsJson'],
      ),
      mediaIdsJson: serializer.fromJson<String>(json['mediaIdsJson']),
      selectedPlatformsJson: serializer.fromJson<String>(
        json['selectedPlatformsJson'],
      ),
      publishedPlatformsJson: serializer.fromJson<String>(
        json['publishedPlatformsJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      isEmbedded: serializer.fromJson<bool>(json['isEmbedded']),
      isRemoved: serializer.fromJson<bool>(json['isRemoved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dump': serializer.toJson<String>(dump),
      'linkedinContent': serializer.toJson<String?>(linkedinContent),
      'twitterContent': serializer.toJson<String?>(twitterContent),
      'embedding': serializer.toJson<String?>(embedding),
      'categoryId': serializer.toJson<String?>(categoryId),
      'linksJson': serializer.toJson<String>(linksJson),
      'postBaseTagsJson': serializer.toJson<String>(postBaseTagsJson),
      'categoryBasePublishTagsJson': serializer.toJson<String>(
        categoryBasePublishTagsJson,
      ),
      'trendsBasePublishTagsJson': serializer.toJson<String>(
        trendsBasePublishTagsJson,
      ),
      'mediaIdsJson': serializer.toJson<String>(mediaIdsJson),
      'selectedPlatformsJson': serializer.toJson<String>(selectedPlatformsJson),
      'publishedPlatformsJson': serializer.toJson<String>(
        publishedPlatformsJson,
      ),
      'status': serializer.toJson<String>(status),
      'isEmbedded': serializer.toJson<bool>(isEmbedded),
      'isRemoved': serializer.toJson<bool>(isRemoved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Post copyWith({
    String? id,
    String? dump,
    Value<String?> linkedinContent = const Value.absent(),
    Value<String?> twitterContent = const Value.absent(),
    Value<String?> embedding = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? linksJson,
    String? postBaseTagsJson,
    String? categoryBasePublishTagsJson,
    String? trendsBasePublishTagsJson,
    String? mediaIdsJson,
    String? selectedPlatformsJson,
    String? publishedPlatformsJson,
    String? status,
    bool? isEmbedded,
    bool? isRemoved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Post(
    id: id ?? this.id,
    dump: dump ?? this.dump,
    linkedinContent: linkedinContent.present
        ? linkedinContent.value
        : this.linkedinContent,
    twitterContent: twitterContent.present
        ? twitterContent.value
        : this.twitterContent,
    embedding: embedding.present ? embedding.value : this.embedding,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    linksJson: linksJson ?? this.linksJson,
    postBaseTagsJson: postBaseTagsJson ?? this.postBaseTagsJson,
    categoryBasePublishTagsJson:
        categoryBasePublishTagsJson ?? this.categoryBasePublishTagsJson,
    trendsBasePublishTagsJson:
        trendsBasePublishTagsJson ?? this.trendsBasePublishTagsJson,
    mediaIdsJson: mediaIdsJson ?? this.mediaIdsJson,
    selectedPlatformsJson: selectedPlatformsJson ?? this.selectedPlatformsJson,
    publishedPlatformsJson:
        publishedPlatformsJson ?? this.publishedPlatformsJson,
    status: status ?? this.status,
    isEmbedded: isEmbedded ?? this.isEmbedded,
    isRemoved: isRemoved ?? this.isRemoved,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      id: data.id.present ? data.id.value : this.id,
      dump: data.dump.present ? data.dump.value : this.dump,
      linkedinContent: data.linkedinContent.present
          ? data.linkedinContent.value
          : this.linkedinContent,
      twitterContent: data.twitterContent.present
          ? data.twitterContent.value
          : this.twitterContent,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      linksJson: data.linksJson.present ? data.linksJson.value : this.linksJson,
      postBaseTagsJson: data.postBaseTagsJson.present
          ? data.postBaseTagsJson.value
          : this.postBaseTagsJson,
      categoryBasePublishTagsJson: data.categoryBasePublishTagsJson.present
          ? data.categoryBasePublishTagsJson.value
          : this.categoryBasePublishTagsJson,
      trendsBasePublishTagsJson: data.trendsBasePublishTagsJson.present
          ? data.trendsBasePublishTagsJson.value
          : this.trendsBasePublishTagsJson,
      mediaIdsJson: data.mediaIdsJson.present
          ? data.mediaIdsJson.value
          : this.mediaIdsJson,
      selectedPlatformsJson: data.selectedPlatformsJson.present
          ? data.selectedPlatformsJson.value
          : this.selectedPlatformsJson,
      publishedPlatformsJson: data.publishedPlatformsJson.present
          ? data.publishedPlatformsJson.value
          : this.publishedPlatformsJson,
      status: data.status.present ? data.status.value : this.status,
      isEmbedded: data.isEmbedded.present
          ? data.isEmbedded.value
          : this.isEmbedded,
      isRemoved: data.isRemoved.present ? data.isRemoved.value : this.isRemoved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('id: $id, ')
          ..write('dump: $dump, ')
          ..write('linkedinContent: $linkedinContent, ')
          ..write('twitterContent: $twitterContent, ')
          ..write('embedding: $embedding, ')
          ..write('categoryId: $categoryId, ')
          ..write('linksJson: $linksJson, ')
          ..write('postBaseTagsJson: $postBaseTagsJson, ')
          ..write('categoryBasePublishTagsJson: $categoryBasePublishTagsJson, ')
          ..write('trendsBasePublishTagsJson: $trendsBasePublishTagsJson, ')
          ..write('mediaIdsJson: $mediaIdsJson, ')
          ..write('selectedPlatformsJson: $selectedPlatformsJson, ')
          ..write('publishedPlatformsJson: $publishedPlatformsJson, ')
          ..write('status: $status, ')
          ..write('isEmbedded: $isEmbedded, ')
          ..write('isRemoved: $isRemoved, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dump,
    linkedinContent,
    twitterContent,
    embedding,
    categoryId,
    linksJson,
    postBaseTagsJson,
    categoryBasePublishTagsJson,
    trendsBasePublishTagsJson,
    mediaIdsJson,
    selectedPlatformsJson,
    publishedPlatformsJson,
    status,
    isEmbedded,
    isRemoved,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.id == this.id &&
          other.dump == this.dump &&
          other.linkedinContent == this.linkedinContent &&
          other.twitterContent == this.twitterContent &&
          other.embedding == this.embedding &&
          other.categoryId == this.categoryId &&
          other.linksJson == this.linksJson &&
          other.postBaseTagsJson == this.postBaseTagsJson &&
          other.categoryBasePublishTagsJson ==
              this.categoryBasePublishTagsJson &&
          other.trendsBasePublishTagsJson == this.trendsBasePublishTagsJson &&
          other.mediaIdsJson == this.mediaIdsJson &&
          other.selectedPlatformsJson == this.selectedPlatformsJson &&
          other.publishedPlatformsJson == this.publishedPlatformsJson &&
          other.status == this.status &&
          other.isEmbedded == this.isEmbedded &&
          other.isRemoved == this.isRemoved &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<String> id;
  final Value<String> dump;
  final Value<String?> linkedinContent;
  final Value<String?> twitterContent;
  final Value<String?> embedding;
  final Value<String?> categoryId;
  final Value<String> linksJson;
  final Value<String> postBaseTagsJson;
  final Value<String> categoryBasePublishTagsJson;
  final Value<String> trendsBasePublishTagsJson;
  final Value<String> mediaIdsJson;
  final Value<String> selectedPlatformsJson;
  final Value<String> publishedPlatformsJson;
  final Value<String> status;
  final Value<bool> isEmbedded;
  final Value<bool> isRemoved;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.dump = const Value.absent(),
    this.linkedinContent = const Value.absent(),
    this.twitterContent = const Value.absent(),
    this.embedding = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.postBaseTagsJson = const Value.absent(),
    this.categoryBasePublishTagsJson = const Value.absent(),
    this.trendsBasePublishTagsJson = const Value.absent(),
    this.mediaIdsJson = const Value.absent(),
    this.selectedPlatformsJson = const Value.absent(),
    this.publishedPlatformsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.isEmbedded = const Value.absent(),
    this.isRemoved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    this.dump = const Value.absent(),
    this.linkedinContent = const Value.absent(),
    this.twitterContent = const Value.absent(),
    this.embedding = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.postBaseTagsJson = const Value.absent(),
    this.categoryBasePublishTagsJson = const Value.absent(),
    this.trendsBasePublishTagsJson = const Value.absent(),
    this.mediaIdsJson = const Value.absent(),
    this.selectedPlatformsJson = const Value.absent(),
    this.publishedPlatformsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.isEmbedded = const Value.absent(),
    this.isRemoved = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Post> custom({
    Expression<String>? id,
    Expression<String>? dump,
    Expression<String>? linkedinContent,
    Expression<String>? twitterContent,
    Expression<String>? embedding,
    Expression<String>? categoryId,
    Expression<String>? linksJson,
    Expression<String>? postBaseTagsJson,
    Expression<String>? categoryBasePublishTagsJson,
    Expression<String>? trendsBasePublishTagsJson,
    Expression<String>? mediaIdsJson,
    Expression<String>? selectedPlatformsJson,
    Expression<String>? publishedPlatformsJson,
    Expression<String>? status,
    Expression<bool>? isEmbedded,
    Expression<bool>? isRemoved,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dump != null) 'dump': dump,
      if (linkedinContent != null) 'linkedin_content': linkedinContent,
      if (twitterContent != null) 'twitter_content': twitterContent,
      if (embedding != null) 'embedding': embedding,
      if (categoryId != null) 'category_id': categoryId,
      if (linksJson != null) 'links_json': linksJson,
      if (postBaseTagsJson != null) 'post_base_tags_json': postBaseTagsJson,
      if (categoryBasePublishTagsJson != null)
        'category_base_publish_tags_json': categoryBasePublishTagsJson,
      if (trendsBasePublishTagsJson != null)
        'trends_base_publish_tags_json': trendsBasePublishTagsJson,
      if (mediaIdsJson != null) 'media_ids_json': mediaIdsJson,
      if (selectedPlatformsJson != null)
        'selected_platforms_json': selectedPlatformsJson,
      if (publishedPlatformsJson != null)
        'published_platforms_json': publishedPlatformsJson,
      if (status != null) 'status': status,
      if (isEmbedded != null) 'is_embedded': isEmbedded,
      if (isRemoved != null) 'is_removed': isRemoved,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String>? dump,
    Value<String?>? linkedinContent,
    Value<String?>? twitterContent,
    Value<String?>? embedding,
    Value<String?>? categoryId,
    Value<String>? linksJson,
    Value<String>? postBaseTagsJson,
    Value<String>? categoryBasePublishTagsJson,
    Value<String>? trendsBasePublishTagsJson,
    Value<String>? mediaIdsJson,
    Value<String>? selectedPlatformsJson,
    Value<String>? publishedPlatformsJson,
    Value<String>? status,
    Value<bool>? isEmbedded,
    Value<bool>? isRemoved,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      dump: dump ?? this.dump,
      linkedinContent: linkedinContent ?? this.linkedinContent,
      twitterContent: twitterContent ?? this.twitterContent,
      embedding: embedding ?? this.embedding,
      categoryId: categoryId ?? this.categoryId,
      linksJson: linksJson ?? this.linksJson,
      postBaseTagsJson: postBaseTagsJson ?? this.postBaseTagsJson,
      categoryBasePublishTagsJson:
          categoryBasePublishTagsJson ?? this.categoryBasePublishTagsJson,
      trendsBasePublishTagsJson:
          trendsBasePublishTagsJson ?? this.trendsBasePublishTagsJson,
      mediaIdsJson: mediaIdsJson ?? this.mediaIdsJson,
      selectedPlatformsJson:
          selectedPlatformsJson ?? this.selectedPlatformsJson,
      publishedPlatformsJson:
          publishedPlatformsJson ?? this.publishedPlatformsJson,
      status: status ?? this.status,
      isEmbedded: isEmbedded ?? this.isEmbedded,
      isRemoved: isRemoved ?? this.isRemoved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dump.present) {
      map['dump'] = Variable<String>(dump.value);
    }
    if (linkedinContent.present) {
      map['linkedin_content'] = Variable<String>(linkedinContent.value);
    }
    if (twitterContent.present) {
      map['twitter_content'] = Variable<String>(twitterContent.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<String>(embedding.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (linksJson.present) {
      map['links_json'] = Variable<String>(linksJson.value);
    }
    if (postBaseTagsJson.present) {
      map['post_base_tags_json'] = Variable<String>(postBaseTagsJson.value);
    }
    if (categoryBasePublishTagsJson.present) {
      map['category_base_publish_tags_json'] = Variable<String>(
        categoryBasePublishTagsJson.value,
      );
    }
    if (trendsBasePublishTagsJson.present) {
      map['trends_base_publish_tags_json'] = Variable<String>(
        trendsBasePublishTagsJson.value,
      );
    }
    if (mediaIdsJson.present) {
      map['media_ids_json'] = Variable<String>(mediaIdsJson.value);
    }
    if (selectedPlatformsJson.present) {
      map['selected_platforms_json'] = Variable<String>(
        selectedPlatformsJson.value,
      );
    }
    if (publishedPlatformsJson.present) {
      map['published_platforms_json'] = Variable<String>(
        publishedPlatformsJson.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isEmbedded.present) {
      map['is_embedded'] = Variable<bool>(isEmbedded.value);
    }
    if (isRemoved.present) {
      map['is_removed'] = Variable<bool>(isRemoved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('dump: $dump, ')
          ..write('linkedinContent: $linkedinContent, ')
          ..write('twitterContent: $twitterContent, ')
          ..write('embedding: $embedding, ')
          ..write('categoryId: $categoryId, ')
          ..write('linksJson: $linksJson, ')
          ..write('postBaseTagsJson: $postBaseTagsJson, ')
          ..write('categoryBasePublishTagsJson: $categoryBasePublishTagsJson, ')
          ..write('trendsBasePublishTagsJson: $trendsBasePublishTagsJson, ')
          ..write('mediaIdsJson: $mediaIdsJson, ')
          ..write('selectedPlatformsJson: $selectedPlatformsJson, ')
          ..write('publishedPlatformsJson: $publishedPlatformsJson, ')
          ..write('status: $status, ')
          ..write('isEmbedded: $isEmbedded, ')
          ..write('isRemoved: $isRemoved, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalFilenameMeta = const VerificationMeta(
    'originalFilename',
  );
  @override
  late final GeneratedColumn<String> originalFilename = GeneratedColumn<String>(
    'original_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedFilenameMeta = const VerificationMeta(
    'storedFilename',
  );
  @override
  late final GeneratedColumn<String> storedFilename = GeneratedColumn<String>(
    'stored_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalFilename,
    storedFilename,
    addedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('original_filename')) {
      context.handle(
        _originalFilenameMeta,
        originalFilename.isAcceptableOrUnknown(
          data['original_filename']!,
          _originalFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalFilenameMeta);
    }
    if (data.containsKey('stored_filename')) {
      context.handle(
        _storedFilenameMeta,
        storedFilename.isAcceptableOrUnknown(
          data['stored_filename']!,
          _storedFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedFilenameMeta);
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      originalFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_filename'],
      )!,
      storedFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_filename'],
      )!,
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_date'],
      )!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaData extends DataClass implements Insertable<MediaData> {
  final String id;
  final String originalFilename;
  final String storedFilename;
  final DateTime addedDate;
  const MediaData({
    required this.id,
    required this.originalFilename,
    required this.storedFilename,
    required this.addedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['original_filename'] = Variable<String>(originalFilename);
    map['stored_filename'] = Variable<String>(storedFilename);
    map['added_date'] = Variable<DateTime>(addedDate);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      originalFilename: Value(originalFilename),
      storedFilename: Value(storedFilename),
      addedDate: Value(addedDate),
    );
  }

  factory MediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaData(
      id: serializer.fromJson<String>(json['id']),
      originalFilename: serializer.fromJson<String>(json['originalFilename']),
      storedFilename: serializer.fromJson<String>(json['storedFilename']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originalFilename': serializer.toJson<String>(originalFilename),
      'storedFilename': serializer.toJson<String>(storedFilename),
      'addedDate': serializer.toJson<DateTime>(addedDate),
    };
  }

  MediaData copyWith({
    String? id,
    String? originalFilename,
    String? storedFilename,
    DateTime? addedDate,
  }) => MediaData(
    id: id ?? this.id,
    originalFilename: originalFilename ?? this.originalFilename,
    storedFilename: storedFilename ?? this.storedFilename,
    addedDate: addedDate ?? this.addedDate,
  );
  MediaData copyWithCompanion(MediaCompanion data) {
    return MediaData(
      id: data.id.present ? data.id.value : this.id,
      originalFilename: data.originalFilename.present
          ? data.originalFilename.value
          : this.originalFilename,
      storedFilename: data.storedFilename.present
          ? data.storedFilename.value
          : this.storedFilename,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaData(')
          ..write('id: $id, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('storedFilename: $storedFilename, ')
          ..write('addedDate: $addedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, originalFilename, storedFilename, addedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaData &&
          other.id == this.id &&
          other.originalFilename == this.originalFilename &&
          other.storedFilename == this.storedFilename &&
          other.addedDate == this.addedDate);
}

class MediaCompanion extends UpdateCompanion<MediaData> {
  final Value<String> id;
  final Value<String> originalFilename;
  final Value<String> storedFilename;
  final Value<DateTime> addedDate;
  final Value<int> rowid;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.originalFilename = const Value.absent(),
    this.storedFilename = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCompanion.insert({
    required String id,
    required String originalFilename,
    required String storedFilename,
    required DateTime addedDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       originalFilename = Value(originalFilename),
       storedFilename = Value(storedFilename),
       addedDate = Value(addedDate);
  static Insertable<MediaData> custom({
    Expression<String>? id,
    Expression<String>? originalFilename,
    Expression<String>? storedFilename,
    Expression<DateTime>? addedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalFilename != null) 'original_filename': originalFilename,
      if (storedFilename != null) 'stored_filename': storedFilename,
      if (addedDate != null) 'added_date': addedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCompanion copyWith({
    Value<String>? id,
    Value<String>? originalFilename,
    Value<String>? storedFilename,
    Value<DateTime>? addedDate,
    Value<int>? rowid,
  }) {
    return MediaCompanion(
      id: id ?? this.id,
      originalFilename: originalFilename ?? this.originalFilename,
      storedFilename: storedFilename ?? this.storedFilename,
      addedDate: addedDate ?? this.addedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originalFilename.present) {
      map['original_filename'] = Variable<String>(originalFilename.value);
    }
    if (storedFilename.present) {
      map['stored_filename'] = Variable<String>(storedFilename.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('storedFilename: $storedFilename, ')
          ..write('addedDate: $addedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _linkedinAuthTokenMeta = const VerificationMeta(
    'linkedinAuthToken',
  );
  @override
  late final GeneratedColumn<String> linkedinAuthToken =
      GeneratedColumn<String>(
        'linkedin_auth_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedinRefreshTokenMeta =
      const VerificationMeta('linkedinRefreshToken');
  @override
  late final GeneratedColumn<String> linkedinRefreshToken =
      GeneratedColumn<String>(
        'linkedin_refresh_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _xAuthTokenMeta = const VerificationMeta(
    'xAuthToken',
  );
  @override
  late final GeneratedColumn<String> xAuthToken = GeneratedColumn<String>(
    'x_auth_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xRefreshTokenMeta = const VerificationMeta(
    'xRefreshToken',
  );
  @override
  late final GeneratedColumn<String> xRefreshToken = GeneratedColumn<String>(
    'x_refresh_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geminiTokenMeta = const VerificationMeta(
    'geminiToken',
  );
  @override
  late final GeneratedColumn<String> geminiToken = GeneratedColumn<String>(
    'gemini_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishPerWeekMeta = const VerificationMeta(
    'publishPerWeek',
  );
  @override
  late final GeneratedColumn<int> publishPerWeek = GeneratedColumn<int>(
    'publish_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _genModelMeta = const VerificationMeta(
    'genModel',
  );
  @override
  late final GeneratedColumn<String> genModel = GeneratedColumn<String>(
    'gen_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embedModelMeta = const VerificationMeta(
    'embedModel',
  );
  @override
  late final GeneratedColumn<String> embedModel = GeneratedColumn<String>(
    'embed_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedinClientIdMeta = const VerificationMeta(
    'linkedinClientId',
  );
  @override
  late final GeneratedColumn<String> linkedinClientId = GeneratedColumn<String>(
    'linkedin_client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedinClientSecretMeta =
      const VerificationMeta('linkedinClientSecret');
  @override
  late final GeneratedColumn<String> linkedinClientSecret =
      GeneratedColumn<String>(
        'linkedin_client_secret',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _xClientIdMeta = const VerificationMeta(
    'xClientId',
  );
  @override
  late final GeneratedColumn<String> xClientId = GeneratedColumn<String>(
    'x_client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xClientSecretMeta = const VerificationMeta(
    'xClientSecret',
  );
  @override
  late final GeneratedColumn<String> xClientSecret = GeneratedColumn<String>(
    'x_client_secret',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _copyToLinkedinMeta = const VerificationMeta(
    'copyToLinkedin',
  );
  @override
  late final GeneratedColumn<bool> copyToLinkedin = GeneratedColumn<bool>(
    'copy_to_linkedin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("copy_to_linkedin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _copyToXMeta = const VerificationMeta(
    'copyToX',
  );
  @override
  late final GeneratedColumn<bool> copyToX = GeneratedColumn<bool>(
    'copy_to_x',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("copy_to_x" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dbSchemaVersionMeta = const VerificationMeta(
    'dbSchemaVersion',
  );
  @override
  late final GeneratedColumn<int> dbSchemaVersion = GeneratedColumn<int>(
    'db_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    linkedinAuthToken,
    linkedinRefreshToken,
    xAuthToken,
    xRefreshToken,
    geminiToken,
    publishPerWeek,
    genModel,
    embedModel,
    linkedinClientId,
    linkedinClientSecret,
    xClientId,
    xClientSecret,
    themeMode,
    copyToLinkedin,
    copyToX,
    dbSchemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('linkedin_auth_token')) {
      context.handle(
        _linkedinAuthTokenMeta,
        linkedinAuthToken.isAcceptableOrUnknown(
          data['linkedin_auth_token']!,
          _linkedinAuthTokenMeta,
        ),
      );
    }
    if (data.containsKey('linkedin_refresh_token')) {
      context.handle(
        _linkedinRefreshTokenMeta,
        linkedinRefreshToken.isAcceptableOrUnknown(
          data['linkedin_refresh_token']!,
          _linkedinRefreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('x_auth_token')) {
      context.handle(
        _xAuthTokenMeta,
        xAuthToken.isAcceptableOrUnknown(
          data['x_auth_token']!,
          _xAuthTokenMeta,
        ),
      );
    }
    if (data.containsKey('x_refresh_token')) {
      context.handle(
        _xRefreshTokenMeta,
        xRefreshToken.isAcceptableOrUnknown(
          data['x_refresh_token']!,
          _xRefreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('gemini_token')) {
      context.handle(
        _geminiTokenMeta,
        geminiToken.isAcceptableOrUnknown(
          data['gemini_token']!,
          _geminiTokenMeta,
        ),
      );
    }
    if (data.containsKey('publish_per_week')) {
      context.handle(
        _publishPerWeekMeta,
        publishPerWeek.isAcceptableOrUnknown(
          data['publish_per_week']!,
          _publishPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('gen_model')) {
      context.handle(
        _genModelMeta,
        genModel.isAcceptableOrUnknown(data['gen_model']!, _genModelMeta),
      );
    }
    if (data.containsKey('embed_model')) {
      context.handle(
        _embedModelMeta,
        embedModel.isAcceptableOrUnknown(data['embed_model']!, _embedModelMeta),
      );
    }
    if (data.containsKey('linkedin_client_id')) {
      context.handle(
        _linkedinClientIdMeta,
        linkedinClientId.isAcceptableOrUnknown(
          data['linkedin_client_id']!,
          _linkedinClientIdMeta,
        ),
      );
    }
    if (data.containsKey('linkedin_client_secret')) {
      context.handle(
        _linkedinClientSecretMeta,
        linkedinClientSecret.isAcceptableOrUnknown(
          data['linkedin_client_secret']!,
          _linkedinClientSecretMeta,
        ),
      );
    }
    if (data.containsKey('x_client_id')) {
      context.handle(
        _xClientIdMeta,
        xClientId.isAcceptableOrUnknown(data['x_client_id']!, _xClientIdMeta),
      );
    }
    if (data.containsKey('x_client_secret')) {
      context.handle(
        _xClientSecretMeta,
        xClientSecret.isAcceptableOrUnknown(
          data['x_client_secret']!,
          _xClientSecretMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('copy_to_linkedin')) {
      context.handle(
        _copyToLinkedinMeta,
        copyToLinkedin.isAcceptableOrUnknown(
          data['copy_to_linkedin']!,
          _copyToLinkedinMeta,
        ),
      );
    }
    if (data.containsKey('copy_to_x')) {
      context.handle(
        _copyToXMeta,
        copyToX.isAcceptableOrUnknown(data['copy_to_x']!, _copyToXMeta),
      );
    }
    if (data.containsKey('db_schema_version')) {
      context.handle(
        _dbSchemaVersionMeta,
        dbSchemaVersion.isAcceptableOrUnknown(
          data['db_schema_version']!,
          _dbSchemaVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      linkedinAuthToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_auth_token'],
      ),
      linkedinRefreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_refresh_token'],
      ),
      xAuthToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}x_auth_token'],
      ),
      xRefreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}x_refresh_token'],
      ),
      geminiToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gemini_token'],
      ),
      publishPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publish_per_week'],
      )!,
      genModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gen_model'],
      ),
      embedModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embed_model'],
      ),
      linkedinClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_client_id'],
      ),
      linkedinClientSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_client_secret'],
      ),
      xClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}x_client_id'],
      ),
      xClientSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}x_client_secret'],
      ),
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      copyToLinkedin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}copy_to_linkedin'],
      )!,
      copyToX: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}copy_to_x'],
      )!,
      dbSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}db_schema_version'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int rowId;
  final String? linkedinAuthToken;
  final String? linkedinRefreshToken;
  final String? xAuthToken;
  final String? xRefreshToken;
  final String? geminiToken;
  final int publishPerWeek;
  final String? genModel;
  final String? embedModel;
  final String? linkedinClientId;
  final String? linkedinClientSecret;
  final String? xClientId;
  final String? xClientSecret;
  final String themeMode;
  final bool copyToLinkedin;
  final bool copyToX;
  final int dbSchemaVersion;
  const Setting({
    required this.rowId,
    this.linkedinAuthToken,
    this.linkedinRefreshToken,
    this.xAuthToken,
    this.xRefreshToken,
    this.geminiToken,
    required this.publishPerWeek,
    this.genModel,
    this.embedModel,
    this.linkedinClientId,
    this.linkedinClientSecret,
    this.xClientId,
    this.xClientSecret,
    required this.themeMode,
    required this.copyToLinkedin,
    required this.copyToX,
    required this.dbSchemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    if (!nullToAbsent || linkedinAuthToken != null) {
      map['linkedin_auth_token'] = Variable<String>(linkedinAuthToken);
    }
    if (!nullToAbsent || linkedinRefreshToken != null) {
      map['linkedin_refresh_token'] = Variable<String>(linkedinRefreshToken);
    }
    if (!nullToAbsent || xAuthToken != null) {
      map['x_auth_token'] = Variable<String>(xAuthToken);
    }
    if (!nullToAbsent || xRefreshToken != null) {
      map['x_refresh_token'] = Variable<String>(xRefreshToken);
    }
    if (!nullToAbsent || geminiToken != null) {
      map['gemini_token'] = Variable<String>(geminiToken);
    }
    map['publish_per_week'] = Variable<int>(publishPerWeek);
    if (!nullToAbsent || genModel != null) {
      map['gen_model'] = Variable<String>(genModel);
    }
    if (!nullToAbsent || embedModel != null) {
      map['embed_model'] = Variable<String>(embedModel);
    }
    if (!nullToAbsent || linkedinClientId != null) {
      map['linkedin_client_id'] = Variable<String>(linkedinClientId);
    }
    if (!nullToAbsent || linkedinClientSecret != null) {
      map['linkedin_client_secret'] = Variable<String>(linkedinClientSecret);
    }
    if (!nullToAbsent || xClientId != null) {
      map['x_client_id'] = Variable<String>(xClientId);
    }
    if (!nullToAbsent || xClientSecret != null) {
      map['x_client_secret'] = Variable<String>(xClientSecret);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    map['copy_to_linkedin'] = Variable<bool>(copyToLinkedin);
    map['copy_to_x'] = Variable<bool>(copyToX);
    map['db_schema_version'] = Variable<int>(dbSchemaVersion);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      rowId: Value(rowId),
      linkedinAuthToken: linkedinAuthToken == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinAuthToken),
      linkedinRefreshToken: linkedinRefreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinRefreshToken),
      xAuthToken: xAuthToken == null && nullToAbsent
          ? const Value.absent()
          : Value(xAuthToken),
      xRefreshToken: xRefreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(xRefreshToken),
      geminiToken: geminiToken == null && nullToAbsent
          ? const Value.absent()
          : Value(geminiToken),
      publishPerWeek: Value(publishPerWeek),
      genModel: genModel == null && nullToAbsent
          ? const Value.absent()
          : Value(genModel),
      embedModel: embedModel == null && nullToAbsent
          ? const Value.absent()
          : Value(embedModel),
      linkedinClientId: linkedinClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinClientId),
      linkedinClientSecret: linkedinClientSecret == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinClientSecret),
      xClientId: xClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(xClientId),
      xClientSecret: xClientSecret == null && nullToAbsent
          ? const Value.absent()
          : Value(xClientSecret),
      themeMode: Value(themeMode),
      copyToLinkedin: Value(copyToLinkedin),
      copyToX: Value(copyToX),
      dbSchemaVersion: Value(dbSchemaVersion),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      rowId: serializer.fromJson<int>(json['rowId']),
      linkedinAuthToken: serializer.fromJson<String?>(
        json['linkedinAuthToken'],
      ),
      linkedinRefreshToken: serializer.fromJson<String?>(
        json['linkedinRefreshToken'],
      ),
      xAuthToken: serializer.fromJson<String?>(json['xAuthToken']),
      xRefreshToken: serializer.fromJson<String?>(json['xRefreshToken']),
      geminiToken: serializer.fromJson<String?>(json['geminiToken']),
      publishPerWeek: serializer.fromJson<int>(json['publishPerWeek']),
      genModel: serializer.fromJson<String?>(json['genModel']),
      embedModel: serializer.fromJson<String?>(json['embedModel']),
      linkedinClientId: serializer.fromJson<String?>(json['linkedinClientId']),
      linkedinClientSecret: serializer.fromJson<String?>(
        json['linkedinClientSecret'],
      ),
      xClientId: serializer.fromJson<String?>(json['xClientId']),
      xClientSecret: serializer.fromJson<String?>(json['xClientSecret']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      copyToLinkedin: serializer.fromJson<bool>(json['copyToLinkedin']),
      copyToX: serializer.fromJson<bool>(json['copyToX']),
      dbSchemaVersion: serializer.fromJson<int>(json['dbSchemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'linkedinAuthToken': serializer.toJson<String?>(linkedinAuthToken),
      'linkedinRefreshToken': serializer.toJson<String?>(linkedinRefreshToken),
      'xAuthToken': serializer.toJson<String?>(xAuthToken),
      'xRefreshToken': serializer.toJson<String?>(xRefreshToken),
      'geminiToken': serializer.toJson<String?>(geminiToken),
      'publishPerWeek': serializer.toJson<int>(publishPerWeek),
      'genModel': serializer.toJson<String?>(genModel),
      'embedModel': serializer.toJson<String?>(embedModel),
      'linkedinClientId': serializer.toJson<String?>(linkedinClientId),
      'linkedinClientSecret': serializer.toJson<String?>(linkedinClientSecret),
      'xClientId': serializer.toJson<String?>(xClientId),
      'xClientSecret': serializer.toJson<String?>(xClientSecret),
      'themeMode': serializer.toJson<String>(themeMode),
      'copyToLinkedin': serializer.toJson<bool>(copyToLinkedin),
      'copyToX': serializer.toJson<bool>(copyToX),
      'dbSchemaVersion': serializer.toJson<int>(dbSchemaVersion),
    };
  }

  Setting copyWith({
    int? rowId,
    Value<String?> linkedinAuthToken = const Value.absent(),
    Value<String?> linkedinRefreshToken = const Value.absent(),
    Value<String?> xAuthToken = const Value.absent(),
    Value<String?> xRefreshToken = const Value.absent(),
    Value<String?> geminiToken = const Value.absent(),
    int? publishPerWeek,
    Value<String?> genModel = const Value.absent(),
    Value<String?> embedModel = const Value.absent(),
    Value<String?> linkedinClientId = const Value.absent(),
    Value<String?> linkedinClientSecret = const Value.absent(),
    Value<String?> xClientId = const Value.absent(),
    Value<String?> xClientSecret = const Value.absent(),
    String? themeMode,
    bool? copyToLinkedin,
    bool? copyToX,
    int? dbSchemaVersion,
  }) => Setting(
    rowId: rowId ?? this.rowId,
    linkedinAuthToken: linkedinAuthToken.present
        ? linkedinAuthToken.value
        : this.linkedinAuthToken,
    linkedinRefreshToken: linkedinRefreshToken.present
        ? linkedinRefreshToken.value
        : this.linkedinRefreshToken,
    xAuthToken: xAuthToken.present ? xAuthToken.value : this.xAuthToken,
    xRefreshToken: xRefreshToken.present
        ? xRefreshToken.value
        : this.xRefreshToken,
    geminiToken: geminiToken.present ? geminiToken.value : this.geminiToken,
    publishPerWeek: publishPerWeek ?? this.publishPerWeek,
    genModel: genModel.present ? genModel.value : this.genModel,
    embedModel: embedModel.present ? embedModel.value : this.embedModel,
    linkedinClientId: linkedinClientId.present
        ? linkedinClientId.value
        : this.linkedinClientId,
    linkedinClientSecret: linkedinClientSecret.present
        ? linkedinClientSecret.value
        : this.linkedinClientSecret,
    xClientId: xClientId.present ? xClientId.value : this.xClientId,
    xClientSecret: xClientSecret.present
        ? xClientSecret.value
        : this.xClientSecret,
    themeMode: themeMode ?? this.themeMode,
    copyToLinkedin: copyToLinkedin ?? this.copyToLinkedin,
    copyToX: copyToX ?? this.copyToX,
    dbSchemaVersion: dbSchemaVersion ?? this.dbSchemaVersion,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      linkedinAuthToken: data.linkedinAuthToken.present
          ? data.linkedinAuthToken.value
          : this.linkedinAuthToken,
      linkedinRefreshToken: data.linkedinRefreshToken.present
          ? data.linkedinRefreshToken.value
          : this.linkedinRefreshToken,
      xAuthToken: data.xAuthToken.present
          ? data.xAuthToken.value
          : this.xAuthToken,
      xRefreshToken: data.xRefreshToken.present
          ? data.xRefreshToken.value
          : this.xRefreshToken,
      geminiToken: data.geminiToken.present
          ? data.geminiToken.value
          : this.geminiToken,
      publishPerWeek: data.publishPerWeek.present
          ? data.publishPerWeek.value
          : this.publishPerWeek,
      genModel: data.genModel.present ? data.genModel.value : this.genModel,
      embedModel: data.embedModel.present
          ? data.embedModel.value
          : this.embedModel,
      linkedinClientId: data.linkedinClientId.present
          ? data.linkedinClientId.value
          : this.linkedinClientId,
      linkedinClientSecret: data.linkedinClientSecret.present
          ? data.linkedinClientSecret.value
          : this.linkedinClientSecret,
      xClientId: data.xClientId.present ? data.xClientId.value : this.xClientId,
      xClientSecret: data.xClientSecret.present
          ? data.xClientSecret.value
          : this.xClientSecret,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      copyToLinkedin: data.copyToLinkedin.present
          ? data.copyToLinkedin.value
          : this.copyToLinkedin,
      copyToX: data.copyToX.present ? data.copyToX.value : this.copyToX,
      dbSchemaVersion: data.dbSchemaVersion.present
          ? data.dbSchemaVersion.value
          : this.dbSchemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('rowId: $rowId, ')
          ..write('linkedinAuthToken: $linkedinAuthToken, ')
          ..write('linkedinRefreshToken: $linkedinRefreshToken, ')
          ..write('xAuthToken: $xAuthToken, ')
          ..write('xRefreshToken: $xRefreshToken, ')
          ..write('geminiToken: $geminiToken, ')
          ..write('publishPerWeek: $publishPerWeek, ')
          ..write('genModel: $genModel, ')
          ..write('embedModel: $embedModel, ')
          ..write('linkedinClientId: $linkedinClientId, ')
          ..write('linkedinClientSecret: $linkedinClientSecret, ')
          ..write('xClientId: $xClientId, ')
          ..write('xClientSecret: $xClientSecret, ')
          ..write('themeMode: $themeMode, ')
          ..write('copyToLinkedin: $copyToLinkedin, ')
          ..write('copyToX: $copyToX, ')
          ..write('dbSchemaVersion: $dbSchemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowId,
    linkedinAuthToken,
    linkedinRefreshToken,
    xAuthToken,
    xRefreshToken,
    geminiToken,
    publishPerWeek,
    genModel,
    embedModel,
    linkedinClientId,
    linkedinClientSecret,
    xClientId,
    xClientSecret,
    themeMode,
    copyToLinkedin,
    copyToX,
    dbSchemaVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.rowId == this.rowId &&
          other.linkedinAuthToken == this.linkedinAuthToken &&
          other.linkedinRefreshToken == this.linkedinRefreshToken &&
          other.xAuthToken == this.xAuthToken &&
          other.xRefreshToken == this.xRefreshToken &&
          other.geminiToken == this.geminiToken &&
          other.publishPerWeek == this.publishPerWeek &&
          other.genModel == this.genModel &&
          other.embedModel == this.embedModel &&
          other.linkedinClientId == this.linkedinClientId &&
          other.linkedinClientSecret == this.linkedinClientSecret &&
          other.xClientId == this.xClientId &&
          other.xClientSecret == this.xClientSecret &&
          other.themeMode == this.themeMode &&
          other.copyToLinkedin == this.copyToLinkedin &&
          other.copyToX == this.copyToX &&
          other.dbSchemaVersion == this.dbSchemaVersion);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> rowId;
  final Value<String?> linkedinAuthToken;
  final Value<String?> linkedinRefreshToken;
  final Value<String?> xAuthToken;
  final Value<String?> xRefreshToken;
  final Value<String?> geminiToken;
  final Value<int> publishPerWeek;
  final Value<String?> genModel;
  final Value<String?> embedModel;
  final Value<String?> linkedinClientId;
  final Value<String?> linkedinClientSecret;
  final Value<String?> xClientId;
  final Value<String?> xClientSecret;
  final Value<String> themeMode;
  final Value<bool> copyToLinkedin;
  final Value<bool> copyToX;
  final Value<int> dbSchemaVersion;
  const SettingsCompanion({
    this.rowId = const Value.absent(),
    this.linkedinAuthToken = const Value.absent(),
    this.linkedinRefreshToken = const Value.absent(),
    this.xAuthToken = const Value.absent(),
    this.xRefreshToken = const Value.absent(),
    this.geminiToken = const Value.absent(),
    this.publishPerWeek = const Value.absent(),
    this.genModel = const Value.absent(),
    this.embedModel = const Value.absent(),
    this.linkedinClientId = const Value.absent(),
    this.linkedinClientSecret = const Value.absent(),
    this.xClientId = const Value.absent(),
    this.xClientSecret = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.copyToLinkedin = const Value.absent(),
    this.copyToX = const Value.absent(),
    this.dbSchemaVersion = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.rowId = const Value.absent(),
    this.linkedinAuthToken = const Value.absent(),
    this.linkedinRefreshToken = const Value.absent(),
    this.xAuthToken = const Value.absent(),
    this.xRefreshToken = const Value.absent(),
    this.geminiToken = const Value.absent(),
    this.publishPerWeek = const Value.absent(),
    this.genModel = const Value.absent(),
    this.embedModel = const Value.absent(),
    this.linkedinClientId = const Value.absent(),
    this.linkedinClientSecret = const Value.absent(),
    this.xClientId = const Value.absent(),
    this.xClientSecret = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.copyToLinkedin = const Value.absent(),
    this.copyToX = const Value.absent(),
    this.dbSchemaVersion = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? rowId,
    Expression<String>? linkedinAuthToken,
    Expression<String>? linkedinRefreshToken,
    Expression<String>? xAuthToken,
    Expression<String>? xRefreshToken,
    Expression<String>? geminiToken,
    Expression<int>? publishPerWeek,
    Expression<String>? genModel,
    Expression<String>? embedModel,
    Expression<String>? linkedinClientId,
    Expression<String>? linkedinClientSecret,
    Expression<String>? xClientId,
    Expression<String>? xClientSecret,
    Expression<String>? themeMode,
    Expression<bool>? copyToLinkedin,
    Expression<bool>? copyToX,
    Expression<int>? dbSchemaVersion,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (linkedinAuthToken != null) 'linkedin_auth_token': linkedinAuthToken,
      if (linkedinRefreshToken != null)
        'linkedin_refresh_token': linkedinRefreshToken,
      if (xAuthToken != null) 'x_auth_token': xAuthToken,
      if (xRefreshToken != null) 'x_refresh_token': xRefreshToken,
      if (geminiToken != null) 'gemini_token': geminiToken,
      if (publishPerWeek != null) 'publish_per_week': publishPerWeek,
      if (genModel != null) 'gen_model': genModel,
      if (embedModel != null) 'embed_model': embedModel,
      if (linkedinClientId != null) 'linkedin_client_id': linkedinClientId,
      if (linkedinClientSecret != null)
        'linkedin_client_secret': linkedinClientSecret,
      if (xClientId != null) 'x_client_id': xClientId,
      if (xClientSecret != null) 'x_client_secret': xClientSecret,
      if (themeMode != null) 'theme_mode': themeMode,
      if (copyToLinkedin != null) 'copy_to_linkedin': copyToLinkedin,
      if (copyToX != null) 'copy_to_x': copyToX,
      if (dbSchemaVersion != null) 'db_schema_version': dbSchemaVersion,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? rowId,
    Value<String?>? linkedinAuthToken,
    Value<String?>? linkedinRefreshToken,
    Value<String?>? xAuthToken,
    Value<String?>? xRefreshToken,
    Value<String?>? geminiToken,
    Value<int>? publishPerWeek,
    Value<String?>? genModel,
    Value<String?>? embedModel,
    Value<String?>? linkedinClientId,
    Value<String?>? linkedinClientSecret,
    Value<String?>? xClientId,
    Value<String?>? xClientSecret,
    Value<String>? themeMode,
    Value<bool>? copyToLinkedin,
    Value<bool>? copyToX,
    Value<int>? dbSchemaVersion,
  }) {
    return SettingsCompanion(
      rowId: rowId ?? this.rowId,
      linkedinAuthToken: linkedinAuthToken ?? this.linkedinAuthToken,
      linkedinRefreshToken: linkedinRefreshToken ?? this.linkedinRefreshToken,
      xAuthToken: xAuthToken ?? this.xAuthToken,
      xRefreshToken: xRefreshToken ?? this.xRefreshToken,
      geminiToken: geminiToken ?? this.geminiToken,
      publishPerWeek: publishPerWeek ?? this.publishPerWeek,
      genModel: genModel ?? this.genModel,
      embedModel: embedModel ?? this.embedModel,
      linkedinClientId: linkedinClientId ?? this.linkedinClientId,
      linkedinClientSecret: linkedinClientSecret ?? this.linkedinClientSecret,
      xClientId: xClientId ?? this.xClientId,
      xClientSecret: xClientSecret ?? this.xClientSecret,
      themeMode: themeMode ?? this.themeMode,
      copyToLinkedin: copyToLinkedin ?? this.copyToLinkedin,
      copyToX: copyToX ?? this.copyToX,
      dbSchemaVersion: dbSchemaVersion ?? this.dbSchemaVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (linkedinAuthToken.present) {
      map['linkedin_auth_token'] = Variable<String>(linkedinAuthToken.value);
    }
    if (linkedinRefreshToken.present) {
      map['linkedin_refresh_token'] = Variable<String>(
        linkedinRefreshToken.value,
      );
    }
    if (xAuthToken.present) {
      map['x_auth_token'] = Variable<String>(xAuthToken.value);
    }
    if (xRefreshToken.present) {
      map['x_refresh_token'] = Variable<String>(xRefreshToken.value);
    }
    if (geminiToken.present) {
      map['gemini_token'] = Variable<String>(geminiToken.value);
    }
    if (publishPerWeek.present) {
      map['publish_per_week'] = Variable<int>(publishPerWeek.value);
    }
    if (genModel.present) {
      map['gen_model'] = Variable<String>(genModel.value);
    }
    if (embedModel.present) {
      map['embed_model'] = Variable<String>(embedModel.value);
    }
    if (linkedinClientId.present) {
      map['linkedin_client_id'] = Variable<String>(linkedinClientId.value);
    }
    if (linkedinClientSecret.present) {
      map['linkedin_client_secret'] = Variable<String>(
        linkedinClientSecret.value,
      );
    }
    if (xClientId.present) {
      map['x_client_id'] = Variable<String>(xClientId.value);
    }
    if (xClientSecret.present) {
      map['x_client_secret'] = Variable<String>(xClientSecret.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (copyToLinkedin.present) {
      map['copy_to_linkedin'] = Variable<bool>(copyToLinkedin.value);
    }
    if (copyToX.present) {
      map['copy_to_x'] = Variable<bool>(copyToX.value);
    }
    if (dbSchemaVersion.present) {
      map['db_schema_version'] = Variable<int>(dbSchemaVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('linkedinAuthToken: $linkedinAuthToken, ')
          ..write('linkedinRefreshToken: $linkedinRefreshToken, ')
          ..write('xAuthToken: $xAuthToken, ')
          ..write('xRefreshToken: $xRefreshToken, ')
          ..write('geminiToken: $geminiToken, ')
          ..write('publishPerWeek: $publishPerWeek, ')
          ..write('genModel: $genModel, ')
          ..write('embedModel: $embedModel, ')
          ..write('linkedinClientId: $linkedinClientId, ')
          ..write('linkedinClientSecret: $linkedinClientSecret, ')
          ..write('xClientId: $xClientId, ')
          ..write('xClientSecret: $xClientSecret, ')
          ..write('themeMode: $themeMode, ')
          ..write('copyToLinkedin: $copyToLinkedin, ')
          ..write('copyToX: $copyToX, ')
          ..write('dbSchemaVersion: $dbSchemaVersion')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootFolderPathMeta = const VerificationMeta(
    'rootFolderPath',
  );
  @override
  late final GeneratedColumn<String> rootFolderPath = GeneratedColumn<String>(
    'root_folder_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, deviceName, rootFolderPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('root_folder_path')) {
      context.handle(
        _rootFolderPathMeta,
        rootFolderPath.isAcceptableOrUnknown(
          data['root_folder_path']!,
          _rootFolderPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootFolderPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      rootFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_folder_path'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String deviceId;
  final String deviceName;
  final String rootFolderPath;
  const Device({
    required this.deviceId,
    required this.deviceName,
    required this.rootFolderPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['device_name'] = Variable<String>(deviceName);
    map['root_folder_path'] = Variable<String>(rootFolderPath);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      deviceId: Value(deviceId),
      deviceName: Value(deviceName),
      rootFolderPath: Value(rootFolderPath),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      rootFolderPath: serializer.fromJson<String>(json['rootFolderPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String>(deviceName),
      'rootFolderPath': serializer.toJson<String>(rootFolderPath),
    };
  }

  Device copyWith({
    String? deviceId,
    String? deviceName,
    String? rootFolderPath,
  }) => Device(
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName ?? this.deviceName,
    rootFolderPath: rootFolderPath ?? this.rootFolderPath,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      rootFolderPath: data.rootFolderPath.present
          ? data.rootFolderPath.value
          : this.rootFolderPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('rootFolderPath: $rootFolderPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, deviceName, rootFolderPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.rootFolderPath == this.rootFolderPath);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> deviceId;
  final Value<String> deviceName;
  final Value<String> rootFolderPath;
  final Value<int> rowid;
  const DevicesCompanion({
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.rootFolderPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String deviceId,
    required String deviceName,
    required String rootFolderPath,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       deviceName = Value(deviceName),
       rootFolderPath = Value(rootFolderPath);
  static Insertable<Device> custom({
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<String>? rootFolderPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (rootFolderPath != null) 'root_folder_path': rootFolderPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? deviceName,
    Value<String>? rootFolderPath,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      rootFolderPath: rootFolderPath ?? this.rootFolderPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (rootFolderPath.present) {
      map['root_folder_path'] = Variable<String>(rootFolderPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('rootFolderPath: $rootFolderPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PublishesTable extends Publishes
    with TableInfo<$PublishesTable, Publishe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PublishesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedDateMeta = const VerificationMeta(
    'publishedDate',
  );
  @override
  late final GeneratedColumn<DateTime> publishedDate =
      GeneratedColumn<DateTime>(
        'published_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _platformsJsonMeta = const VerificationMeta(
    'platformsJson',
  );
  @override
  late final GeneratedColumn<String> platformsJson = GeneratedColumn<String>(
    'platforms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    postId,
    publishedDate,
    platformsJson,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'publishes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Publishe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('published_date')) {
      context.handle(
        _publishedDateMeta,
        publishedDate.isAcceptableOrUnknown(
          data['published_date']!,
          _publishedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedDateMeta);
    }
    if (data.containsKey('platforms_json')) {
      context.handle(
        _platformsJsonMeta,
        platformsJson.isAcceptableOrUnknown(
          data['platforms_json']!,
          _platformsJsonMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Publishe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Publishe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      publishedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_date'],
      )!,
      platformsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platforms_json'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $PublishesTable createAlias(String alias) {
    return $PublishesTable(attachedDatabase, alias);
  }
}

class Publishe extends DataClass implements Insertable<Publishe> {
  final String id;
  final String postId;
  final DateTime publishedDate;
  final String platformsJson;
  final String deviceId;
  const Publishe({
    required this.id,
    required this.postId,
    required this.publishedDate,
    required this.platformsJson,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_id'] = Variable<String>(postId);
    map['published_date'] = Variable<DateTime>(publishedDate);
    map['platforms_json'] = Variable<String>(platformsJson);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  PublishesCompanion toCompanion(bool nullToAbsent) {
    return PublishesCompanion(
      id: Value(id),
      postId: Value(postId),
      publishedDate: Value(publishedDate),
      platformsJson: Value(platformsJson),
      deviceId: Value(deviceId),
    );
  }

  factory Publishe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Publishe(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      publishedDate: serializer.fromJson<DateTime>(json['publishedDate']),
      platformsJson: serializer.fromJson<String>(json['platformsJson']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String>(postId),
      'publishedDate': serializer.toJson<DateTime>(publishedDate),
      'platformsJson': serializer.toJson<String>(platformsJson),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  Publishe copyWith({
    String? id,
    String? postId,
    DateTime? publishedDate,
    String? platformsJson,
    String? deviceId,
  }) => Publishe(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    publishedDate: publishedDate ?? this.publishedDate,
    platformsJson: platformsJson ?? this.platformsJson,
    deviceId: deviceId ?? this.deviceId,
  );
  Publishe copyWithCompanion(PublishesCompanion data) {
    return Publishe(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      publishedDate: data.publishedDate.present
          ? data.publishedDate.value
          : this.publishedDate,
      platformsJson: data.platformsJson.present
          ? data.platformsJson.value
          : this.platformsJson,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Publishe(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('platformsJson: $platformsJson, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, postId, publishedDate, platformsJson, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Publishe &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.publishedDate == this.publishedDate &&
          other.platformsJson == this.platformsJson &&
          other.deviceId == this.deviceId);
}

class PublishesCompanion extends UpdateCompanion<Publishe> {
  final Value<String> id;
  final Value<String> postId;
  final Value<DateTime> publishedDate;
  final Value<String> platformsJson;
  final Value<String> deviceId;
  final Value<int> rowid;
  const PublishesCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.platformsJson = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PublishesCompanion.insert({
    required String id,
    required String postId,
    required DateTime publishedDate,
    this.platformsJson = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       postId = Value(postId),
       publishedDate = Value(publishedDate),
       deviceId = Value(deviceId);
  static Insertable<Publishe> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<DateTime>? publishedDate,
    Expression<String>? platformsJson,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (publishedDate != null) 'published_date': publishedDate,
      if (platformsJson != null) 'platforms_json': platformsJson,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PublishesCompanion copyWith({
    Value<String>? id,
    Value<String>? postId,
    Value<DateTime>? publishedDate,
    Value<String>? platformsJson,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return PublishesCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      publishedDate: publishedDate ?? this.publishedDate,
      platformsJson: platformsJson ?? this.platformsJson,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (publishedDate.present) {
      map['published_date'] = Variable<DateTime>(publishedDate.value);
    }
    if (platformsJson.present) {
      map['platforms_json'] = Variable<String>(platformsJson.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PublishesCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('platformsJson: $platformsJson, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'created_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdDate,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['created_date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String description;
  final DateTime createdDate;
  final String status;
  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['created_date'] = Variable<DateTime>(createdDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      createdDate: Value(createdDate),
      status: Value(status),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'status': serializer.toJson<String>(status),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdDate,
    String? status,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdDate: createdDate ?? this.createdDate,
    status: status ?? this.status,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdDate: $createdDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdDate == this.createdDate &&
          other.status == this.status);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> createdDate;
  final Value<String> status;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdDate,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdDate = Value(createdDate);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdDate,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdDate != null) 'created_date': createdDate,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<DateTime>? createdDate,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<DateTime>(createdDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdDate: $createdDate, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrendingsTable extends Trendings
    with TableInfo<$TrendingsTable, Trending> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrendingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trendTopicsJsonMeta = const VerificationMeta(
    'trendTopicsJson',
  );
  @override
  late final GeneratedColumn<String> trendTopicsJson = GeneratedColumn<String>(
    'trend_topics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _categoryTopicsJsonMeta =
      const VerificationMeta('categoryTopicsJson');
  @override
  late final GeneratedColumn<String> categoryTopicsJson =
      GeneratedColumn<String>(
        'category_topics_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullEmbeddingJsonMeta = const VerificationMeta(
    'fullEmbeddingJson',
  );
  @override
  late final GeneratedColumn<String> fullEmbeddingJson =
      GeneratedColumn<String>(
        'full_embedding_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _eachEmbeddingJsonMeta = const VerificationMeta(
    'eachEmbeddingJson',
  );
  @override
  late final GeneratedColumn<String> eachEmbeddingJson =
      GeneratedColumn<String>(
        'each_embedding_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gemini'),
  );
  static const VerificationMeta _fetchErrorMeta = const VerificationMeta(
    'fetchError',
  );
  @override
  late final GeneratedColumn<String> fetchError = GeneratedColumn<String>(
    'fetch_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTrendingJsonMeta = const VerificationMeta(
    'rawTrendingJson',
  );
  @override
  late final GeneratedColumn<String> rawTrendingJson = GeneratedColumn<String>(
    'raw_trending_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trendTopicsJson,
    categoryTopicsJson,
    addedDate,
    fullEmbeddingJson,
    eachEmbeddingJson,
    platform,
    fetchError,
    rawTrendingJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trendings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trending> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trend_topics_json')) {
      context.handle(
        _trendTopicsJsonMeta,
        trendTopicsJson.isAcceptableOrUnknown(
          data['trend_topics_json']!,
          _trendTopicsJsonMeta,
        ),
      );
    }
    if (data.containsKey('category_topics_json')) {
      context.handle(
        _categoryTopicsJsonMeta,
        categoryTopicsJson.isAcceptableOrUnknown(
          data['category_topics_json']!,
          _categoryTopicsJsonMeta,
        ),
      );
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('full_embedding_json')) {
      context.handle(
        _fullEmbeddingJsonMeta,
        fullEmbeddingJson.isAcceptableOrUnknown(
          data['full_embedding_json']!,
          _fullEmbeddingJsonMeta,
        ),
      );
    }
    if (data.containsKey('each_embedding_json')) {
      context.handle(
        _eachEmbeddingJsonMeta,
        eachEmbeddingJson.isAcceptableOrUnknown(
          data['each_embedding_json']!,
          _eachEmbeddingJsonMeta,
        ),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('fetch_error')) {
      context.handle(
        _fetchErrorMeta,
        fetchError.isAcceptableOrUnknown(data['fetch_error']!, _fetchErrorMeta),
      );
    }
    if (data.containsKey('raw_trending_json')) {
      context.handle(
        _rawTrendingJsonMeta,
        rawTrendingJson.isAcceptableOrUnknown(
          data['raw_trending_json']!,
          _rawTrendingJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trending map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trending(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trendTopicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trend_topics_json'],
      )!,
      categoryTopicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_topics_json'],
      )!,
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_date'],
      )!,
      fullEmbeddingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_embedding_json'],
      )!,
      eachEmbeddingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}each_embedding_json'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      fetchError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fetch_error'],
      ),
      rawTrendingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_trending_json'],
      ),
    );
  }

  @override
  $TrendingsTable createAlias(String alias) {
    return $TrendingsTable(attachedDatabase, alias);
  }
}

class Trending extends DataClass implements Insertable<Trending> {
  final String id;
  final String trendTopicsJson;
  final String categoryTopicsJson;
  final DateTime addedDate;
  final String fullEmbeddingJson;
  final String eachEmbeddingJson;
  final String platform;
  final String? fetchError;
  final String? rawTrendingJson;
  const Trending({
    required this.id,
    required this.trendTopicsJson,
    required this.categoryTopicsJson,
    required this.addedDate,
    required this.fullEmbeddingJson,
    required this.eachEmbeddingJson,
    required this.platform,
    this.fetchError,
    this.rawTrendingJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trend_topics_json'] = Variable<String>(trendTopicsJson);
    map['category_topics_json'] = Variable<String>(categoryTopicsJson);
    map['added_date'] = Variable<DateTime>(addedDate);
    map['full_embedding_json'] = Variable<String>(fullEmbeddingJson);
    map['each_embedding_json'] = Variable<String>(eachEmbeddingJson);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || fetchError != null) {
      map['fetch_error'] = Variable<String>(fetchError);
    }
    if (!nullToAbsent || rawTrendingJson != null) {
      map['raw_trending_json'] = Variable<String>(rawTrendingJson);
    }
    return map;
  }

  TrendingsCompanion toCompanion(bool nullToAbsent) {
    return TrendingsCompanion(
      id: Value(id),
      trendTopicsJson: Value(trendTopicsJson),
      categoryTopicsJson: Value(categoryTopicsJson),
      addedDate: Value(addedDate),
      fullEmbeddingJson: Value(fullEmbeddingJson),
      eachEmbeddingJson: Value(eachEmbeddingJson),
      platform: Value(platform),
      fetchError: fetchError == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchError),
      rawTrendingJson: rawTrendingJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawTrendingJson),
    );
  }

  factory Trending.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trending(
      id: serializer.fromJson<String>(json['id']),
      trendTopicsJson: serializer.fromJson<String>(json['trendTopicsJson']),
      categoryTopicsJson: serializer.fromJson<String>(
        json['categoryTopicsJson'],
      ),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
      fullEmbeddingJson: serializer.fromJson<String>(json['fullEmbeddingJson']),
      eachEmbeddingJson: serializer.fromJson<String>(json['eachEmbeddingJson']),
      platform: serializer.fromJson<String>(json['platform']),
      fetchError: serializer.fromJson<String?>(json['fetchError']),
      rawTrendingJson: serializer.fromJson<String?>(json['rawTrendingJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trendTopicsJson': serializer.toJson<String>(trendTopicsJson),
      'categoryTopicsJson': serializer.toJson<String>(categoryTopicsJson),
      'addedDate': serializer.toJson<DateTime>(addedDate),
      'fullEmbeddingJson': serializer.toJson<String>(fullEmbeddingJson),
      'eachEmbeddingJson': serializer.toJson<String>(eachEmbeddingJson),
      'platform': serializer.toJson<String>(platform),
      'fetchError': serializer.toJson<String?>(fetchError),
      'rawTrendingJson': serializer.toJson<String?>(rawTrendingJson),
    };
  }

  Trending copyWith({
    String? id,
    String? trendTopicsJson,
    String? categoryTopicsJson,
    DateTime? addedDate,
    String? fullEmbeddingJson,
    String? eachEmbeddingJson,
    String? platform,
    Value<String?> fetchError = const Value.absent(),
    Value<String?> rawTrendingJson = const Value.absent(),
  }) => Trending(
    id: id ?? this.id,
    trendTopicsJson: trendTopicsJson ?? this.trendTopicsJson,
    categoryTopicsJson: categoryTopicsJson ?? this.categoryTopicsJson,
    addedDate: addedDate ?? this.addedDate,
    fullEmbeddingJson: fullEmbeddingJson ?? this.fullEmbeddingJson,
    eachEmbeddingJson: eachEmbeddingJson ?? this.eachEmbeddingJson,
    platform: platform ?? this.platform,
    fetchError: fetchError.present ? fetchError.value : this.fetchError,
    rawTrendingJson: rawTrendingJson.present
        ? rawTrendingJson.value
        : this.rawTrendingJson,
  );
  Trending copyWithCompanion(TrendingsCompanion data) {
    return Trending(
      id: data.id.present ? data.id.value : this.id,
      trendTopicsJson: data.trendTopicsJson.present
          ? data.trendTopicsJson.value
          : this.trendTopicsJson,
      categoryTopicsJson: data.categoryTopicsJson.present
          ? data.categoryTopicsJson.value
          : this.categoryTopicsJson,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      fullEmbeddingJson: data.fullEmbeddingJson.present
          ? data.fullEmbeddingJson.value
          : this.fullEmbeddingJson,
      eachEmbeddingJson: data.eachEmbeddingJson.present
          ? data.eachEmbeddingJson.value
          : this.eachEmbeddingJson,
      platform: data.platform.present ? data.platform.value : this.platform,
      fetchError: data.fetchError.present
          ? data.fetchError.value
          : this.fetchError,
      rawTrendingJson: data.rawTrendingJson.present
          ? data.rawTrendingJson.value
          : this.rawTrendingJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trending(')
          ..write('id: $id, ')
          ..write('trendTopicsJson: $trendTopicsJson, ')
          ..write('categoryTopicsJson: $categoryTopicsJson, ')
          ..write('addedDate: $addedDate, ')
          ..write('fullEmbeddingJson: $fullEmbeddingJson, ')
          ..write('eachEmbeddingJson: $eachEmbeddingJson, ')
          ..write('platform: $platform, ')
          ..write('fetchError: $fetchError, ')
          ..write('rawTrendingJson: $rawTrendingJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trendTopicsJson,
    categoryTopicsJson,
    addedDate,
    fullEmbeddingJson,
    eachEmbeddingJson,
    platform,
    fetchError,
    rawTrendingJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trending &&
          other.id == this.id &&
          other.trendTopicsJson == this.trendTopicsJson &&
          other.categoryTopicsJson == this.categoryTopicsJson &&
          other.addedDate == this.addedDate &&
          other.fullEmbeddingJson == this.fullEmbeddingJson &&
          other.eachEmbeddingJson == this.eachEmbeddingJson &&
          other.platform == this.platform &&
          other.fetchError == this.fetchError &&
          other.rawTrendingJson == this.rawTrendingJson);
}

class TrendingsCompanion extends UpdateCompanion<Trending> {
  final Value<String> id;
  final Value<String> trendTopicsJson;
  final Value<String> categoryTopicsJson;
  final Value<DateTime> addedDate;
  final Value<String> fullEmbeddingJson;
  final Value<String> eachEmbeddingJson;
  final Value<String> platform;
  final Value<String?> fetchError;
  final Value<String?> rawTrendingJson;
  final Value<int> rowid;
  const TrendingsCompanion({
    this.id = const Value.absent(),
    this.trendTopicsJson = const Value.absent(),
    this.categoryTopicsJson = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.fullEmbeddingJson = const Value.absent(),
    this.eachEmbeddingJson = const Value.absent(),
    this.platform = const Value.absent(),
    this.fetchError = const Value.absent(),
    this.rawTrendingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrendingsCompanion.insert({
    required String id,
    this.trendTopicsJson = const Value.absent(),
    this.categoryTopicsJson = const Value.absent(),
    required DateTime addedDate,
    this.fullEmbeddingJson = const Value.absent(),
    this.eachEmbeddingJson = const Value.absent(),
    this.platform = const Value.absent(),
    this.fetchError = const Value.absent(),
    this.rawTrendingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       addedDate = Value(addedDate);
  static Insertable<Trending> custom({
    Expression<String>? id,
    Expression<String>? trendTopicsJson,
    Expression<String>? categoryTopicsJson,
    Expression<DateTime>? addedDate,
    Expression<String>? fullEmbeddingJson,
    Expression<String>? eachEmbeddingJson,
    Expression<String>? platform,
    Expression<String>? fetchError,
    Expression<String>? rawTrendingJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trendTopicsJson != null) 'trend_topics_json': trendTopicsJson,
      if (categoryTopicsJson != null)
        'category_topics_json': categoryTopicsJson,
      if (addedDate != null) 'added_date': addedDate,
      if (fullEmbeddingJson != null) 'full_embedding_json': fullEmbeddingJson,
      if (eachEmbeddingJson != null) 'each_embedding_json': eachEmbeddingJson,
      if (platform != null) 'platform': platform,
      if (fetchError != null) 'fetch_error': fetchError,
      if (rawTrendingJson != null) 'raw_trending_json': rawTrendingJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrendingsCompanion copyWith({
    Value<String>? id,
    Value<String>? trendTopicsJson,
    Value<String>? categoryTopicsJson,
    Value<DateTime>? addedDate,
    Value<String>? fullEmbeddingJson,
    Value<String>? eachEmbeddingJson,
    Value<String>? platform,
    Value<String?>? fetchError,
    Value<String?>? rawTrendingJson,
    Value<int>? rowid,
  }) {
    return TrendingsCompanion(
      id: id ?? this.id,
      trendTopicsJson: trendTopicsJson ?? this.trendTopicsJson,
      categoryTopicsJson: categoryTopicsJson ?? this.categoryTopicsJson,
      addedDate: addedDate ?? this.addedDate,
      fullEmbeddingJson: fullEmbeddingJson ?? this.fullEmbeddingJson,
      eachEmbeddingJson: eachEmbeddingJson ?? this.eachEmbeddingJson,
      platform: platform ?? this.platform,
      fetchError: fetchError ?? this.fetchError,
      rawTrendingJson: rawTrendingJson ?? this.rawTrendingJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trendTopicsJson.present) {
      map['trend_topics_json'] = Variable<String>(trendTopicsJson.value);
    }
    if (categoryTopicsJson.present) {
      map['category_topics_json'] = Variable<String>(categoryTopicsJson.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (fullEmbeddingJson.present) {
      map['full_embedding_json'] = Variable<String>(fullEmbeddingJson.value);
    }
    if (eachEmbeddingJson.present) {
      map['each_embedding_json'] = Variable<String>(eachEmbeddingJson.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (fetchError.present) {
      map['fetch_error'] = Variable<String>(fetchError.value);
    }
    if (rawTrendingJson.present) {
      map['raw_trending_json'] = Variable<String>(rawTrendingJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrendingsCompanion(')
          ..write('id: $id, ')
          ..write('trendTopicsJson: $trendTopicsJson, ')
          ..write('categoryTopicsJson: $categoryTopicsJson, ')
          ..write('addedDate: $addedDate, ')
          ..write('fullEmbeddingJson: $fullEmbeddingJson, ')
          ..write('eachEmbeddingJson: $eachEmbeddingJson, ')
          ..write('platform: $platform, ')
          ..write('fetchError: $fetchError, ')
          ..write('rawTrendingJson: $rawTrendingJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PublishesTable publishes = $PublishesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TrendingsTable trendings = $TrendingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    posts,
    media,
    settings,
    devices,
    publishes,
    categories,
    trendings,
  ];
}

typedef $$PostsTableCreateCompanionBuilder =
    PostsCompanion Function({
      required String id,
      Value<String> dump,
      Value<String?> linkedinContent,
      Value<String?> twitterContent,
      Value<String?> embedding,
      Value<String?> categoryId,
      Value<String> linksJson,
      Value<String> postBaseTagsJson,
      Value<String> categoryBasePublishTagsJson,
      Value<String> trendsBasePublishTagsJson,
      Value<String> mediaIdsJson,
      Value<String> selectedPlatformsJson,
      Value<String> publishedPlatformsJson,
      Value<String> status,
      Value<bool> isEmbedded,
      Value<bool> isRemoved,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PostsTableUpdateCompanionBuilder =
    PostsCompanion Function({
      Value<String> id,
      Value<String> dump,
      Value<String?> linkedinContent,
      Value<String?> twitterContent,
      Value<String?> embedding,
      Value<String?> categoryId,
      Value<String> linksJson,
      Value<String> postBaseTagsJson,
      Value<String> categoryBasePublishTagsJson,
      Value<String> trendsBasePublishTagsJson,
      Value<String> mediaIdsJson,
      Value<String> selectedPlatformsJson,
      Value<String> publishedPlatformsJson,
      Value<String> status,
      Value<bool> isEmbedded,
      Value<bool> isRemoved,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dump => $composableBuilder(
    column: $table.dump,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinContent => $composableBuilder(
    column: $table.linkedinContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get twitterContent => $composableBuilder(
    column: $table.twitterContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linksJson => $composableBuilder(
    column: $table.linksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postBaseTagsJson => $composableBuilder(
    column: $table.postBaseTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryBasePublishTagsJson => $composableBuilder(
    column: $table.categoryBasePublishTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trendsBasePublishTagsJson => $composableBuilder(
    column: $table.trendsBasePublishTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaIdsJson => $composableBuilder(
    column: $table.mediaIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedPlatformsJson => $composableBuilder(
    column: $table.selectedPlatformsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedPlatformsJson => $composableBuilder(
    column: $table.publishedPlatformsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEmbedded => $composableBuilder(
    column: $table.isEmbedded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRemoved => $composableBuilder(
    column: $table.isRemoved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dump => $composableBuilder(
    column: $table.dump,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinContent => $composableBuilder(
    column: $table.linkedinContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get twitterContent => $composableBuilder(
    column: $table.twitterContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linksJson => $composableBuilder(
    column: $table.linksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postBaseTagsJson => $composableBuilder(
    column: $table.postBaseTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryBasePublishTagsJson => $composableBuilder(
    column: $table.categoryBasePublishTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trendsBasePublishTagsJson => $composableBuilder(
    column: $table.trendsBasePublishTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaIdsJson => $composableBuilder(
    column: $table.mediaIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedPlatformsJson => $composableBuilder(
    column: $table.selectedPlatformsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedPlatformsJson => $composableBuilder(
    column: $table.publishedPlatformsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEmbedded => $composableBuilder(
    column: $table.isEmbedded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRemoved => $composableBuilder(
    column: $table.isRemoved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dump =>
      $composableBuilder(column: $table.dump, builder: (column) => column);

  GeneratedColumn<String> get linkedinContent => $composableBuilder(
    column: $table.linkedinContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get twitterContent => $composableBuilder(
    column: $table.twitterContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linksJson =>
      $composableBuilder(column: $table.linksJson, builder: (column) => column);

  GeneratedColumn<String> get postBaseTagsJson => $composableBuilder(
    column: $table.postBaseTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryBasePublishTagsJson => $composableBuilder(
    column: $table.categoryBasePublishTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trendsBasePublishTagsJson => $composableBuilder(
    column: $table.trendsBasePublishTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaIdsJson => $composableBuilder(
    column: $table.mediaIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedPlatformsJson => $composableBuilder(
    column: $table.selectedPlatformsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publishedPlatformsJson => $composableBuilder(
    column: $table.publishedPlatformsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isEmbedded => $composableBuilder(
    column: $table.isEmbedded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRemoved =>
      $composableBuilder(column: $table.isRemoved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostsTable,
          Post,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (Post, BaseReferences<_$AppDatabase, $PostsTable, Post>),
          Post,
          PrefetchHooks Function()
        > {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dump = const Value.absent(),
                Value<String?> linkedinContent = const Value.absent(),
                Value<String?> twitterContent = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> linksJson = const Value.absent(),
                Value<String> postBaseTagsJson = const Value.absent(),
                Value<String> categoryBasePublishTagsJson =
                    const Value.absent(),
                Value<String> trendsBasePublishTagsJson = const Value.absent(),
                Value<String> mediaIdsJson = const Value.absent(),
                Value<String> selectedPlatformsJson = const Value.absent(),
                Value<String> publishedPlatformsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isEmbedded = const Value.absent(),
                Value<bool> isRemoved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                dump: dump,
                linkedinContent: linkedinContent,
                twitterContent: twitterContent,
                embedding: embedding,
                categoryId: categoryId,
                linksJson: linksJson,
                postBaseTagsJson: postBaseTagsJson,
                categoryBasePublishTagsJson: categoryBasePublishTagsJson,
                trendsBasePublishTagsJson: trendsBasePublishTagsJson,
                mediaIdsJson: mediaIdsJson,
                selectedPlatformsJson: selectedPlatformsJson,
                publishedPlatformsJson: publishedPlatformsJson,
                status: status,
                isEmbedded: isEmbedded,
                isRemoved: isRemoved,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> dump = const Value.absent(),
                Value<String?> linkedinContent = const Value.absent(),
                Value<String?> twitterContent = const Value.absent(),
                Value<String?> embedding = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> linksJson = const Value.absent(),
                Value<String> postBaseTagsJson = const Value.absent(),
                Value<String> categoryBasePublishTagsJson =
                    const Value.absent(),
                Value<String> trendsBasePublishTagsJson = const Value.absent(),
                Value<String> mediaIdsJson = const Value.absent(),
                Value<String> selectedPlatformsJson = const Value.absent(),
                Value<String> publishedPlatformsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isEmbedded = const Value.absent(),
                Value<bool> isRemoved = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                dump: dump,
                linkedinContent: linkedinContent,
                twitterContent: twitterContent,
                embedding: embedding,
                categoryId: categoryId,
                linksJson: linksJson,
                postBaseTagsJson: postBaseTagsJson,
                categoryBasePublishTagsJson: categoryBasePublishTagsJson,
                trendsBasePublishTagsJson: trendsBasePublishTagsJson,
                mediaIdsJson: mediaIdsJson,
                selectedPlatformsJson: selectedPlatformsJson,
                publishedPlatformsJson: publishedPlatformsJson,
                status: status,
                isEmbedded: isEmbedded,
                isRemoved: isRemoved,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostsTable,
      Post,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (Post, BaseReferences<_$AppDatabase, $PostsTable, Post>),
      Post,
      PrefetchHooks Function()
    >;
typedef $$MediaTableCreateCompanionBuilder =
    MediaCompanion Function({
      required String id,
      required String originalFilename,
      required String storedFilename,
      required DateTime addedDate,
      Value<int> rowid,
    });
typedef $$MediaTableUpdateCompanionBuilder =
    MediaCompanion Function({
      Value<String> id,
      Value<String> originalFilename,
      Value<String> storedFilename,
      Value<DateTime> addedDate,
      Value<int> rowid,
    });

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedFilename => $composableBuilder(
    column: $table.storedFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedFilename => $composableBuilder(
    column: $table.storedFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storedFilename => $composableBuilder(
    column: $table.storedFilename,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTable,
          MediaData,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
          MediaData,
          PrefetchHooks Function()
        > {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> originalFilename = const Value.absent(),
                Value<String> storedFilename = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion(
                id: id,
                originalFilename: originalFilename,
                storedFilename: storedFilename,
                addedDate: addedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String originalFilename,
                required String storedFilename,
                required DateTime addedDate,
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion.insert(
                id: id,
                originalFilename: originalFilename,
                storedFilename: storedFilename,
                addedDate: addedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTable,
      MediaData,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
      MediaData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> rowId,
      Value<String?> linkedinAuthToken,
      Value<String?> linkedinRefreshToken,
      Value<String?> xAuthToken,
      Value<String?> xRefreshToken,
      Value<String?> geminiToken,
      Value<int> publishPerWeek,
      Value<String?> genModel,
      Value<String?> embedModel,
      Value<String?> linkedinClientId,
      Value<String?> linkedinClientSecret,
      Value<String?> xClientId,
      Value<String?> xClientSecret,
      Value<String> themeMode,
      Value<bool> copyToLinkedin,
      Value<bool> copyToX,
      Value<int> dbSchemaVersion,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> rowId,
      Value<String?> linkedinAuthToken,
      Value<String?> linkedinRefreshToken,
      Value<String?> xAuthToken,
      Value<String?> xRefreshToken,
      Value<String?> geminiToken,
      Value<int> publishPerWeek,
      Value<String?> genModel,
      Value<String?> embedModel,
      Value<String?> linkedinClientId,
      Value<String?> linkedinClientSecret,
      Value<String?> xClientId,
      Value<String?> xClientSecret,
      Value<String> themeMode,
      Value<bool> copyToLinkedin,
      Value<bool> copyToX,
      Value<int> dbSchemaVersion,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinAuthToken => $composableBuilder(
    column: $table.linkedinAuthToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinRefreshToken => $composableBuilder(
    column: $table.linkedinRefreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xAuthToken => $composableBuilder(
    column: $table.xAuthToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xRefreshToken => $composableBuilder(
    column: $table.xRefreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geminiToken => $composableBuilder(
    column: $table.geminiToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishPerWeek => $composableBuilder(
    column: $table.publishPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genModel => $composableBuilder(
    column: $table.genModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedModel => $composableBuilder(
    column: $table.embedModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinClientId => $composableBuilder(
    column: $table.linkedinClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinClientSecret => $composableBuilder(
    column: $table.linkedinClientSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xClientId => $composableBuilder(
    column: $table.xClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xClientSecret => $composableBuilder(
    column: $table.xClientSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get copyToLinkedin => $composableBuilder(
    column: $table.copyToLinkedin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get copyToX => $composableBuilder(
    column: $table.copyToX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dbSchemaVersion => $composableBuilder(
    column: $table.dbSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinAuthToken => $composableBuilder(
    column: $table.linkedinAuthToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinRefreshToken => $composableBuilder(
    column: $table.linkedinRefreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xAuthToken => $composableBuilder(
    column: $table.xAuthToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xRefreshToken => $composableBuilder(
    column: $table.xRefreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geminiToken => $composableBuilder(
    column: $table.geminiToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishPerWeek => $composableBuilder(
    column: $table.publishPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genModel => $composableBuilder(
    column: $table.genModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedModel => $composableBuilder(
    column: $table.embedModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinClientId => $composableBuilder(
    column: $table.linkedinClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinClientSecret => $composableBuilder(
    column: $table.linkedinClientSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xClientId => $composableBuilder(
    column: $table.xClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xClientSecret => $composableBuilder(
    column: $table.xClientSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get copyToLinkedin => $composableBuilder(
    column: $table.copyToLinkedin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get copyToX => $composableBuilder(
    column: $table.copyToX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dbSchemaVersion => $composableBuilder(
    column: $table.dbSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get linkedinAuthToken => $composableBuilder(
    column: $table.linkedinAuthToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedinRefreshToken => $composableBuilder(
    column: $table.linkedinRefreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get xAuthToken => $composableBuilder(
    column: $table.xAuthToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get xRefreshToken => $composableBuilder(
    column: $table.xRefreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get geminiToken => $composableBuilder(
    column: $table.geminiToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get publishPerWeek => $composableBuilder(
    column: $table.publishPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genModel =>
      $composableBuilder(column: $table.genModel, builder: (column) => column);

  GeneratedColumn<String> get embedModel => $composableBuilder(
    column: $table.embedModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedinClientId => $composableBuilder(
    column: $table.linkedinClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedinClientSecret => $composableBuilder(
    column: $table.linkedinClientSecret,
    builder: (column) => column,
  );

  GeneratedColumn<String> get xClientId =>
      $composableBuilder(column: $table.xClientId, builder: (column) => column);

  GeneratedColumn<String> get xClientSecret => $composableBuilder(
    column: $table.xClientSecret,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get copyToLinkedin => $composableBuilder(
    column: $table.copyToLinkedin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get copyToX =>
      $composableBuilder(column: $table.copyToX, builder: (column) => column);

  GeneratedColumn<int> get dbSchemaVersion => $composableBuilder(
    column: $table.dbSchemaVersion,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String?> linkedinAuthToken = const Value.absent(),
                Value<String?> linkedinRefreshToken = const Value.absent(),
                Value<String?> xAuthToken = const Value.absent(),
                Value<String?> xRefreshToken = const Value.absent(),
                Value<String?> geminiToken = const Value.absent(),
                Value<int> publishPerWeek = const Value.absent(),
                Value<String?> genModel = const Value.absent(),
                Value<String?> embedModel = const Value.absent(),
                Value<String?> linkedinClientId = const Value.absent(),
                Value<String?> linkedinClientSecret = const Value.absent(),
                Value<String?> xClientId = const Value.absent(),
                Value<String?> xClientSecret = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> copyToLinkedin = const Value.absent(),
                Value<bool> copyToX = const Value.absent(),
                Value<int> dbSchemaVersion = const Value.absent(),
              }) => SettingsCompanion(
                rowId: rowId,
                linkedinAuthToken: linkedinAuthToken,
                linkedinRefreshToken: linkedinRefreshToken,
                xAuthToken: xAuthToken,
                xRefreshToken: xRefreshToken,
                geminiToken: geminiToken,
                publishPerWeek: publishPerWeek,
                genModel: genModel,
                embedModel: embedModel,
                linkedinClientId: linkedinClientId,
                linkedinClientSecret: linkedinClientSecret,
                xClientId: xClientId,
                xClientSecret: xClientSecret,
                themeMode: themeMode,
                copyToLinkedin: copyToLinkedin,
                copyToX: copyToX,
                dbSchemaVersion: dbSchemaVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String?> linkedinAuthToken = const Value.absent(),
                Value<String?> linkedinRefreshToken = const Value.absent(),
                Value<String?> xAuthToken = const Value.absent(),
                Value<String?> xRefreshToken = const Value.absent(),
                Value<String?> geminiToken = const Value.absent(),
                Value<int> publishPerWeek = const Value.absent(),
                Value<String?> genModel = const Value.absent(),
                Value<String?> embedModel = const Value.absent(),
                Value<String?> linkedinClientId = const Value.absent(),
                Value<String?> linkedinClientSecret = const Value.absent(),
                Value<String?> xClientId = const Value.absent(),
                Value<String?> xClientSecret = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> copyToLinkedin = const Value.absent(),
                Value<bool> copyToX = const Value.absent(),
                Value<int> dbSchemaVersion = const Value.absent(),
              }) => SettingsCompanion.insert(
                rowId: rowId,
                linkedinAuthToken: linkedinAuthToken,
                linkedinRefreshToken: linkedinRefreshToken,
                xAuthToken: xAuthToken,
                xRefreshToken: xRefreshToken,
                geminiToken: geminiToken,
                publishPerWeek: publishPerWeek,
                genModel: genModel,
                embedModel: embedModel,
                linkedinClientId: linkedinClientId,
                linkedinClientSecret: linkedinClientSecret,
                xClientId: xClientId,
                xClientSecret: xClientSecret,
                themeMode: themeMode,
                copyToLinkedin: copyToLinkedin,
                copyToX: copyToX,
                dbSchemaVersion: dbSchemaVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String deviceId,
      required String deviceName,
      required String rootFolderPath,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> deviceId,
      Value<String> deviceName,
      Value<String> rootFolderPath,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootFolderPath => $composableBuilder(
    column: $table.rootFolderPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootFolderPath => $composableBuilder(
    column: $table.rootFolderPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootFolderPath => $composableBuilder(
    column: $table.rootFolderPath,
    builder: (column) => column,
  );
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String> rootFolderPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                deviceId: deviceId,
                deviceName: deviceName,
                rootFolderPath: rootFolderPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String deviceName,
                required String rootFolderPath,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                deviceId: deviceId,
                deviceName: deviceName,
                rootFolderPath: rootFolderPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$PublishesTableCreateCompanionBuilder =
    PublishesCompanion Function({
      required String id,
      required String postId,
      required DateTime publishedDate,
      Value<String> platformsJson,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$PublishesTableUpdateCompanionBuilder =
    PublishesCompanion Function({
      Value<String> id,
      Value<String> postId,
      Value<DateTime> publishedDate,
      Value<String> platformsJson,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$PublishesTableFilterComposer
    extends Composer<_$AppDatabase, $PublishesTable> {
  $$PublishesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformsJson => $composableBuilder(
    column: $table.platformsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PublishesTableOrderingComposer
    extends Composer<_$AppDatabase, $PublishesTable> {
  $$PublishesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformsJson => $composableBuilder(
    column: $table.platformsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PublishesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PublishesTable> {
  $$PublishesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platformsJson => $composableBuilder(
    column: $table.platformsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$PublishesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PublishesTable,
          Publishe,
          $$PublishesTableFilterComposer,
          $$PublishesTableOrderingComposer,
          $$PublishesTableAnnotationComposer,
          $$PublishesTableCreateCompanionBuilder,
          $$PublishesTableUpdateCompanionBuilder,
          (Publishe, BaseReferences<_$AppDatabase, $PublishesTable, Publishe>),
          Publishe,
          PrefetchHooks Function()
        > {
  $$PublishesTableTableManager(_$AppDatabase db, $PublishesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PublishesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PublishesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PublishesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> postId = const Value.absent(),
                Value<DateTime> publishedDate = const Value.absent(),
                Value<String> platformsJson = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PublishesCompanion(
                id: id,
                postId: postId,
                publishedDate: publishedDate,
                platformsJson: platformsJson,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String postId,
                required DateTime publishedDate,
                Value<String> platformsJson = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => PublishesCompanion.insert(
                id: id,
                postId: postId,
                publishedDate: publishedDate,
                platformsJson: platformsJson,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PublishesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PublishesTable,
      Publishe,
      $$PublishesTableFilterComposer,
      $$PublishesTableOrderingComposer,
      $$PublishesTableAnnotationComposer,
      $$PublishesTableCreateCompanionBuilder,
      $$PublishesTableUpdateCompanionBuilder,
      (Publishe, BaseReferences<_$AppDatabase, $PublishesTable, Publishe>),
      Publishe,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      required DateTime createdDate,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<DateTime> createdDate,
      Value<String> status,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                description: description,
                createdDate: createdDate,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                required DateTime createdDate,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdDate: createdDate,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TrendingsTableCreateCompanionBuilder =
    TrendingsCompanion Function({
      required String id,
      Value<String> trendTopicsJson,
      Value<String> categoryTopicsJson,
      required DateTime addedDate,
      Value<String> fullEmbeddingJson,
      Value<String> eachEmbeddingJson,
      Value<String> platform,
      Value<String?> fetchError,
      Value<String?> rawTrendingJson,
      Value<int> rowid,
    });
typedef $$TrendingsTableUpdateCompanionBuilder =
    TrendingsCompanion Function({
      Value<String> id,
      Value<String> trendTopicsJson,
      Value<String> categoryTopicsJson,
      Value<DateTime> addedDate,
      Value<String> fullEmbeddingJson,
      Value<String> eachEmbeddingJson,
      Value<String> platform,
      Value<String?> fetchError,
      Value<String?> rawTrendingJson,
      Value<int> rowid,
    });

class $$TrendingsTableFilterComposer
    extends Composer<_$AppDatabase, $TrendingsTable> {
  $$TrendingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trendTopicsJson => $composableBuilder(
    column: $table.trendTopicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryTopicsJson => $composableBuilder(
    column: $table.categoryTopicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullEmbeddingJson => $composableBuilder(
    column: $table.fullEmbeddingJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eachEmbeddingJson => $composableBuilder(
    column: $table.eachEmbeddingJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fetchError => $composableBuilder(
    column: $table.fetchError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTrendingJson => $composableBuilder(
    column: $table.rawTrendingJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrendingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrendingsTable> {
  $$TrendingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trendTopicsJson => $composableBuilder(
    column: $table.trendTopicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryTopicsJson => $composableBuilder(
    column: $table.categoryTopicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullEmbeddingJson => $composableBuilder(
    column: $table.fullEmbeddingJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eachEmbeddingJson => $composableBuilder(
    column: $table.eachEmbeddingJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fetchError => $composableBuilder(
    column: $table.fetchError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTrendingJson => $composableBuilder(
    column: $table.rawTrendingJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrendingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrendingsTable> {
  $$TrendingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trendTopicsJson => $composableBuilder(
    column: $table.trendTopicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryTopicsJson => $composableBuilder(
    column: $table.categoryTopicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<String> get fullEmbeddingJson => $composableBuilder(
    column: $table.fullEmbeddingJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eachEmbeddingJson => $composableBuilder(
    column: $table.eachEmbeddingJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get fetchError => $composableBuilder(
    column: $table.fetchError,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawTrendingJson => $composableBuilder(
    column: $table.rawTrendingJson,
    builder: (column) => column,
  );
}

class $$TrendingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrendingsTable,
          Trending,
          $$TrendingsTableFilterComposer,
          $$TrendingsTableOrderingComposer,
          $$TrendingsTableAnnotationComposer,
          $$TrendingsTableCreateCompanionBuilder,
          $$TrendingsTableUpdateCompanionBuilder,
          (Trending, BaseReferences<_$AppDatabase, $TrendingsTable, Trending>),
          Trending,
          PrefetchHooks Function()
        > {
  $$TrendingsTableTableManager(_$AppDatabase db, $TrendingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrendingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrendingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrendingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trendTopicsJson = const Value.absent(),
                Value<String> categoryTopicsJson = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
                Value<String> fullEmbeddingJson = const Value.absent(),
                Value<String> eachEmbeddingJson = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> fetchError = const Value.absent(),
                Value<String?> rawTrendingJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrendingsCompanion(
                id: id,
                trendTopicsJson: trendTopicsJson,
                categoryTopicsJson: categoryTopicsJson,
                addedDate: addedDate,
                fullEmbeddingJson: fullEmbeddingJson,
                eachEmbeddingJson: eachEmbeddingJson,
                platform: platform,
                fetchError: fetchError,
                rawTrendingJson: rawTrendingJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> trendTopicsJson = const Value.absent(),
                Value<String> categoryTopicsJson = const Value.absent(),
                required DateTime addedDate,
                Value<String> fullEmbeddingJson = const Value.absent(),
                Value<String> eachEmbeddingJson = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> fetchError = const Value.absent(),
                Value<String?> rawTrendingJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrendingsCompanion.insert(
                id: id,
                trendTopicsJson: trendTopicsJson,
                categoryTopicsJson: categoryTopicsJson,
                addedDate: addedDate,
                fullEmbeddingJson: fullEmbeddingJson,
                eachEmbeddingJson: eachEmbeddingJson,
                platform: platform,
                fetchError: fetchError,
                rawTrendingJson: rawTrendingJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrendingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrendingsTable,
      Trending,
      $$TrendingsTableFilterComposer,
      $$TrendingsTableOrderingComposer,
      $$TrendingsTableAnnotationComposer,
      $$TrendingsTableCreateCompanionBuilder,
      $$TrendingsTableUpdateCompanionBuilder,
      (Trending, BaseReferences<_$AppDatabase, $TrendingsTable, Trending>),
      Trending,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PublishesTableTableManager get publishes =>
      $$PublishesTableTableManager(_db, _db.publishes);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TrendingsTableTableManager get trendings =>
      $$TrendingsTableTableManager(_db, _db.trendings);
}
