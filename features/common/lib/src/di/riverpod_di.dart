import 'package:common/src/navigation/routes.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/sharedPreferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


part 'riverpod_di.g.dart';

@riverpod
PreferenceRepository preferenceRepository(Ref<PreferenceRepository> ref) =>
    SharedPreferencesRepository();

final supabaseClient = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

@riverpod
AppRouterDelegate routerDelegate(Ref<AppRouterDelegate> ref) =>
    AppRouterDelegate();