import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:castpa/domain/entities/media_item.dart';

sealed class PickFileResult {}

class PickFileSuccess extends PickFileResult {
  final MediaItem item;
  PickFileSuccess(this.item);
}

class PickFileCancelled extends PickFileResult {}

class PickFilePermissionDenied extends PickFileResult {
  final bool isPermanentlyDenied;
  PickFilePermissionDenied({this.isPermanentlyDenied = false});
}

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

  Future<PickFileResult> pickAndSaveFile() async {
    if (Platform.isAndroid) {
      final granted = await Permission.manageExternalStorage.isGranted;
      if (!granted) {
        return PickFilePermissionDenied(isPermanentlyDenied: true);
      }
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [..._imageExtensions, ..._videoExtensions],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return PickFileCancelled();
    final file = result.files.first;
    final bytes = file.bytes;
    final MediaItem item;
    if (bytes == null) {
      if (file.path == null) return PickFileCancelled();
      item = await _saveFromPath(File(file.path!), file.name);
    } else {
      item = await _saveFromBytes(bytes, file.name);
    }
    return PickFileSuccess(item);
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
