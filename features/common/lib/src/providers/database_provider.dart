import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Provider for the app database
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Dispose the database when the provider is disposed
  ref.onDispose(() {
    database.close();
  });

  return database;
});
