import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/app_settings.dart';
import 'package:castpa/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  @override
  Future<AppSettings> getSettings() async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.rowId.equals(1)))
        .getSingleOrNull();
    if (row == null) return const AppSettings();
    return AppSettings(
      linkedinAuthToken: row.linkedinAuthToken,
      linkedinRefreshToken: row.linkedinRefreshToken,
      linkedinClientId: row.linkedinClientId,
      linkedinClientSecret: row.linkedinClientSecret,
      xAuthToken: row.xAuthToken,
      xRefreshToken: row.xRefreshToken,
      xClientId: row.xClientId,
      xClientSecret: row.xClientSecret,
      geminiToken: row.geminiToken,
      publishPerWeek: row.publishPerWeek,
      genModel: row.genModel,
      embedModel: row.embedModel,
      themeMode: row.themeMode,
      copyToLinkedin: row.copyToLinkedin,
      copyToX: row.copyToX,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion(
      rowId: const Value(1),
      linkedinAuthToken: Value(settings.linkedinAuthToken),
      linkedinRefreshToken: Value(settings.linkedinRefreshToken),
      linkedinClientId: Value(settings.linkedinClientId),
      linkedinClientSecret: Value(settings.linkedinClientSecret),
      xAuthToken: Value(settings.xAuthToken),
      xRefreshToken: Value(settings.xRefreshToken),
      xClientId: Value(settings.xClientId),
      xClientSecret: Value(settings.xClientSecret),
      geminiToken: Value(settings.geminiToken),
      publishPerWeek: Value(settings.publishPerWeek),
      genModel: Value(settings.genModel),
      embedModel: Value(settings.embedModel),
      themeMode: Value(settings.themeMode),
      copyToLinkedin: Value(settings.copyToLinkedin),
      copyToX: Value(settings.copyToX),
    ));
  }
}
