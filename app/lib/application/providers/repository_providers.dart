import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/data/repositories/post_repository_impl.dart';
import 'package:castpa/data/repositories/category_repository_impl.dart';
import 'package:castpa/data/repositories/media_repository_impl.dart';
import 'package:castpa/data/repositories/settings_repository_impl.dart';
import 'package:castpa/data/repositories/device_repository_impl.dart';
import 'package:castpa/data/repositories/publish_repository_impl.dart';
import 'package:castpa/data/repositories/trending_repository_impl.dart';
import 'package:castpa/domain/repositories/post_repository.dart';
import 'package:castpa/domain/repositories/category_repository.dart';
import 'package:castpa/domain/repositories/media_repository.dart';
import 'package:castpa/domain/repositories/settings_repository.dart';
import 'package:castpa/domain/repositories/device_repository.dart';
import 'package:castpa/domain/repositories/publish_repository.dart';
import 'package:castpa/domain/entities/trending.dart';
import 'package:castpa/domain/repositories/trending_repository.dart';

final latestTrendingProvider = FutureProvider.autoDispose<Trending?>((ref) {
  return ref.watch(trendingRepositoryProvider).getMostRecent();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(databaseProvider));
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(ref.watch(databaseProvider));
});

final publishRepositoryProvider = Provider<PublishRepository>((ref) {
  return PublishRepositoryImpl(ref.watch(databaseProvider));
});

final trendingRepositoryProvider = Provider<TrendingRepository>((ref) {
  return TrendingRepositoryImpl(ref.watch(databaseProvider));
});
