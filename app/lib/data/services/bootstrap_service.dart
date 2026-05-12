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
