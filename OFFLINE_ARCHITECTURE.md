# Architecture Offline-First - DansMonSac

## 📋 Spécifications

### Besoins validés
✅ **Toutes les données disponibles offline** (cours, fournitures, calendrier, paramètres)
✅ **Local wins** - Le local est la source de vérité (mono-utilisateur, mono-appareil)
✅ **Drift** comme base de données locale (type-safe, reactive, SQLite)
✅ **Opérations idempotentes** avec UUID pour éviter les doublons
✅ **Sync multiple** : Au démarrage + Reconnexion réseau + Pull-to-refresh
✅ **Indicateur visuel** de l'état de synchronisation

---

## 🏗️ Architecture Complète

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Course Page  │  │ Supply Page  │  │ Calendar Page│         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                  │
│         └──────────────────┴──────────────────┘                 │
│                            │                                     │
│                 ┌──────────▼───────────┐                        │
│                 │  Sync Status Widget  │  [📶/⏳/✅/❌]        │
│                 └──────────────────────┘                        │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                    Repository Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CourseRepository (Interface)                            │  │
│  │  - fetchAll() : List<Course>                             │  │
│  │  - save(Course) : void                                   │  │
│  │  - delete(String id) : void                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│         Offline Repository Implementation (NOUVEAU)             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  OfflineCourseRepository implements CourseRepository     │  │
│  │                                                           │  │
│  │  fetchAll() {                                            │  │
│  │    1. Read from Local DB (always)                        │  │
│  │    2. Trigger background sync if online                  │  │
│  │    3. Return local data immediately                      │  │
│  │  }                                                        │  │
│  │                                                           │  │
│  │  save(course) {                                          │  │
│  │    1. Save to Local DB (immediate)                       │  │
│  │    2. Add to pending operations queue                    │  │
│  │    3. Attempt sync if online                             │  │
│  │  }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                ┌─────────┴──────────┐
                │                    │
                ▼                    ▼
┌───────────────────────┐  ┌─────────────────────────────────────┐
│   Local Database      │  │    Sync Manager (NOUVEAU)           │
│   (Drift)             │  │  ┌──────────────────────────────┐   │
│                       │  │  │  Pending Operations Queue    │   │
│ ┌─────────────────┐   │  │  │  - operation_id (UUID)       │   │
│ │ Courses Table   │   │  │  │  - type (CREATE/UPDATE/DEL)  │   │
│ │ - id (PK)       │   │  │  │  - entity_type (course/...)  │   │
│ │ - name          │   │  │  │  - entity_id                 │   │
│ │ - updated_at    │   │  │  │  - data (JSON)               │   │
│ │ - is_synced     │   │  │  │  - created_at                │   │
│ └─────────────────┘   │  │  │  - retry_count               │   │
│                       │  │  └──────────────────────────────┘   │
│ ┌─────────────────┐   │  │                                     │
│ │ Supplies Table  │   │  │  Network Detector                   │
│ │ - id            │   │  │  - connectivity_plus plugin         │
│ │ - course_id     │   │  │  - Stream<ConnectivityResult>       │
│ │ - name          │   │  └─────────────────────────────────────┘
│ │ - updated_at    │   │                    │
│ └─────────────────┘   │                    │
│                       │                    ▼
│ ┌─────────────────┐   │  ┌─────────────────────────────────────┐
│ │ Calendar Table  │   │  │   Remote Database (Supabase)        │
│ │ - id            │   │  │   - Courses                         │
│ │ - course_id     │   │  │   - Supplies                        │
│ │ - week_type     │   │  │   - Calendar                        │
│ │ - day_of_week   │   │  └─────────────────────────────────────┘
│ └─────────────────┘   │
└───────────────────────┘
```

---

## 📦 Structure Drift (Base de Données Locale)

### 1. Définition des Tables

```dart
// features/common/lib/src/database/app_database.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// ============= TABLES =============

@DataClassName('CourseEntity')
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SupplyEntity')
class Supplies extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().nullable()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CalendarCourseEntity')
class CalendarCourses extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get weekType => text()(); // 'A' or 'B'
  IntColumn get dayOfWeek => integer()(); // 1-7
  TextColumn get startTime => text()(); // "08:00"
  TextColumn get endTime => text()(); // "10:00"
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PendingOperationEntity')
class PendingOperations extends Table {
  TextColumn get operationId => text()();
  TextColumn get operationType => text()(); // 'CREATE', 'UPDATE', 'DELETE'
  TextColumn get entityType => text()(); // 'course', 'supply', 'calendar'
  TextColumn get entityId => text()();
  TextColumn get data => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {operationId};
}

// ============= DATABASE =============

@DriftDatabase(tables: [Courses, Supplies, CalendarCourses, PendingOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ============= MIGRATIONS =============

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // ============= COURSE QUERIES =============

  Future<List<CourseEntity>> getAllCourses() => select(courses).get();

  Future<CourseEntity?> getCourseById(String id) =>
      (select(courses)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertCourse(CoursesCompanion course) =>
      into(courses).insert(course);

  Future<bool> updateCourse(CoursesCompanion course) =>
      update(courses).replace(course);

  Future<int> deleteCourse(String id) =>
      (delete(courses)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> markCourseAsSynced(String id) {
    return (update(courses)..where((tbl) => tbl.id.equals(id)))
        .write(const CoursesCompanion(isSynced: Value(true)));
  }

  Stream<List<CourseEntity>> watchCourses() => select(courses).watch();

  // ============= SUPPLY QUERIES =============

  Future<List<SupplyEntity>> getAllSupplies() => select(supplies).get();

  Future<List<SupplyEntity>> getSuppliesByCourseId(String courseId) =>
      (select(supplies)..where((tbl) => tbl.courseId.equals(courseId))).get();

  Future<int> insertSupply(SuppliesCompanion supply) =>
      into(supplies).insert(supply);

  Future<bool> updateSupply(SuppliesCompanion supply) =>
      update(supplies).replace(supply);

  Future<int> deleteSupply(String id) =>
      (delete(supplies)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> markSupplyAsSynced(String id) {
    return (update(supplies)..where((tbl) => tbl.id.equals(id)))
        .write(const SuppliesCompanion(isSynced: Value(true)));
  }

  // ============= CALENDAR QUERIES =============

  Future<List<CalendarCourseEntity>> getAllCalendarCourses() =>
      select(calendarCourses).get();

  Future<List<CalendarCourseEntity>> getCalendarCoursesForDay(
    String weekType,
    int dayOfWeek,
  ) =>
      (select(calendarCourses)
            ..where((tbl) =>
                tbl.weekType.equals(weekType) & tbl.dayOfWeek.equals(dayOfWeek)))
          .get();

  Future<int> insertCalendarCourse(CalendarCoursesCompanion calendarCourse) =>
      into(calendarCourses).insert(calendarCourse);

  Future<bool> updateCalendarCourse(CalendarCoursesCompanion calendarCourse) =>
      update(calendarCourses).replace(calendarCourse);

  Future<int> deleteCalendarCourse(String id) =>
      (delete(calendarCourses)..where((tbl) => tbl.id.equals(id))).go();

  // ============= PENDING OPERATIONS QUERIES =============

  Future<List<PendingOperationEntity>> getAllPendingOperations() =>
      (select(pendingOperations)..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  Future<int> insertPendingOperation(PendingOperationsCompanion operation) =>
      into(pendingOperations).insert(operation);

  Future<int> deletePendingOperation(String operationId) =>
      (delete(pendingOperations)..where((tbl) => tbl.operationId.equals(operationId)))
          .go();

  Future<void> incrementRetryCount(String operationId) {
    return (update(pendingOperations)..where((tbl) => tbl.operationId.equals(operationId)))
        .write(PendingOperationsCompanion(
      retryCount: Value((select(pendingOperations)
                ..where((tbl) => tbl.operationId.equals(operationId)))
              .getSingle()
              .then((op) => op.retryCount + 1) as int),
    ));
  }
}

// ============= CONNECTION =============

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dansmonsac.sqlite'));
    return NativeDatabase(file);
  });
}
```

---

## 🔄 Sync Manager (Gestionnaire de Synchronisation)

### 2. Service de Synchronisation

```dart
// features/common/lib/src/sync/sync_manager.dart

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:common/src/database/app_database.dart';

enum SyncStatus {
  synced,       // ✅ Tout est synchronisé
  syncing,      // ⏳ Synchronisation en cours
  offline,      // 📡 Hors ligne, données non synchronisées
  error,        // ❌ Erreur lors de la synchronisation
}

class SyncManager {
  final AppDatabase _database;
  final Connectivity _connectivity;
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _uuid = const Uuid();

  SyncManager(this._database, this._connectivity) {
    _initNetworkListener();
  }

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus _currentStatus = SyncStatus.synced;
  SyncStatus get currentStatus => _currentStatus;

  // ============= NETWORK LISTENER =============

  void _initNetworkListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Reconnexion détectée
        print('🌐 Network reconnected. Starting sync...');
        syncPendingOperations();
      } else {
        _updateStatus(SyncStatus.offline);
      }
    });
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  // ============= ADD PENDING OPERATION =============

  Future<void> addPendingOperation({
    required String operationType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final operationId = _uuid.v4();

    await _database.insertPendingOperation(
      PendingOperationsCompanion.insert(
        operationId: operationId,
        operationType: operationType,
        entityType: entityType,
        entityId: entityId,
        data: jsonEncode(data),
      ),
    );

    print('📝 Pending operation added: $operationType $entityType ($entityId)');

    // Marquer comme non synchronisé
    _updateStatus(SyncStatus.offline);

    // Tenter la sync immédiatement si en ligne
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncPendingOperations();
    }
  }

  // ============= SYNC PENDING OPERATIONS =============

  Future<void> syncPendingOperations() async {
    // Vérifier la connexion
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('📡 No network. Skipping sync.');
      _updateStatus(SyncStatus.offline);
      return;
    }

    _updateStatus(SyncStatus.syncing);

    try {
      final pendingOps = await _database.getAllPendingOperations();

      if (pendingOps.isEmpty) {
        print('✅ No pending operations. Already synced.');
        _updateStatus(SyncStatus.synced);
        return;
      }

      print('🔄 Syncing ${pendingOps.length} pending operations...');

      for (final op in pendingOps) {
        try {
          await _executePendingOperation(op);
          await _database.deletePendingOperation(op.operationId);
          print('✅ Operation synced: ${op.operationId}');
        } catch (e) {
          print('❌ Failed to sync operation ${op.operationId}: $e');

          // Incrémenter le compteur de retry
          if (op.retryCount < 5) {
            await _database.incrementRetryCount(op.operationId);
          } else {
            // Après 5 tentatives, supprimer l'opération
            print('🗑️ Operation failed after 5 retries. Deleting: ${op.operationId}');
            await _database.deletePendingOperation(op.operationId);
          }
        }
      }

      // Vérifier s'il reste des opérations
      final remainingOps = await _database.getAllPendingOperations();
      if (remainingOps.isEmpty) {
        _updateStatus(SyncStatus.synced);
      } else {
        _updateStatus(SyncStatus.error);
      }
    } catch (e) {
      print('❌ Sync error: $e');
      _updateStatus(SyncStatus.error);
    }
  }

  // ============= EXECUTE PENDING OPERATION =============

  Future<void> _executePendingOperation(PendingOperationEntity op) async {
    final data = jsonDecode(op.data) as Map<String, dynamic>;

    switch (op.entityType) {
      case 'course':
        await _syncCourse(op.operationType, op.entityId, data);
        break;
      case 'supply':
        await _syncSupply(op.operationType, op.entityId, data);
        break;
      case 'calendar':
        await _syncCalendar(op.operationType, op.entityId, data);
        break;
      default:
        throw Exception('Unknown entity type: ${op.entityType}');
    }
  }

  // ============= SYNC COURSE =============

  Future<void> _syncCourse(String operationType, String entityId, Map<String, dynamic> data) async {
    // TODO: Appeler l'API Supabase selon l'opération
    switch (operationType) {
      case 'CREATE':
        // await supabaseClient.from('courses').insert(data);
        break;
      case 'UPDATE':
        // await supabaseClient.from('courses').update(data).eq('id', entityId);
        break;
      case 'DELETE':
        // await supabaseClient.from('courses').delete().eq('id', entityId);
        break;
    }

    // Marquer comme synchronisé dans la BDD locale
    await _database.markCourseAsSynced(entityId);
  }

  // ============= SYNC SUPPLY =============

  Future<void> _syncSupply(String operationType, String entityId, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        // await supabaseClient.from('supplies').insert(data);
        break;
      case 'UPDATE':
        // await supabaseClient.from('supplies').update(data).eq('id', entityId);
        break;
      case 'DELETE':
        // await supabaseClient.from('supplies').delete().eq('id', entityId);
        break;
    }

    await _database.markSupplyAsSynced(entityId);
  }

  // ============= SYNC CALENDAR =============

  Future<void> _syncCalendar(String operationType, String entityId, Map<String, dynamic> data) async {
    switch (operationType) {
      case 'CREATE':
        // await supabaseClient.from('calendar_courses').insert(data);
        break;
      case 'UPDATE':
        // await supabaseClient.from('calendar_courses').update(data).eq('id', entityId);
        break;
      case 'DELETE':
        // await supabaseClient.from('calendar_courses').delete().eq('id', entityId);
        break;
    }
  }

  // ============= FULL SYNC FROM SERVER =============

  Future<void> pullFromServer() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('📡 No network. Cannot pull from server.');
      return;
    }

    print('⬇️ Pulling data from server...');

    try {
      // TODO: Récupérer toutes les données du serveur
      // final courses = await supabaseClient.from('courses').select();
      // final supplies = await supabaseClient.from('supplies').select();
      // final calendarCourses = await supabaseClient.from('calendar_courses').select();

      // Sauvegarder en local
      // for (final course in courses) {
      //   await _database.insertCourse(...);
      // }

      print('✅ Pull completed.');
    } catch (e) {
      print('❌ Pull error: $e');
    }
  }

  // ============= DISPOSE =============

  void dispose() {
    _statusController.close();
  }
}
```

---

## 🗄️ Offline Repository Implementation

### 3. Repository Offline pour Courses

```dart
// features/course/lib/repository/offline_course_repository.dart

import 'package:course/models/cours_with_supplies.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/repository/course_repository.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/sync/sync_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

class OfflineCourseRepository implements CourseRepository {
  final AppDatabase _database;
  final SyncManager _syncManager;
  final _uuid = const Uuid();

  OfflineCourseRepository(this._database, this._syncManager);

  // ============= FETCH COURSES =============

  @override
  Future<Either<Failure, List<CourseWithSupplies>>> fetchCourses() async {
    try {
      // 1. Toujours lire depuis le local (offline-first)
      final courseEntities = await _database.getAllCourses();

      // 2. Convertir en modèle métier
      final courses = <CourseWithSupplies>[];
      for (final entity in courseEntities) {
        final supplies = await _database.getSuppliesByCourseId(entity.id);
        courses.add(CourseWithSupplies(
          id: entity.id,
          name: entity.name,
          supplies: supplies
              .map((s) => Supply(id: s.id, name: s.name))
              .toList(),
        ));
      }

      // 3. Déclencher la sync en arrière-plan (non bloquant)
      _syncManager.syncPendingOperations();

      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ============= STORE COURSE =============

  @override
  Future<Either<Failure, CourseWithSupplies>> store(AddCourseCommand command) async {
    try {
      final courseId = _uuid.v4();
      final now = DateTime.now();

      // 1. Sauvegarder en local immédiatement
      await _database.insertCourse(CoursesCompanion.insert(
        id: courseId,
        name: command.name,
        updatedAt: now,
        isSynced: const Value(false),
      ));

      // 2. Ajouter à la file d'attente de sync
      await _syncManager.addPendingOperation(
        operationType: 'CREATE',
        entityType: 'course',
        entityId: courseId,
        data: {
          'id': courseId,
          'name': command.name,
          'updated_at': now.toIso8601String(),
        },
      );

      // 3. Retourner le cours créé
      final course = CourseWithSupplies(
        id: courseId,
        name: command.name,
        supplies: [],
      );

      return Right(course);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ============= DELETE COURSE =============

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    try {
      // 1. Supprimer en local immédiatement
      await _database.deleteCourse(id);

      // 2. Ajouter à la file d'attente de sync
      await _syncManager.addPendingOperation(
        operationType: 'DELETE',
        entityType: 'course',
        entityId: id,
        data: {'id': id},
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## 🎨 Indicateur Visuel de Synchronisation

### 4. Widget Sync Status

```dart
// features/common/lib/src/widgets/sync_status_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/sync/sync_manager.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncManager = ref.watch(syncManagerProvider);

    return StreamBuilder<SyncStatus>(
      stream: syncManager.statusStream,
      initialData: syncManager.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.synced;

        return IconButton(
          icon: _getIcon(status),
          onPressed: () => _showSyncDialog(context, status, syncManager),
          tooltip: _getTooltip(status),
        );
      },
    );
  }

  Widget _getIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, color: Colors.red);
    }
  }

  String _getTooltip(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Données synchronisées';
      case SyncStatus.syncing:
        return 'Synchronisation en cours...';
      case SyncStatus.offline:
        return 'Hors ligne - Changements en attente';
      case SyncStatus.error:
        return 'Erreur de synchronisation';
    }
  }

  void _showSyncDialog(BuildContext context, SyncStatus status, SyncManager syncManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getIcon(status),
            const SizedBox(width: 12),
            Text(_getTitle(status)),
          ],
        ),
        content: Text(_getMessage(status)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (status != SyncStatus.syncing)
            FilledButton(
              onPressed: () {
                syncManager.syncPendingOperations();
                Navigator.pop(context);
              },
              child: const Text('Synchroniser'),
            ),
        ],
      ),
    );
  }

  String _getTitle(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Tout est synchronisé';
      case SyncStatus.syncing:
        return 'Synchronisation...';
      case SyncStatus.offline:
        return 'Mode hors ligne';
      case SyncStatus.error:
        return 'Erreur';
    }
  }

  String _getMessage(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Toutes vos données sont à jour et synchronisées avec le serveur.';
      case SyncStatus.syncing:
        return 'Synchronisation de vos changements en cours...';
      case SyncStatus.offline:
        return 'Vous êtes actuellement hors ligne. Vos modifications seront synchronisées dès que vous retrouverez une connexion.';
      case SyncStatus.error:
        return 'Une erreur est survenue lors de la synchronisation. Réessayez plus tard.';
    }
  }
}
```

---

## 📋 Plan d'Implémentation (Phase par Phase)

### **Phase 1 : Setup & Infrastructure (1-2 jours)**

#### Étape 1.1 : Ajouter les dépendances
```yaml
# pubspec.yaml
dependencies:
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3
  connectivity_plus: ^5.0.0
  uuid: ^4.0.0

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.0
```

#### Étape 1.2 : Créer la structure de base de données
- ✅ Créer `features/common/lib/src/database/app_database.dart`
- ✅ Définir toutes les tables (Courses, Supplies, CalendarCourses, PendingOperations)
- ✅ Générer le code : `flutter pub run build_runner build`

#### Étape 1.3 : Créer le SyncManager
- ✅ Créer `features/common/lib/src/sync/sync_manager.dart`
- ✅ Implémenter la détection réseau
- ✅ Implémenter la file d'attente d'opérations

---

### **Phase 2 : Refactoring Repositories (2-3 jours)**

#### Étape 2.1 : Course Repository
- ✅ Créer `OfflineCourseRepository`
- ✅ Implémenter `fetchCourses()` avec lecture locale
- ✅ Implémenter `store()` avec pending operations
- ✅ Implémenter `deleteCourse()` avec pending operations
- ✅ Remplacer l'ancien repository par le nouveau dans les providers

#### Étape 2.2 : Supply Repository
- ✅ Créer `OfflineSupplyRepository`
- ✅ Implémenter toutes les méthodes avec logique offline

#### Étape 2.3 : Calendar Repository
- ✅ Créer `OfflineCalendarRepository`
- ✅ Implémenter toutes les méthodes avec logique offline

---

### **Phase 3 : Synchronisation (2 jours)**

#### Étape 3.1 : Implémenter la sync vers Supabase
- ✅ Compléter `_syncCourse()` dans SyncManager
- ✅ Compléter `_syncSupply()` dans SyncManager
- ✅ Compléter `_syncCalendar()` dans SyncManager

#### Étape 3.2 : Implémenter le pull depuis Supabase
- ✅ Créer `pullFromServer()` pour télécharger toutes les données
- ✅ Gérer les timestamps pour éviter de tout re-télécharger

---

### **Phase 4 : UI & UX (1 jour)**

#### Étape 4.1 : Ajouter l'indicateur de sync
- ✅ Créer `SyncStatusIndicator` widget
- ✅ Ajouter dans l'AppBar de la HomePage

#### Étape 4.2 : Pull-to-refresh
- ✅ Ajouter `RefreshIndicator` sur les pages principales
- ✅ Déclencher `syncPendingOperations()` au refresh

---

### **Phase 5 : Tests & Polish (2 jours)**

#### Étape 5.1 : Tests
- ✅ Tester le mode offline complet
- ✅ Tester la reconnexion et la sync automatique
- ✅ Tester les opérations en attente

#### Étape 5.2 : Optimisations
- ✅ Ajouter des index sur les tables pour les performances
- ✅ Implémenter un système de cache pour réduire les requêtes

---

## 🚀 Migration des Données Existantes

### Script de Migration

```dart
// features/common/lib/src/database/migration_helper.dart

class MigrationHelper {
  final AppDatabase _localDb;
  final SupabaseClient _supabase;

  MigrationHelper(this._localDb, this._supabase);

  /// Télécharge toutes les données de Supabase et les sauvegarde en local
  Future<void> initialDataSync() async {
    print('🔄 Starting initial data sync...');

    try {
      // 1. Télécharger les cours
      final coursesResponse = await _supabase.from('courses').select();
      for (final courseData in coursesResponse) {
        await _localDb.insertCourse(CoursesCompanion.insert(
          id: courseData['id'],
          name: courseData['name'],
          updatedAt: DateTime.parse(courseData['updated_at']),
          isSynced: const Value(true),
        ));
      }

      // 2. Télécharger les fournitures
      final suppliesResponse = await _supabase.from('supplies').select();
      for (final supplyData in suppliesResponse) {
        await _localDb.insertSupply(SuppliesCompanion.insert(
          id: supplyData['id'],
          courseId: Value(supplyData['course_id']),
          name: supplyData['name'],
          updatedAt: DateTime.parse(supplyData['updated_at']),
          isSynced: const Value(true),
        ));
      }

      // 3. Télécharger le calendrier
      final calendarResponse = await _supabase.from('calendar_courses').select();
      for (final calendarData in calendarResponse) {
        await _localDb.insertCalendarCourse(CalendarCoursesCompanion.insert(
          id: calendarData['id'],
          courseId: calendarData['course_id'],
          weekType: calendarData['week_type'],
          dayOfWeek: calendarData['day_of_week'],
          startTime: calendarData['start_time'],
          endTime: calendarData['end_time'],
          updatedAt: DateTime.parse(calendarData['updated_at']),
          isSynced: const Value(true),
        ));
      }

      print('✅ Initial sync completed!');
    } catch (e) {
      print('❌ Initial sync error: $e');
      rethrow;
    }
  }
}
```

---

## 🎯 Résumé

### Ce qui sera implémenté :

✅ **Base de données locale Drift** avec toutes les tables
✅ **SyncManager** pour gérer les opérations en attente
✅ **Offline Repositories** pour toutes les entités
✅ **Détection réseau automatique** avec reconnexion
✅ **Indicateur visuel** de l'état de synchronisation
✅ **Pull-to-refresh** manuel
✅ **Local wins** - priorité au local pour les conflits
✅ **Opérations idempotentes** avec UUID

### Durée estimée : **8-10 jours**

### Avantages pour l'utilisateur :

🚀 **App utilisable sans connexion**
⚡ **UI ultra-rapide** (pas d'attente réseau)
🔄 **Sync transparente** en arrière-plan
📶 **Indicateur clair** du statut de sync
✅ **Pas de perte de données** même hors ligne

Veux-tu que je commence l'implémentation ? Par quelle phase veux-tu commencer ?
