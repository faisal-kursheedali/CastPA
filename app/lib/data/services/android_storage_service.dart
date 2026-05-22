import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AndroidStorageService {
  /// Requests MANAGE_EXTERNAL_STORAGE (All Files Access).
  /// Returns true if granted.
  static Future<bool> requestAllFilesAccess() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  static Future<bool> get hasAllFilesAccess async {
    if (!Platform.isAndroid) return true;
    return Permission.manageExternalStorage.isGranted;
  }

  /// Converts a SAF URI (returned by file_picker on Android) to a real
  /// filesystem path usable with dart:io.
  ///
  /// Examples:
  ///   content://com.android.externalstorage.documents/tree/primary:Documents/castpa
  ///     → /storage/emulated/0/Documents/castpa
  ///   content://com.android.externalstorage.documents/tree/1A2B-3C4D:castpa
  ///     → /storage/1A2B-3C4D/castpa
  static String? safUriToPath(String uri) {
    if (!uri.startsWith('content://')) return uri; // already a real path

    try {
      final decoded = Uri.decodeComponent(uri);
      // Extract the part after /tree/
      final treePrefix = '/tree/';
      final treeIdx = decoded.indexOf(treePrefix);
      if (treeIdx == -1) return null;

      final treeId = decoded.substring(treeIdx + treePrefix.length);
      // Remove any /document/... suffix (present in document URIs)
      final docIdx = treeId.indexOf('/document/');
      final segment = docIdx == -1 ? treeId : treeId.substring(0, docIdx);

      final colonIdx = segment.indexOf(':');
      if (colonIdx == -1) return null;

      final authority = segment.substring(0, colonIdx);
      final relativePath = segment.substring(colonIdx + 1);

      if (authority == 'primary') {
        return '/storage/emulated/0${relativePath.isEmpty ? '' : '/$relativePath'}';
      } else {
        // External SD card: authority is the volume ID like "1A2B-3C4D"
        return '/storage/$authority${relativePath.isEmpty ? '' : '/$relativePath'}';
      }
    } catch (_) {
      return null;
    }
  }
}
