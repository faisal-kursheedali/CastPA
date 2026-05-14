import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyBookmark = 'sync_folder_bookmark';
const _channel = MethodChannel('castpa/bookmark');

class MacosBookmarkService {
  /// Saves a security-scoped bookmark for [path] and persists the raw bytes.
  /// No-op on non-macOS platforms.
  Future<void> saveBookmark(String path) async {
    if (!Platform.isMacOS) return;
    final Uint8List data = await _channel.invokeMethod('saveBookmark', path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBookmark, String.fromCharCodes(data));
  }

  /// Resolves the stored bookmark and starts security-scoped access.
  /// Returns the resolved path, or null if no bookmark is stored or resolution fails.
  Future<String?> resolveAndStartAccess() async {
    if (!Platform.isMacOS) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBookmark);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = Uint8List.fromList(raw.codeUnits);
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'resolveBookmark',
        ByteData.sublistView(data),
      );
      if (result == null) return null;
      final path = result['path'] as String?;
      final isStale = result['isStale'] as bool? ?? false;
      if (isStale && path != null) {
        // Refresh bookmark data while we still have access.
        await saveBookmark(path);
      }
      return path;
    } catch (_) {
      return null;
    }
  }

  /// Stops security-scoped access for [path]. Call when the app no longer
  /// needs access (e.g. on folder change or app termination).
  Future<void> stopAccess(String path) async {
    if (!Platform.isMacOS) return;
    await _channel.invokeMethod('stopAccessing', path);
  }

  Future<void> clearBookmark() async {
    if (!Platform.isMacOS) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBookmark);
  }
}
