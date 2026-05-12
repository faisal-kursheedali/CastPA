import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/domain/entities/device.dart';

final _devicesProvider = FutureProvider.autoDispose<List<Device>>((ref) {
  return ref.watch(deviceRepositoryProvider).getAllDevices();
});

class DeviceInfoScreen extends ConsumerStatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  ConsumerState<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends ConsumerState<DeviceInfoScreen> {
  int _dbTapCount = 0;
  DateTime? _lastDbTap;

  void _onDbTap() {
    final now = DateTime.now();
    if (_lastDbTap != null && now.difference(_lastDbTap!) > const Duration(seconds: 3)) {
      _dbTapCount = 0;
    }
    _lastDbTap = now;
    _dbTapCount++;
    if (_dbTapCount >= 5) {
      _dbTapCount = 0;
      context.push('/db-inspector');
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(_devicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Device Info')),
      body: Column(
        children: [
          Expanded(
            child: devicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (devices) => devices.isEmpty
                  ? const Center(child: Text('No devices registered'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: devices.length,
                      itemBuilder: (ctx, i) {
                        final d = devices[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.deviceName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                _InfoRow('Device ID', d.deviceId),
                                _InfoRow('Folder', d.rootFolderPath),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: _onDbTap,
              child: Text(
                'CastPA.DB',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
