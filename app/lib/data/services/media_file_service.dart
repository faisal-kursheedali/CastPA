import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:castpa/domain/entities/media_item.dart';

class MediaFileService {
  static const _uuid = Uuid();

  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'};
  static const _videoExtensions = {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'};

  final String mediaFolderPath;

  MediaFileService(this.mediaFolderPath);

  static bool isImage(String filename) {
    final ext = p.extension(filename).replaceFirst('.', '').toLowerCase();
    return _imageExtensions.contains(ext);
  }

  static bool isVideo(String filename) {
    final ext = p.extension(filename).replaceFirst('.', '').toLowerCase();
    return _videoExtensions.contains(ext);
  }

  Future<MediaItem?> pickAndSaveFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [..._imageExtensions, ..._videoExtensions],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      // Fallback: direct path copy (desktop with full disk access)
      if (file.path == null) return null;
      return _saveFromPath(File(file.path!), file.name);
    }
    return _saveFromBytes(bytes, file.name);
  }

  Future<MediaItem> _saveFromBytes(List<int> bytes, String originalFilename) async {
    final ext = p.extension(originalFilename);
    final storedName = '${_uuid.v4()}$ext';
    final destPath = p.join(mediaFolderPath, storedName);
    await Directory(mediaFolderPath).create(recursive: true);
    await File(destPath).writeAsBytes(bytes);
    return MediaItem(
      id: _uuid.v4(),
      originalFilename: originalFilename,
      storedFilename: storedName,
      addedDate: DateTime.now(),
    );
  }

  Future<MediaItem> _saveFromPath(File sourceFile, String originalFilename) async {
    final ext = p.extension(originalFilename);
    final storedName = '${_uuid.v4()}$ext';
    final destPath = p.join(mediaFolderPath, storedName);
    await Directory(mediaFolderPath).create(recursive: true);
    await sourceFile.copy(destPath);
    return MediaItem(
      id: _uuid.v4(),
      originalFilename: originalFilename,
      storedFilename: storedName,
      addedDate: DateTime.now(),
    );
  }

  String getMediaFilePath(String storedFilename) =>
      p.join(mediaFolderPath, storedFilename);

  bool fileExists(String storedFilename) =>
      File(getMediaFilePath(storedFilename)).existsSync();
}
