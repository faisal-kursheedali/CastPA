enum Platform {
  linkedin,
  x;

  String get displayName {
    switch (this) {
      case Platform.linkedin:
        return 'LinkedIn';
      case Platform.x:
        return 'X';
    }
  }

  String get key => name;

  static Platform? fromKey(String key) {
    for (final p in Platform.values) {
      if (p.key == key) return p;
    }
    return null;
  }
}

enum PostStatus {
  draft,
  pending,
  partialPublished,
  published;

  String get key {
    switch (this) {
      case PostStatus.draft:
        return 'draft';
      case PostStatus.pending:
        return 'pending';
      case PostStatus.partialPublished:
        return 'partial_published';
      case PostStatus.published:
        return 'published';
    }
  }

  String get displayName {
    switch (this) {
      case PostStatus.draft:
        return 'Draft';
      case PostStatus.pending:
        return 'Pending';
      case PostStatus.partialPublished:
        return 'Partial Published';
      case PostStatus.published:
        return 'Published';
    }
  }

  static PostStatus fromKey(String key) {
    for (final s in PostStatus.values) {
      if (s.key == key) return s;
    }
    return PostStatus.draft;
  }
}

enum CategoryStatus {
  active,
  inactive;

  String get key => name;

  static CategoryStatus fromKey(String key) {
    for (final s in CategoryStatus.values) {
      if (s.key == key) return s;
    }
    return CategoryStatus.active;
  }
}
