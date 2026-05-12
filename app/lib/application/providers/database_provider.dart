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
