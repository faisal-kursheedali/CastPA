import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  Future<BootstrapConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_keyDeviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    final syncFolderPath = prefs.getString(_keySyncFolderPath);
    return BootstrapConfig(deviceId: deviceId, syncFolderPath: syncFolderPath);
  }

  Future<void> saveSyncFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncFolderPath, path);
  }

  Future<void> clearSyncFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncFolderPath, '');
  }

  Future<bool> validateSyncFolder(String path) async {
    try {
      return Directory(path).existsSync();
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

  String? existingDbInFolder(String syncFolderPath) {
    final path = p.join(syncFolderPath, 'castpa.db');
    return File(path).existsSync() ? path : null;
  }

  /// Returns the path the app should open as its live database.
  ///
  /// When a sync folder is configured **and** accessible, the DB is opened
  /// directly from that folder so every Drift write lands in castpa.db
  /// immediately (no copy needed).  Falls back to the sandboxed app-documents
  /// path when no sync folder is set.
  Future<String> dbPath({String? syncFolderPath}) async {
    if (syncFolderPath != null && syncFolderPath.isNotEmpty) {
      final syncDb = p.join(syncFolderPath, 'castpa.db');
      // Prefer the sync-folder file if the directory is accessible.
      if (Directory(syncFolderPath).existsSync()) {
        return syncDb;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'castpa.db');
  }

  String mediaFolderPath(String syncFolderPath) => p.join(syncFolderPath, 'media');
}
