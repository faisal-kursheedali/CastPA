import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/device.dart' as domain;
import 'package:castpa/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final AppDatabase _db;

  DeviceRepositoryImpl(this._db);

  domain.Device _fromRow(Device row) {
    return domain.Device(
      deviceId: row.deviceId,
      deviceName: row.deviceName,
      rootFolderPath: row.rootFolderPath,
    );
  }

  @override
  Future<List<domain.Device>> getAllDevices() async {
    final rows = await _db.select(_db.devices).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<domain.Device?> getDeviceById(String id) async {
    final row = await (_db.select(_db.devices)
          ..where((t) => t.deviceId.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsertDevice(domain.Device device) async {
    await _db.into(_db.devices).insertOnConflictUpdate(DevicesCompanion(
      deviceId: Value(device.deviceId),
      deviceName: Value(device.deviceName),
      rootFolderPath: Value(device.rootFolderPath),
    ));
  }

}
