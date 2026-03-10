// ignore_for_file: avoid_print

// Script to clean duplicate data from Drift database
//
// IMPORTANT: This script must be run from Flutter, not as a standalone Dart script
//
// To run this cleanup:
// 1. Option A - Add this code to main.dart temporarily before runApp():
//    ```dart
//    final database = ref.read(databaseProvider);
//    final result = await database.cleanDuplicates();
//    print('Cleaned: ${result['courses']} courses, ${result['supplies']} supplies, ${result['calendarCourses']} calendar courses');
//    ```
//
// 2. Option B - Add a button in settings page:
//    ```dart
//    ElevatedButton(
//      onPressed: () async {
//        final database = ref.read(databaseProvider);
//        final result = await database.cleanDuplicates();
//        ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(content: Text('Nettoyé: ${result['courses']} cours, ${result['supplies']} fournitures, ${result['calendarCourses']} séances')),
//        );
//      },
//      child: Text('Nettoyer les doublons'),
//    )
//    ```
//
// The cleanDuplicates() method is available in AppDatabase and will:
// - Remove duplicate courses (keeping oldest by createdAt)
// - Remove duplicate supplies (keeping oldest by createdAt)
// - Remove duplicate calendar courses (keeping oldest by createdAt)
// - Update all references to point to kept entries

void main() {
  print('''
🧹 NETTOYAGE DES DOUBLONS

Ce script ne peut pas être exécuté directement.
Utilisez l'une des méthodes suivantes:

OPTION 1 - Nettoyage au démarrage (temporaire):
Ajoutez ce code dans lib/main.dart après la création du ProviderScope:

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    // ... autres initialisations ...

    final container = ProviderContainer();
    final database = container.read(databaseProvider);
    final result = await database.cleanDuplicates();
    print('Nettoyé: \${result['courses']} cours, \${result['supplies']} fournitures, \${result['calendarCourses']} séances');

    runApp(ProviderScope(child: MyApp()));
  }

OPTION 2 - Bouton dans les paramètres:
Ajoutez un bouton dans features/main/lib/presentation/home/settings_page.dart:

  ElevatedButton(
    onPressed: () async {
      final database = ref.read(databaseProvider);
      final result = await database.cleanDuplicates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nettoyé: \${result['courses']} cours, '
              '\${result['supplies']} fournitures, '
              '\${result['calendarCourses']} séances'
            ),
          ),
        );
      }
    },
    child: const Text('🧹 Nettoyer les doublons'),
  )
''');
}
