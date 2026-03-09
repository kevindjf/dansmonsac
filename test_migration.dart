// ignore_for_file: avoid_print

// Test script for Supabase-to-Drift migration (OBSOLETE)
//
// This script was used to verify migration from Supabase to local Drift database.
// It is no longer usable because MigrationService and AppDatabase.memory() have been
// removed as part of the local-first architecture migration.
//
// The migration has already been completed and is no longer needed.

void main() {
  print('This migration test script is obsolete.');
  print(
      'The Supabase-to-Drift migration has been completed and MigrationService was removed.');
  print(
      'All data is now stored locally using Drift (local-first architecture).');
}
