class MediaItem {
  final String id;
  final String originalFilename;
  final String storedFilename;
  final DateTime addedDate;

  const MediaItem({
    required this.id,
    required this.originalFilename,
    required this.storedFilename,
    required this.addedDate,
  });

  MediaItem copyWith({
    String? id,
    String? originalFilename,
    String? storedFilename,
    DateTime? addedDate,
  }) {
    return MediaItem(
      id: id ?? this.id,
      originalFilename: originalFilename ?? this.originalFilename,
      storedFilename: storedFilename ?? this.storedFilename,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
