import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

// Bump this when you need a data-level migration that must run once across all synced devices.
const int kDbLogicalVersion = 1;

// ─── Table definitions ───────────────────────────────────────────────────────

class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get dump => text().withDefault(const Constant(''))();
  TextColumn get linkedinContent => text().nullable()();
  TextColumn get twitterContent => text().nullable()();
  TextColumn get embedding => text().nullable()();
  TextColumn get postBaseTagsEmbedding => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get linksJson => text().withDefault(const Constant('[]'))();
  TextColumn get postBaseTagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get categoryBasePublishTagsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get trendsBasePublishTagsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get userAddedTrendTagsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get mediaIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get selectedPlatformsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get publishedPlatformsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  BoolColumn get isEmbedded => boolean().withDefault(const Constant(false))();
  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Media extends Table {
  TextColumn get id => text()();
  TextColumn get originalFilename => text()();
  TextColumn get storedFilename => text()();
  DateTimeColumn get addedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  IntColumn get rowId => integer().withDefault(const Constant(1))();
  TextColumn get linkedinAuthToken => text().nullable()();
  TextColumn get linkedinRefreshToken => text().nullable()();
  TextColumn get xAuthToken => text().nullable()();
  TextColumn get xRefreshToken => text().nullable()();
  TextColumn get geminiToken => text().nullable()();
  IntColumn get publishPerWeek => integer().withDefault(const Constant(3))();
  TextColumn get genModel => text().nullable()();
  TextColumn get embedModel => text().nullable()();
  TextColumn get linkedinClientId => text().nullable()();
  TextColumn get linkedinClientSecret => text().nullable()();
  TextColumn get xClientId => text().nullable()();
  TextColumn get xClientSecret => text().nullable()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get copyToLinkedin => boolean().withDefault(const Constant(false))();
  BoolColumn get copyToX => boolean().withDefault(const Constant(false))();
  IntColumn get trendFetchCount => integer().withDefault(const Constant(7))();
  IntColumn get trendTagsPerPost => integer().withDefault(const Constant(5))();
  TextColumn get postTagMode => text().withDefault(const Constant('range'))();
  IntColumn get postTagMin => integer().withDefault(const Constant(3))();
  IntColumn get postTagMax => integer().withDefault(const Constant(10))();
  IntColumn get postTagExact => integer().withDefault(const Constant(5))();
  // Tracks the logical schema version that has been applied to this DB file.
  // Synced across devices so migrations only run once regardless of which device opens it first.
  IntColumn get dbSchemaVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {rowId};
}

class Devices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text()();
  TextColumn get rootFolderPath => text()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class Publishes extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text()();
  DateTimeColumn get publishedDate => dateTime()();
  TextColumn get platformsJson => text().withDefault(const Constant('[]'))();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Trendings extends Table {
  TextColumn get id => text()();
  TextColumn get trendTopicsJson => text().withDefault(const Constant('[]'))();
  TextColumn get categoryTopicsJson =>
      text().withDefault(const Constant('[]'))();
  DateTimeColumn get addedDate => dateTime()();
  TextColumn get fullEmbeddingJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get eachEmbeddingJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get platform =>
      text().withDefault(const Constant('gemini'))();
  TextColumn get fetchError => text().nullable()();
  TextColumn get rawTrendingJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [Posts, Media, Settings, Devices, Publishes, Categories, Trendings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbPath) : super(_openConnection(dbPath));

  @override
  int get schemaVersion => 17;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Seed the logical version so a fresh DB doesn't re-run migrations.
      await _initLogicalVersion();
    },
    onUpgrade: (m, from, to) async {
      // Structural migrations — must run on every device that opens the file.
      // Using _safeAlter because a synced DB file may already have the column
      // even if its PRAGMA user_version is lower than expected.
      if (from < 2) {
        await _safeAlter(
          'ALTER TABLE posts ADD COLUMN is_embedded INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 3) {
        await _safeAlter(
          'ALTER TABLE posts ADD COLUMN is_removed INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 5) {
        await _safeAlter('ALTER TABLE settings ADD COLUMN gen_model TEXT');
        await _safeAlter('ALTER TABLE settings ADD COLUMN embed_model TEXT');
      }
      if (from < 6) {
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN db_schema_version INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 7) {
        await _safeAlter('ALTER TABLE settings ADD COLUMN linkedin_client_id TEXT');
        await _safeAlter('ALTER TABLE settings ADD COLUMN linkedin_client_secret TEXT');
        await _safeAlter('ALTER TABLE settings ADD COLUMN x_client_id TEXT');
        await _safeAlter('ALTER TABLE settings ADD COLUMN x_client_secret TEXT');
      }
      if (from < 8) {
        await _safeAlter(
          "ALTER TABLE settings ADD COLUMN theme_mode TEXT NOT NULL DEFAULT 'system'",
        );
      }
      if (from < 9) {
        await _safeAlter(
          "ALTER TABLE trendings ADD COLUMN platform TEXT NOT NULL DEFAULT 'gemini'",
        );
      }
      if (from < 10) {
        await _safeAlter(
          'ALTER TABLE trendings ADD COLUMN fetch_error TEXT',
        );
      }
      if (from < 11) {
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN copy_to_linkedin INTEGER NOT NULL DEFAULT 0',
        );
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN copy_to_x INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 12) {
        await _safeAlter(
          'ALTER TABLE trendings ADD COLUMN raw_trending_json TEXT',
        );
      }
      if (from < 13) {
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN trend_fetch_count INTEGER NOT NULL DEFAULT 7',
        );
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN trend_tags_per_post INTEGER NOT NULL DEFAULT 5',
        );
      }
      if (from < 14) {
        await _safeAlter(
          "ALTER TABLE settings ADD COLUMN post_tag_mode TEXT NOT NULL DEFAULT 'range'",
        );
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN post_tag_min INTEGER NOT NULL DEFAULT 3',
        );
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN post_tag_max INTEGER NOT NULL DEFAULT 10',
        );
      }
      if (from < 15) {
        await _safeAlter(
          'ALTER TABLE settings ADD COLUMN post_tag_exact INTEGER NOT NULL DEFAULT 5',
        );
      }
      if (from < 16) {
        await _safeAlter(
          'ALTER TABLE posts ADD COLUMN post_base_tags_embedding TEXT',
        );
      }
      if (from < 17) {
        await _safeAlter(
          "ALTER TABLE posts ADD COLUMN user_added_trend_tags_json TEXT NOT NULL DEFAULT '[]'",
        );
      }
    },
    beforeOpen: (details) async {
      // Logical migrations — run once across all synced devices based on the
      // version stored in the DB itself, not the device's PRAGMA user_version.
      await _runLogicalMigrations();
    },
  );

  // Ignores "duplicate column name" so synced DB files (which already have the
  // column) don't crash when PRAGMA user_version is behind the code version.
  Future<void> _safeAlter(String sql) async {
    try {
      await customStatement(sql);
    } on SqliteException catch (e) {
      if (!e.message.contains('duplicate column name')) rethrow;
    }
  }

  Future<void> _initLogicalVersion() async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(dbSchemaVersion: Value(kDbLogicalVersion)),
    );
  }

  Future<void> _runLogicalMigrations() async {
    final row = await (select(settings)..where((s) => s.rowId.equals(1)))
        .getSingleOrNull();
    final current = row?.dbSchemaVersion ?? 0;
    if (current >= kDbLogicalVersion) return;

    await transaction(() async {
      // Add logical migration blocks here as kDbLogicalVersion grows.
      // if (current < 1) { /* e.g. backfill data */ }

      await (update(settings)..where((s) => s.rowId.equals(1))).write(
        SettingsCompanion(dbSchemaVersion: Value(kDbLogicalVersion)),
      );
    });
  }
}

LazyDatabase _openConnection(String dbPath) {
  return LazyDatabase(() async {
    final file = File(dbPath);
    await file.parent.create(recursive: true);
    return NativeDatabase(file);
  });
}
