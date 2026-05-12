class Device {
  final String deviceId;
  final String deviceName;
  final String rootFolderPath;

  const Device({
    required this.deviceId,
    required this.deviceName,
    required this.rootFolderPath,
  });

  Device copyWith({
    String? deviceId,
    String? deviceName,
    String? rootFolderPath,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      rootFolderPath: rootFolderPath ?? this.rootFolderPath,
    );
  }
}
