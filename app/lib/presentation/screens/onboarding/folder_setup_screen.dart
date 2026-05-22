import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:castpa/application/providers/bootstrap_provider.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/data/services/android_storage_service.dart';
import 'package:castpa/domain/entities/device.dart' as domain;
import 'package:castpa/data/repositories/device_repository_impl.dart';

class FolderSetupScreen extends ConsumerStatefulWidget {
  const FolderSetupScreen({super.key});

  @override
  ConsumerState<FolderSetupScreen> createState() => _FolderSetupScreenState();
}

class _FolderSetupScreenState extends ConsumerState<FolderSetupScreen> {
  bool _loading = false;
  String? _error;
  String? _selectedPath;

  Future<void> _pickFolder() async {
    if (Platform.isAndroid) {
      final granted = await AndroidStorageService.requestAllFilesAccess();
      if (!granted) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Castpa needs "All files access" to read and write your sync folder. '
              'Please enable it in Settings → Apps → Castpa → Permissions → Files and media.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () { Navigator.pop(context); openAppSettings(); },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }
    }

    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Sync Folder',
    );
    if (result == null) return;

    // On Android, file_picker returns a SAF URI — convert to a real path.
    final path = Platform.isAndroid
        ? AndroidStorageService.safUriToPath(result)
        : result;

    if (path == null) {
      setState(() => _error = 'Could not resolve folder path. Try a different folder.');
      return;
    }

    setState(() => _selectedPath = path);
  }

  Future<void> _logDebugState(String tag) async {
    // ignore: avoid_print
    print('[$tag] ── DEBUG STATE ──────────────────────────────');

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    // ignore: avoid_print
    print('[$tag] SharedPreferences (${keys.length} keys):');
    for (final k in keys) {
      // ignore: avoid_print
      print('[$tag]   $k = ${prefs.get(k)}');
    }

    final devices = await ref.read(deviceRepositoryProvider).getAllDevices();
    // ignore: avoid_print
    print('[$tag] devices table (${devices.length} rows):');
    for (final d in devices) {
      // ignore: avoid_print
      print('[$tag]   id=${d.deviceId}  name=${d.deviceName}  path="${d.rootFolderPath}"');
    }

    // ignore: avoid_print
    print('[$tag] ─────────────────────────────────────────────');
  }

  Future<void> _confirm() async {
    if (_selectedPath == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ignore: avoid_print
      print('[FOLDER_SETUP] chosen path: $_selectedPath');
      await _logDebugState('FOLDER_SETUP:before');

      final bootstrapService = ref.read(bootstrapServiceProvider);
      final valid = await bootstrapService.validateSyncFolder(_selectedPath!);
      if (!valid) {
        setState(() {
          _error = 'Selected folder is not accessible.';
          _loading = false;
        });
        return;
      }

      final mediaExists = Directory(bootstrapService.mediaFolderPath(_selectedPath!)).existsSync();
      if (!mediaExists) await bootstrapService.ensureMediaFolder(_selectedPath!);

      // If the folder contains a castpa.db from another device/install, copy
      // it into app documents so it becomes the active DB. The DB always lives
      // in app documents to stay accessible under the macOS sandbox.
      final imported = await bootstrapService.importDbFromFolder(_selectedPath!);
      final dbPath = await bootstrapService.dbPath();

      if (imported) {
        // ignore: avoid_print
        print('[FOLDER_SETUP] castpa.db found in folder — importing it');
      } else {
        // ignore: avoid_print
        print('[FOLDER_SETUP] no castpa.db in folder — wiping old DB and starting fresh');
      }

      // Always close the current DB and swap in a new instance.
      // For fresh folders this deletes the old castpa.db so old data doesn't bleed through.
      await ref.read(databaseProvider).close();
      if (!imported) {
        final oldDb = File(dbPath);
        if (oldDb.existsSync()) await oldDb.delete();
      }
      ref.read(databaseProvider.notifier).state = AppDatabase(dbPath);

      await bootstrapService.saveSyncFolderPath(_selectedPath!);

      final config = await bootstrapService.load();
      final db = ref.read(databaseProvider);

      if (!imported) {
        // Fresh DB — register this device.
        final deviceRepo = DeviceRepositoryImpl(db);
        await deviceRepo.upsertDevice(
          domain.Device(
            deviceId: config.deviceId,
            deviceName: Platform.localHostname,
            rootFolderPath: _selectedPath!,
          ),
        );
      }

      // Invalidate all providers so they reload from the (possibly new) DB.
      ref.invalidate(bootstrapConfigProvider);
      ref.invalidate(settingsNotifierProvider);

      await _logDebugState('FOLDER_SETUP:after');

      if (mounted) context.go('/');
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Connect Sync Folder',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Castpa stores all your content in a folder you choose. Use iCloud Drive, Google Drive, or any synced folder to keep data accessible across devices.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                if (_selectedPath != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedPath!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _pickFolder,
                        icon: const Icon(Icons.folder_open),
                        label: Text(
                          _selectedPath == null
                              ? 'Choose Folder'
                              : 'Change Folder',
                        ),
                      ),
                    ),
                    if (_selectedPath != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _loading ? null : _confirm,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
