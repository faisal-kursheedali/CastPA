import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/application/providers/bootstrap_provider.dart';
import 'package:castpa/data/services/gemini_service.dart';
import 'package:castpa/data/services/oauth_service.dart';
import 'package:castpa/data/services/publish_service.dart';
import 'package:castpa/data/services/trending_service.dart';
import 'package:castpa/data/services/embedding_service.dart';
import 'package:castpa/data/services/media_file_service.dart';

final _mediaFolderPathProvider = FutureProvider<String>((ref) async {
  final config = ref.watch(bootstrapConfigProvider).valueOrNull;
  final syncFolder = config?.syncFolderPath ?? '';
  if (syncFolder.isEmpty) return '';
  final mediaDir = Directory(p.join(syncFolder, '.media'));
  await mediaDir.create(recursive: true);

  if (Platform.isAndroid) {
    await _migrateOldAndroidMedia(mediaDir.path);
  }

  return mediaDir.path;
});

Future<void> _migrateOldAndroidMedia(String newMediaPath) async {
  try {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final oldMediaDir = Directory(p.join(appDocsDir.path, '.media'));
    if (!oldMediaDir.existsSync()) return;
    final files = oldMediaDir.listSync().whereType<File>();
    for (final file in files) {
      final dest = File(p.join(newMediaPath, p.basename(file.path)));
      if (!dest.existsSync()) {
        await file.copy(dest.path);
      }
      await file.delete();
    }
    if (oldMediaDir.listSync().isEmpty) {
      await oldMediaDir.delete();
    }
  } catch (_) {}
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final settings = ref.watch(settingsNotifierProvider).valueOrNull;
  return GeminiService(settings?.geminiToken ?? '');
});

final oauthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

final publishServiceProvider = Provider<PublishService>((ref) {
  return PublishService();
});

final trendingServiceProvider = Provider<TrendingService>((ref) {
  return TrendingService(
    ref.watch(trendingRepositoryProvider),
    ref.watch(geminiServiceProvider),
    ref.watch(embeddingServiceProvider),
  );
});

// Runs once at app startup: checks if trending topics are from this week,
// fetches and stores fresh ones if not.
// Waits for settings to load first so the Gemini API key is available.
final trendingInitProvider = FutureProvider<void>((ref) async {
  final settings = await ref.read(settingsNotifierProvider.future);
  final service = ref.read(trendingServiceProvider);
  await service.getOrFetchCurrentWeek(trendFetchCount: settings.trendFetchCount);
});

final embeddingServiceProvider = Provider<EmbeddingService>((ref) {
  return EmbeddingService();
});

final mediaFileServiceProvider = Provider<MediaFileService>((ref) {
  final mediaFolder = ref.watch(_mediaFolderPathProvider).valueOrNull ?? '';
  return MediaFileService(mediaFolder);
});
