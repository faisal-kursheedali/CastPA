import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/app.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/data/database/local_database.dart';
import 'package:castpa/data/services/bootstrap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = BootstrapService();
  final bootstrap = await service.load();
  // DB always lives in app documents so macOS sandbox never blocks it.
  final dbPath = await service.dbPath();
  // On every launch, sync state from castpa.db in the selected folder (if any).
  if (bootstrap.hasSyncFolder) {
    await service.importDbFromFolder(bootstrap.syncFolderPath!);
  }
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

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        localDatabaseProvider.overrideWithValue(localDb),
      ],
      child: const AppBootstrap(),
    ),
  );
}
