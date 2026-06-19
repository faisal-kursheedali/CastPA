import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/app.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/data/database/local_database.dart';
import 'package:castpa/data/services/bootstrap_service.dart';
import 'package:castpa/data/services/db_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = BootstrapService();
  final bootstrap = await service.load();

  // Open the DB directly from the sync folder when one is configured.
  // This makes the app a true vessel: every Drift write lands in castpa.db
  // immediately, and external writes to castpa.db are visible to Drift on
  // its next query (SQLite handles cross-connection visibility at the file level).
  final dbPath = await service.dbPath(syncFolderPath: bootstrap.syncFolderPath);

  final db = AppDatabase(dbPath);
  final localDb = LocalDatabase();

  await localDb
      .into(localDb.localDeviceInfo)
      .insertOnConflictUpdate(
        LocalDeviceInfoCompanion(
          deviceId: Value(bootstrap.deviceId),
          syncFolderPath: Value(bootstrap.syncFolderPath),
          localSchemaVersion: Value(db.schemaVersion),
          lastOpenedAt: Value(DateTime.now()),
        ),
      );

  // Create the provider container so we can wire DbSyncService to it.
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWith((ref) => db),
      localDatabaseProvider.overrideWithValue(localDb),
    ],
  );

  // Start the file watcher when a sync folder is configured.
  DbSyncService? syncService;
  if (bootstrap.hasSyncFolder) {
    syncService = DbSyncService(
      watchedDbPath: dbPath,
      onExternalChange: () {
        container.read(dbEpochProvider.notifier).state++;
      },
    );

    // Tell the sync service whenever this device writes to the DB.
    // Used to detect conflict risk: only backs up if we were recently active.
    db.tableUpdates().listen((_) => syncService!.notifyLocalWrite());

    syncService.start();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: _AppRoot(syncService: syncService),
    ),
  );
}

/// Wraps the app so [DbSyncService] is disposed when the widget tree tears down.
class _AppRoot extends StatefulWidget {
  const _AppRoot({this.syncService});
  final DbSyncService? syncService;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.syncService?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearShareFolder();
    }
  }

  void _clearShareFolder() {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final fileService = container.read(mediaFileServiceProvider);
      fileService.clearAndPrepareShareFolder();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => const AppBootstrap();
}
