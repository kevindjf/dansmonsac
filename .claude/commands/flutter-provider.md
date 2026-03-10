Crée un provider Riverpod en respectant ces règles :

## Riverpod Generator OBLIGATOIRE
- TOUJOURS utiliser @riverpod annotation, PAS de providers manuels
- `dart run build_runner build --delete-conflicting-outputs` après chaque ajout
- Fichier généré : `xxx.g.dart`

## Quel type
- **@riverpod + Notifier** → état mutable (controller de page, formulaire)
- **@riverpod + AsyncNotifier** → état async (données API/DB)
- **@riverpod simple** → dépendances (repositories, use cases, streams)
- **JAMAIS StateProvider** pour de la logique métier

## Clean Architecture : Provider → Use Case → Repository
- Le provider appelle un USE CASE, JAMAIS un repository directement
- Le use case contient la logique métier
- Le repository est injecté via un provider @riverpod
- JAMAIS d'appel Supabase/API dans le provider ou le widget

```dart
// ❌ INTERDIT
@riverpod
class ProfileController extends _$ProfileController {
  Future<void> load() async {
    state = await ref.read(supabaseProvider).from('profiles').select();
  }
}

// ✅ CORRECT
@riverpod
class ProfileController extends _$ProfileController {
  Future<void> load() async {
    final getProfile = ref.read(getProfileUseCaseProvider);
    state = AsyncData(await getProfile());
  }
}
```

## Conventions
- Fichier : `feature_name_controller.dart` (Notifier) ou `feature_name_provider.dart` (simple)
- Placer dans `lib/features/<feature>/application/providers/`
- Un provider = une responsabilité. Si ton provider fait 2 choses, splitte-le

## Gestion d'erreurs
- AsyncValue.when(data:, loading:, error:) → TOUJOURS gérer les 3
- Retry : exposer une méthode refresh() dans le Notifier
- Catch les exceptions dans le Notifier, pas dans le widget
