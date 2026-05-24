import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Watches castpa.db for external changes (Drive sync, another device, etc.)
/// and fires [onExternalChange] so callers can refresh the UI.
///
/// A backup is created only when this device was recently writing to the DB
/// at the moment Drive pushes a new version in — i.e. a real conflict risk.
/// Idle syncs (you switched from Device B while A was dormant) are ignored.
///
/// Only the latest [maxBackups] meaningful backups are kept.
class DbSyncService {
  final VoidCallback onExternalChange;
  final String watchedDbPath;
  final int maxBackups;

  /// How long after the last local write we consider a conflict possible.
  final Duration _conflictWindow;

  StreamSubscription<FileSystemEvent>? _watchSub;
  Timer? _debounce;

  /// Updated by [notifyLocalWrite] every time this device writes to the DB.
  DateTime? _lastLocalWriteAt;

  DbSyncService({
    required this.onExternalChange,
    required this.watchedDbPath,
    this.maxBackups = 10,
    Duration conflictWindow = const Duration(minutes: 7),
  }) : _conflictWindow = conflictWindow;

  /// Call this whenever this device writes anything to the DB.
  /// Wired to db.tableUpdates() in main.dart.
  void notifyLocalWrite() {
    _lastLocalWriteAt = DateTime.now();
  }

  void start() {
    try {
      final dir = File(watchedDbPath).parent;
      _watchSub = dir
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create)
          .where((event) => event.path == watchedDbPath)
          .listen(_onExternalChange);
      debugPrint('[DbSyncService] Watching: $watchedDbPath');
    } catch (e) {
      debugPrint('[DbSyncService] Could not start file watcher: $e');
    }
  }

  void _onExternalChange(FileSystemEvent event) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final shouldBackup = _wasRecentlyActive();
      if (shouldBackup) {
        debugPrint('[DbSyncService] Conflict risk detected – creating backup');
        await _backup();
      } else {
        debugPrint('[DbSyncService] Idle sync – no backup needed');
      }
      onExternalChange();
    });
  }

  /// Returns true if this device wrote to the DB within the conflict window.
  bool _wasRecentlyActive() {
    if (_lastLocalWriteAt == null) return false;
    return DateTime.now().difference(_lastLocalWriteAt!) < _conflictWindow;
  }

  Future<void> _backup() async {
    try {
      final src = File(watchedDbPath);
      if (!src.existsSync()) return;

      final backupDir = Directory(p.join(src.parent.path, 'backups'));
      if (!backupDir.existsSync()) await backupDir.create(recursive: true);

      final now = DateTime.now();
      final stamp =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}-'
          '${now.minute.toString().padLeft(2, '0')}-'
          '${now.second.toString().padLeft(2, '0')}';
      final dest = p.join(backupDir.path, 'castpa_$stamp.db');

      await src.copy(dest);
      debugPrint('[DbSyncService] Backup saved: $dest');

      await _pruneBackups(backupDir);
    } catch (e) {
      debugPrint('[DbSyncService] Backup failed: $e');
    }
  }

  Future<void> _pruneBackups(Directory backupDir) async {
    try {
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) =>
              p.basename(f.path).startsWith('castpa_') &&
              f.path.endsWith('.db'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path)); // oldest first

      while (files.length > maxBackups) {
        final oldest = files.removeAt(0);
        await oldest.delete();
        debugPrint('[DbSyncService] Pruned old backup: ${oldest.path}');
      }
    } catch (e) {
      debugPrint('[DbSyncService] Prune failed: $e');
    }
  }

  void dispose() {
    _debounce?.cancel();
    _watchSub?.cancel();
    debugPrint('[DbSyncService] Disposed');
  }
}
