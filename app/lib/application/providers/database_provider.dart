import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/data/database/local_database.dart';

// Overridden in main.dart with a real AppDatabase instance.
// StateProvider so FolderSetupScreen can swap the DB when a new folder is linked.
final databaseProvider = StateProvider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  throw UnimplementedError('localDatabaseProvider must be overridden in main()');
});

/// Incremented by [DbSyncService] whenever an external process writes to
/// castpa.db. Any provider that reads live data should watch this so it
/// rebuilds automatically when the file changes outside the app.
final dbEpochProvider = StateProvider<int>((ref) => 0);
