import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/data/services/bootstrap_service.dart';

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService();
});

final bootstrapConfigProvider = FutureProvider<BootstrapConfig>((ref) async {
  final service = ref.watch(bootstrapServiceProvider);
  return service.load();
});
