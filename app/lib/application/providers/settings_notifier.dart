import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/domain/entities/app_settings.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    ref.watch(dbEpochProvider); // rebuild when external db change detected
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> save(AppSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).saveSettings(settings);
      return settings;
    });
  }

  Future<void> updateWith(AppSettings Function(AppSettings) updater) async {
    final current = state.valueOrNull ?? const AppSettings();
    await save(updater(current));
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
