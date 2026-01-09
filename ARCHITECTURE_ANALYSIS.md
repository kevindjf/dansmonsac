# Analyse de l'Architecture - DansMonSac

## 📊 Vue d'ensemble

L'application DansMonSac suit une **architecture modulaire par features** avec des principes de Clean Architecture. Voici une analyse détaillée pour améliorer la testabilité et la maintenabilité.

---

## ✅ Points Forts (Ce qui est bien fait)

### 1. **Architecture Modulaire par Features** ⭐⭐⭐⭐⭐
```
features/
├── common/       # Code partagé
├── course/       # Gestion des cours
├── schedule/     # Calendrier et planning
├── supply/       # Fournitures
├── onboarding/   # Parcours d'accueil
├── main/         # Page d'accueil
└── splash/       # Écran de démarrage
```

**Avantages:**
- Chaque feature est indépendante et peut être développée/testée séparément
- Facilite le travail en équipe
- Réduit le couplage entre les modules
- Favorise la réutilisabilité

### 2. **Pattern Repository avec Interfaces** ⭐⭐⭐⭐⭐
```dart
// Interface abstraite
abstract class CourseRepository {
  Future<Either<Failure, CourseWithSupplies>> store(AddCourseCommand command);
  Future<Either<Failure, List<CourseWithSupplies>>> fetchCourses();
  Future<Either<Failure, void>> deleteCourse(String id);
}

// Implémentation Supabase
class CourseSupabaseRepository implements CourseRepository { }
```

**Avantages:**
- Séparation claire entre l'interface et l'implémentation
- Facile de créer des mocks pour les tests
- Permet de changer de source de données (Supabase → Firebase → Local DB)
- Suit le principe d'inversion de dépendances (SOLID)

### 3. **Gestion des Erreurs avec Either (dartz)** ⭐⭐⭐⭐
```dart
Future<Either<Failure, List<CourseWithSupplies>>> fetchCourses();
```

**Avantages:**
- Gestion explicite des erreurs
- Pas d'exceptions non gérées
- Force à traiter les cas d'erreur
- Type-safe error handling

### 4. **Injection de Dépendances avec Riverpod** ⭐⭐⭐⭐
```dart
@riverpod
class CoursesController extends _$CoursesController {
  late CourseRepository courseRepository;

  @override
  Future<CourseListState> build() async {
    courseRepository = ref.watch(courseRepositoryProvider);
    // ...
  }
}
```

**Avantages:**
- Dépendances injectées, pas de singletons hardcodés
- Testable avec des mocks
- Gestion automatique du cycle de vie

### 5. **Séparation Présentation/Logique** ⭐⭐⭐⭐
```
presentation/
├── list/
│   ├── controller/      # Logique métier
│   ├── widgets/         # Composants UI
│   └── list_page.dart   # Vue principale
```

**Avantages:**
- Controllers séparés des widgets
- Logique métier testable indépendamment de l'UI
- Réutilisabilité des widgets

---

## ⚠️ Points à Améliorer (Pour une meilleure testabilité)

### 1. **Services Statiques** 🔴 PRIORITÉ HAUTE

**Problème actuel:**
```dart
// PreferencesService.dart
class PreferencesService {
  static Future<void> setPackTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPackTimeHour, time.hour);
    // ...
  }
}

// NotificationService.dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async { }
}
```

**Pourquoi c'est problématique:**
- ❌ Impossible de mocker dans les tests
- ❌ Couplage fort avec les implémentations concrètes
- ❌ Pas de contrôle sur l'instance dans les tests
- ❌ Difficile de tester les controllers qui utilisent ces services

**Solution recommandée:**
```dart
// 1. Créer une interface abstraite
abstract class IPreferencesService {
  Future<void> setPackTime(TimeOfDay time);
  Future<TimeOfDay> getPackTime();
  Future<void> setSchoolYearStart(DateTime date);
  Future<DateTime> getSchoolYearStart();
  // ... autres méthodes
}

// 2. Implémenter avec SharedPreferences
class PreferencesService implements IPreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  @override
  Future<void> setPackTime(TimeOfDay time) async {
    await _prefs.setInt(_keyPackTimeHour, time.hour);
    await _prefs.setInt(_keyPackTimeMinute, time.minute);
  }

  // ... autres méthodes
}

// 3. Provider Riverpod
@riverpod
IPreferencesService preferencesService(PreferencesServiceRef ref) {
  // En production
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
}

// 4. Dans les tests - Mock facile
class MockPreferencesService extends Mock implements IPreferencesService {}

test('should save pack time', () async {
  final mockService = MockPreferencesService();
  when(() => mockService.setPackTime(any())).thenAnswer((_) async {});

  // Utiliser le mock dans le test
});
```

**Fichiers à refactoriser:**
- ✏️ `features/common/lib/src/services/preferences_service.dart`
- ✏️ `features/common/lib/src/services/notification_service.dart`

---

### 2. **Logique Métier dans les Controllers UI** 🟡 PRIORITÉ MOYENNE

**Problème actuel:**
```dart
// CoursesController.dart (lignes 53-70)
List<CourseItemUI> apiToUI(List<CourseWithSupplies> courses) {
  List<CourseItemUI> itemsUi = [];
  for (var course in courses) {
    List<SupplyItemUI> supplies = [];
    for (var supply in course.supplies) {
      supplies.add(SupplyItemUI(id: supply.id, name: supply.name));
    }
    itemsUi.add(CourseItemUI(
      id: course.id,
      title: course.name,
      supplies: supplies,
      isExpand: false
    ));
  }
  return itemsUi;
}
```

**Pourquoi c'est problématique:**
- ❌ Transformation de données mélangée avec la logique UI
- ❌ Difficile à tester cette logique de mapping
- ❌ Pas de réutilisabilité si on veut afficher les cours ailleurs

**Solution recommandée:**
```dart
// 1. Créer une couche Use Case / Domain Service
class CourseMapper {
  static List<CourseItemUI> toUIList(List<CourseWithSupplies> courses) {
    return courses.map((course) => toUI(course)).toList();
  }

  static CourseItemUI toUI(CourseWithSupplies course) {
    return CourseItemUI(
      id: course.id,
      title: course.name,
      supplies: course.supplies.map((s) => SupplyItemUI(
        id: s.id,
        name: s.name,
      )).toList(),
      isExpand: false,
    );
  }
}

// 2. Dans le controller
@override
Future<CourseListState> build() async {
  final response = await courseRepository.fetchCourses();

  return response.fold(
    (failure) => ErrorCourseListState(),
    (courses) {
      listCourses.addAll(courses);
      return DataCourseListState(CourseMapper.toUIList(courses));
    },
  );
}

// 3. Test facile
test('should map courses to UI models', () {
  final courses = [
    CourseWithSupplies(id: '1', name: 'Math', supplies: []),
  ];

  final result = CourseMapper.toUIList(courses);

  expect(result.length, 1);
  expect(result[0].title, 'Math');
});
```

---

### 3. **Absence de Use Cases / Interactors** 🟡 PRIORITÉ MOYENNE

**Problème actuel:**
Les controllers appellent directement les repositories et gèrent toute la logique métier.

**Architecture actuelle:**
```
UI Widget → Controller → Repository → Data Source
```

**Architecture recommandée (Clean Architecture):**
```
UI Widget → Controller → Use Case → Repository → Data Source
                           ↓
                      Domain Logic
```

**Solution recommandée:**
```dart
// 1. Créer un use case pour une opération métier
class GetCoursesForTomorrowUseCase {
  final CourseRepository _courseRepository;
  final CalendarRepository _calendarRepository;
  final IPreferencesService _preferences;

  GetCoursesForTomorrowUseCase(
    this._courseRepository,
    this._calendarRepository,
    this._preferences,
  );

  Future<Either<Failure, List<CourseWithSupplies>>> execute() async {
    // 1. Obtenir la date de demain
    final tomorrow = DateTime.now().add(Duration(days: 1));

    // 2. Déterminer si c'est semaine A ou B
    final schoolYearStart = await _preferences.getSchoolYearStart();
    final isWeekA = WeekUtils.isWeekA(tomorrow, schoolYearStart);

    // 3. Récupérer les cours du calendrier pour demain
    final calendarResult = await _calendarRepository.getCoursesForDate(
      tomorrow,
      isWeekA ? WeekType.A : WeekType.B,
    );

    return calendarResult.fold(
      (failure) => Left(failure),
      (calendarCourses) async {
        // 4. Enrichir avec les détails des cours
        final coursesResult = await _courseRepository.fetchCourses();
        return coursesResult.map((allCourses) {
          // Filtrer pour ne garder que les cours de demain
          return allCourses.where((course) =>
            calendarCourses.any((cc) => cc.courseId == course.id)
          ).toList();
        });
      },
    );
  }
}

// 2. Provider
@riverpod
GetCoursesForTomorrowUseCase getCoursesForTomorrowUseCase(
  GetCoursesForTomorrowUseCaseRef ref,
) {
  return GetCoursesForTomorrowUseCase(
    ref.watch(courseRepositoryProvider),
    ref.watch(calendarRepositoryProvider),
    ref.watch(preferencesServiceProvider),
  );
}

// 3. Dans le controller
@override
Future<SupplyListState> build() async {
  final result = await ref.read(getCoursesForTomorrowUseCaseProvider).execute();

  return result.fold(
    (failure) => ErrorState(),
    (courses) => SuccessState(courses),
  );
}

// 4. Test du use case (indépendant de Riverpod et Flutter)
test('should return courses for tomorrow', () async {
  final mockCourseRepo = MockCourseRepository();
  final mockCalendarRepo = MockCalendarRepository();
  final mockPreferences = MockPreferencesService();

  final useCase = GetCoursesForTomorrowUseCase(
    mockCourseRepo,
    mockCalendarRepo,
    mockPreferences,
  );

  // Setup mocks
  when(() => mockPreferences.getSchoolYearStart())
      .thenAnswer((_) async => DateTime(2024, 9, 2));

  // Execute
  final result = await useCase.execute();

  // Verify
  expect(result.isRight(), true);
});
```

**Avantages des Use Cases:**
- ✅ Logique métier pure, testable sans Flutter
- ✅ Réutilisable dans plusieurs controllers
- ✅ Respecte le Single Responsibility Principle
- ✅ Facilite les tests avec des mocks

---

### 4. **État Mutable dans les Controllers** 🟡 PRIORITÉ MOYENNE

**Problème actuel:**
```dart
@riverpod
class CoursesController extends _$CoursesController {
  final List<CourseWithSupplies> listCourses = []; // ❌ État mutable

  @override
  Future<CourseListState> build() async {
    listCourses.addAll(courses); // ❌ Mutation directe
    return DataCourseListState(apiToUI(courses));
  }

  void addSupply(int index, Supply? supply) {
    listCourses[index] = updatedCourse; // ❌ Mutation
  }
}
```

**Pourquoi c'est problématique:**
- ❌ État mutable = bugs difficiles à déboguer
- ❌ Pas thread-safe
- ❌ Difficile de prédire l'état à un moment donné
- ❌ Les tests peuvent avoir des effets de bord

**Solution recommandée:**
```dart
@riverpod
class CoursesController extends _$CoursesController {
  // ✅ Pas d'état mutable, tout dans le state Riverpod

  @override
  Future<CourseListState> build() async {
    final response = await courseRepository.fetchCourses();

    return response.fold(
      (failure) => ErrorCourseListState(),
      (courses) => DataCourseListState(
        courses: courses, // ✅ Immutable
        uiItems: CourseMapper.toUIList(courses),
      ),
    );
  }

  void addSupply(int index, Supply? supply) {
    state.whenData((currentState) {
      if (currentState is DataCourseListState) {
        // ✅ Créer une nouvelle liste au lieu de muter
        final updatedCourses = List<CourseWithSupplies>.from(
          currentState.courses
        );
        updatedCourses[index] = updatedCourses[index].copyWith(
          supplies: [...updatedCourses[index].supplies, supply],
        );

        state = AsyncValue.data(DataCourseListState(
          courses: updatedCourses,
          uiItems: CourseMapper.toUIList(updatedCourses),
        ));
      }
    });
  }
}
```

---

### 5. **Manque de Tests** 🔴 PRIORITÉ HAUTE

**État actuel:**
```
✅ test/widget_test.dart (test basique)
✅ features/onboarding/test/onboarding_test.dart (test modèle)
✅ features/schedule/test/schedule_test.dart
```

**Couverture manquante:**
- ❌ Repositories
- ❌ Controllers/Use Cases
- ❌ Services
- ❌ Mappers/Transformations
- ❌ Tests d'intégration

**Plan de test recommandé:**

#### A. Tests Unitaires (rapides, nombreux)
```dart
// 1. Repository Tests
test('CourseRepository should fetch courses from Supabase', () async {
  final mockClient = MockSupabaseClient();
  final repository = CourseSupabaseRepository(mockClient);

  when(() => mockClient.from('courses').select())
      .thenAnswer((_) async => [{'id': '1', 'name': 'Math'}]);

  final result = await repository.fetchCourses();

  expect(result.isRight(), true);
  verify(() => mockClient.from('courses').select()).called(1);
});

// 2. Use Case Tests
test('GetCoursesForTomorrowUseCase should return correct courses', () async {
  // ... (exemple plus haut)
});

// 3. Mapper Tests
test('CourseMapper should convert domain to UI model', () {
  final course = CourseWithSupplies(id: '1', name: 'Math', supplies: []);

  final result = CourseMapper.toUI(course);

  expect(result.id, '1');
  expect(result.title, 'Math');
});

// 4. Service Tests
test('PreferencesService should save and retrieve pack time', () async {
  final mockPrefs = MockSharedPreferences();
  final service = PreferencesService(mockPrefs);

  when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);

  await service.setPackTime(TimeOfDay(hour: 19, minute: 0));

  verify(() => mockPrefs.setInt('pack_time_hour', 19)).called(1);
});
```

#### B. Tests de Widgets (UI)
```dart
testWidgets('Course list should display courses', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        coursesControllerProvider.overrideWith(() => MockCoursesController()),
      ],
      child: MaterialApp(home: CourseListPage()),
    ),
  );

  expect(find.text('Math'), findsOneWidget);
  expect(find.byType(CourseCard), findsWidgets);
});
```

#### C. Tests d'Intégration
```dart
testWidgets('Adding a supply updates the tomorrow list', (tester) async {
  // Setup: page cours avec un cours
  // Action: ajouter une fourniture
  // Vérification: la fourniture apparaît dans "Mon Sac"
});
```

---

### 6. **Dépendances Hardcodées dans les Tests** 🟡

**Problème:**
Les controllers utilisent `ref.watch()` ce qui rend difficile le test avec des mocks.

**Solution:**
Utiliser l'override de providers dans les tests:

```dart
test('should fetch courses', () async {
  final container = ProviderContainer(
    overrides: [
      courseRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );

  final controller = container.read(coursesControllerProvider);

  await controller.future;

  expect(controller.value, isA<DataCourseListState>());
});
```

---

## 📋 Plan d'Action Recommandé

### Phase 1: Fondations (1-2 semaines)
1. ✅ Refactoriser `PreferencesService` → Interface + Implémentation
2. ✅ Refactoriser `NotificationService` → Interface + Implémentation
3. ✅ Créer des providers Riverpod pour ces services
4. ✅ Ajouter les dépendances de test:
   ```yaml
   dev_dependencies:
     flutter_test:
     mockito: ^5.4.0
     build_runner: ^2.4.0
     mocktail: ^1.0.0  # Alternative à mockito, plus simple
   ```

### Phase 2: Use Cases & Tests (2-3 semaines)
1. ✅ Créer la couche Use Cases pour la logique métier complexe
2. ✅ Écrire des tests pour tous les repositories
3. ✅ Écrire des tests pour les use cases
4. ✅ Écrire des tests pour les mappers/transformations

### Phase 3: Tests UI & Intégration (1-2 semaines)
1. ✅ Tests de widgets pour les pages principales
2. ✅ Tests d'intégration pour les flux critiques
3. ✅ Configuration CI/CD pour exécuter les tests automatiquement

### Phase 4: Refactoring Controllers (1 semaine)
1. ✅ Supprimer l'état mutable des controllers
2. ✅ Utiliser les use cases dans les controllers
3. ✅ Ajouter des tests pour les controllers

---

## 🎯 Objectifs de Couverture de Tests

| Type | Objectif | Priorité |
|------|----------|----------|
| **Repositories** | 80-90% | 🔴 HAUTE |
| **Use Cases** | 90-100% | 🔴 HAUTE |
| **Services** | 80-90% | 🔴 HAUTE |
| **Mappers** | 100% | 🟡 MOYENNE |
| **Controllers** | 70-80% | 🟡 MOYENNE |
| **Widgets** | 50-60% | 🟢 BASSE |

---

## 📚 Ressources Recommandées

- **Clean Architecture Flutter**: [ResoCoder Blog](https://resocoder.com/flutter-clean-architecture-tdd/)
- **Testing avec Riverpod**: [Documentation officielle](https://riverpod.dev/docs/cookbooks/testing)
- **Mockito/Mocktail**: Pour créer des mocks
- **Golden Tests**: Pour tester l'UI de manière visuelle

---

## 🏆 Résumé

### Forces de l'architecture actuelle:
✅ Architecture modulaire bien organisée
✅ Pattern Repository avec interfaces
✅ Gestion des erreurs avec Either
✅ Riverpod pour l'injection de dépendances
✅ Séparation présentation/logique

### Faiblesses principales:
❌ Services statiques non testables
❌ Absence de couche Use Cases
❌ État mutable dans les controllers
❌ Manque de tests

### Priorités:
1. 🔴 Refactoriser les services statiques
2. 🔴 Créer la couche Use Cases
3. 🔴 Écrire des tests pour repositories et use cases
4. 🟡 Refactoriser les controllers (immutabilité)
5. 🟢 Ajouter tests d'intégration et UI

En suivant ce plan, ton application sera **100% testable** et **maintenable à long terme** ! 🚀
