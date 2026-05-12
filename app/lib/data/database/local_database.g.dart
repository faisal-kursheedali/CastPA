// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalDeviceInfoTable extends LocalDeviceInfo
    with TableInfo<$LocalDeviceInfoTable, LocalDeviceInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDeviceInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncFolderPathMeta = const VerificationMeta(
    'syncFolderPath',
  );
  @override
  late final GeneratedColumn<String> syncFolderPath = GeneratedColumn<String>(
    'sync_folder_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localSchemaVersionMeta =
      const VerificationMeta('localSchemaVersion');
  @override
  late final GeneratedColumn<int> localSchemaVersion = GeneratedColumn<int>(
    'local_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    deviceName,
    syncFolderPath,
    localSchemaVersion,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_device_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDeviceInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('sync_folder_path')) {
      context.handle(
        _syncFolderPathMeta,
        syncFolderPath.isAcceptableOrUnknown(
          data['sync_folder_path']!,
          _syncFolderPathMeta,
        ),
      );
    }
    if (data.containsKey('local_schema_version')) {
      context.handle(
        _localSchemaVersionMeta,
        localSchemaVersion.isAcceptableOrUnknown(
          data['local_schema_version']!,
          _localSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  LocalDeviceInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDeviceInfoData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      syncFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_folder_path'],
      ),
      localSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_schema_version'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $LocalDeviceInfoTable createAlias(String alias) {
    return $LocalDeviceInfoTable(attachedDatabase, alias);
  }
}

class LocalDeviceInfoData extends DataClass
    implements Insertable<LocalDeviceInfoData> {
  final String deviceId;
  final String deviceName;
  final String? syncFolderPath;
  final int localSchemaVersion;
  final DateTime lastOpenedAt;
  const LocalDeviceInfoData({
    required this.deviceId,
    required this.deviceName,
    this.syncFolderPath,
    required this.localSchemaVersion,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['device_name'] = Variable<String>(deviceName);
    if (!nullToAbsent || syncFolderPath != null) {
      map['sync_folder_path'] = Variable<String>(syncFolderPath);
    }
    map['local_schema_version'] = Variable<int>(localSchemaVersion);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  LocalDeviceInfoCompanion toCompanion(bool nullToAbsent) {
    return LocalDeviceInfoCompanion(
      deviceId: Value(deviceId),
      deviceName: Value(deviceName),
      syncFolderPath: syncFolderPath == null && nullToAbsent
          ? const Value.absent()
          : Value(syncFolderPath),
      localSchemaVersion: Value(localSchemaVersion),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory LocalDeviceInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDeviceInfoData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      syncFolderPath: serializer.fromJson<String?>(json['syncFolderPath']),
      localSchemaVersion: serializer.fromJson<int>(json['localSchemaVersion']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String>(deviceName),
      'syncFolderPath': serializer.toJson<String?>(syncFolderPath),
      'localSchemaVersion': serializer.toJson<int>(localSchemaVersion),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  LocalDeviceInfoData copyWith({
    String? deviceId,
    String? deviceName,
    Value<String?> syncFolderPath = const Value.absent(),
    int? localSchemaVersion,
    DateTime? lastOpenedAt,
  }) => LocalDeviceInfoData(
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName ?? this.deviceName,
    syncFolderPath: syncFolderPath.present
        ? syncFolderPath.value
        : this.syncFolderPath,
    localSchemaVersion: localSchemaVersion ?? this.localSchemaVersion,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  LocalDeviceInfoData copyWithCompanion(LocalDeviceInfoCompanion data) {
    return LocalDeviceInfoData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      syncFolderPath: data.syncFolderPath.present
          ? data.syncFolderPath.value
          : this.syncFolderPath,
      localSchemaVersion: data.localSchemaVersion.present
          ? data.localSchemaVersion.value
          : this.localSchemaVersion,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDeviceInfoData(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('syncFolderPath: $syncFolderPath, ')
          ..write('localSchemaVersion: $localSchemaVersion, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    deviceName,
    syncFolderPath,
    localSchemaVersion,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDeviceInfoData &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.syncFolderPath == this.syncFolderPath &&
          other.localSchemaVersion == this.localSchemaVersion &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class LocalDeviceInfoCompanion extends UpdateCompanion<LocalDeviceInfoData> {
  final Value<String> deviceId;
  final Value<String> deviceName;
  final Value<String?> syncFolderPath;
  final Value<int> localSchemaVersion;
  final Value<DateTime> lastOpenedAt;
  final Value<int> rowid;
  const LocalDeviceInfoCompanion({
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.syncFolderPath = const Value.absent(),
    this.localSchemaVersion = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDeviceInfoCompanion.insert({
    required String deviceId,
    this.deviceName = const Value.absent(),
    this.syncFolderPath = const Value.absent(),
    this.localSchemaVersion = const Value.absent(),
    required DateTime lastOpenedAt,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<LocalDeviceInfoData> custom({
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<String>? syncFolderPath,
    Expression<int>? localSchemaVersion,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (syncFolderPath != null) 'sync_folder_path': syncFolderPath,
      if (localSchemaVersion != null)
        'local_schema_version': localSchemaVersion,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDeviceInfoCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? deviceName,
    Value<String?>? syncFolderPath,
    Value<int>? localSchemaVersion,
    Value<DateTime>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return LocalDeviceInfoCompanion(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      syncFolderPath: syncFolderPath ?? this.syncFolderPath,
      localSchemaVersion: localSchemaVersion ?? this.localSchemaVersion,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (syncFolderPath.present) {
      map['sync_folder_path'] = Variable<String>(syncFolderPath.value);
    }
    if (localSchemaVersion.present) {
      map['local_schema_version'] = Variable<int>(localSchemaVersion.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDeviceInfoCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('syncFolderPath: $syncFolderPath, ')
          ..write('localSchemaVersion: $localSchemaVersion, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalDeviceInfoTable localDeviceInfo = $LocalDeviceInfoTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localDeviceInfo];
}

typedef $$LocalDeviceInfoTableCreateCompanionBuilder =
    LocalDeviceInfoCompanion Function({
      required String deviceId,
      Value<String> deviceName,
      Value<String?> syncFolderPath,
      Value<int> localSchemaVersion,
      required DateTime lastOpenedAt,
      Value<int> rowid,
    });
typedef $$LocalDeviceInfoTableUpdateCompanionBuilder =
    LocalDeviceInfoCompanion Function({
      Value<String> deviceId,
      Value<String> deviceName,
      Value<String?> syncFolderPath,
      Value<int> localSchemaVersion,
      Value<DateTime> lastOpenedAt,
      Value<int> rowid,
    });

class $$LocalDeviceInfoTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalDeviceInfoTable> {
  $$LocalDeviceInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncFolderPath => $composableBuilder(
    column: $table.syncFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localSchemaVersion => $composableBuilder(
    column: $table.localSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDeviceInfoTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalDeviceInfoTable> {
  $$LocalDeviceInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncFolderPath => $composableBuilder(
    column: $table.syncFolderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSchemaVersion => $composableBuilder(
    column: $table.localSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDeviceInfoTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalDeviceInfoTable> {
  $$LocalDeviceInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncFolderPath => $composableBuilder(
    column: $table.syncFolderPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localSchemaVersion => $composableBuilder(
    column: $table.localSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );
}

class $$LocalDeviceInfoTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalDeviceInfoTable,
          LocalDeviceInfoData,
          $$LocalDeviceInfoTableFilterComposer,
          $$LocalDeviceInfoTableOrderingComposer,
          $$LocalDeviceInfoTableAnnotationComposer,
          $$LocalDeviceInfoTableCreateCompanionBuilder,
          $$LocalDeviceInfoTableUpdateCompanionBuilder,
          (
            LocalDeviceInfoData,
            BaseReferences<
              _$LocalDatabase,
              $LocalDeviceInfoTable,
              LocalDeviceInfoData
            >,
          ),
          LocalDeviceInfoData,
          PrefetchHooks Function()
        > {
  $$LocalDeviceInfoTableTableManager(
    _$LocalDatabase db,
    $LocalDeviceInfoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDeviceInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDeviceInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDeviceInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String?> syncFolderPath = const Value.absent(),
                Value<int> localSchemaVersion = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDeviceInfoCompanion(
                deviceId: deviceId,
                deviceName: deviceName,
                syncFolderPath: syncFolderPath,
                localSchemaVersion: localSchemaVersion,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<String> deviceName = const Value.absent(),
                Value<String?> syncFolderPath = const Value.absent(),
                Value<int> localSchemaVersion = const Value.absent(),
                required DateTime lastOpenedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalDeviceInfoCompanion.insert(
                deviceId: deviceId,
                deviceName: deviceName,
                syncFolderPath: syncFolderPath,
                localSchemaVersion: localSchemaVersion,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDeviceInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalDeviceInfoTable,
      LocalDeviceInfoData,
      $$LocalDeviceInfoTableFilterComposer,
      $$LocalDeviceInfoTableOrderingComposer,
      $$LocalDeviceInfoTableAnnotationComposer,
      $$LocalDeviceInfoTableCreateCompanionBuilder,
      $$LocalDeviceInfoTableUpdateCompanionBuilder,
      (
        LocalDeviceInfoData,
        BaseReferences<
          _$LocalDatabase,
          $LocalDeviceInfoTable,
          LocalDeviceInfoData
        >,
      ),
      LocalDeviceInfoData,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalDeviceInfoTableTableManager get localDeviceInfo =>
      $$LocalDeviceInfoTableTableManager(_db, _db.localDeviceInfo);
}
