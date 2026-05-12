import 'package:castpa/domain/entities/device.dart';

abstract interface class DeviceRepository {
  Future<List<Device>> getAllDevices();
  Future<Device?> getDeviceById(String id);
  Future<void> upsertDevice(Device device);
}
