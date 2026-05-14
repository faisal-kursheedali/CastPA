import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:castpa/data/services/macos_bookmark_service.dart';

const _keyDeviceId = 'device_id';
const _keySyncFolderPath = 'sync_folder_path';

class BootstrapConfig {
  final String deviceId;
  final String? syncFolderPath;

  const BootstrapConfig({required this.deviceId, this.syncFolderPath});

  bool get hasSyncFolder => syncFolderPath != null && syncFolderPath!.isNotEmpty;
}

class BootstrapService {
  static const _uuid = Uuid();
  final _bookmarkService = MacosBookmarkService();

  Future<BootstrapConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_keyDeviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    // On macOS, resolve the security-scoped bookmark to regain sandbox access.
    // Fall back to the stored plain path (works in debug / non-Mac).
    String? syncFolderPath;
    if (Platform.isMacOS) {
      syncFolderPath = await _bookmarkService.resolveAndStartAccess();
    }
    syncFolderPath ??= prefs.getString(_keySyncFolderPath);

    return BootstrapConfig(deviceId: deviceId, syncFolderPath: syncFolderPath);
  }

  Future<void> saveSyncFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncFolderPath, path);
    // On macOS, also persist a security-scoped bookmark for sandbox-safe access.
    await _bookmarkService.saveBookmark(path);
  }

  Future<void> clearSyncFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_keySyncFolderPath);
    if (current != null && current.isNotEmpty && Platform.isMacOS) {
      await _bookmarkService.stopAccess(current);
    }
    await prefs.setString(_keySyncFolderPath, '');
    await _bookmarkService.clearBookmark();
  }

  Future<bool> validateSyncFolder(String path) async {
    try {
      final dir = Directory(path);
      return dir.existsSync();
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureMediaFolder(String syncFolderPath) async {
    final mediaDir = Directory(p.join(syncFolderPath, 'media'));
    if (!mediaDir.existsSync()) {
      await mediaDir.create(recursive: true);
    }
  }

  /// Returns the path to castpa.db inside [syncFolderPath], if it exists.
  String? existingDbInFolder(String syncFolderPath) {
    final path = p.join(syncFolderPath, 'castpa.db');
    return File(path).existsSync() ? path : null;
  }

  /// Copies castpa.db from [syncFolderPath] into app documents (the canonical
  /// DB location). Returns true when a copy was performed.
  Future<bool> importDbFromFolder(String syncFolderPath) async {
    final src = existingDbInFolder(syncFolderPath);
    if (src == null) return false;
    final dest = await dbPath();
    await File(src).copy(dest);
    return true;
  }

  /// The canonical DB path — always in app documents so macOS sandbox never
  /// blocks access across restarts.
  Future<String> dbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'castpa.db');
  }
  String mediaFolderPath(String syncFolderPath) => p.join(syncFolderPath, 'media');
}
