import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

// Stores device-specific state that must NOT be synced across devices.
class LocalDeviceInfo extends Table {
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text().withDefault(const Constant(''))();
  TextColumn get syncFolderPath => text().nullable()();
  // The PRAGMA user_version this device last applied to the shared DB.
  IntColumn get localSchemaVersion => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastOpenedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

@DriftDatabase(tables: [LocalDeviceInfo])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'castpa_local.db'));
    await file.parent.create(recursive: true);
    return NativeDatabase(file);
  });
}
