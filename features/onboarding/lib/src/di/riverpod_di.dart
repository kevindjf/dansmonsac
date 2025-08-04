import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:onboarding/src/repositories/onboarding_supabase_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:course/di/riverpod_di.dart';

part 'riverpod_di.g.dart';

@riverpod
OnboardingRepository onboardingRepository(Ref<OnboardingRepository> ref) =>
    OnboardingSupabaseRepository(
        ref.watch(supabaseClient),
        ref.watch(preferenceRepositoryProvider),
        ref.watch(courseRepositoryProvider));
