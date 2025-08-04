import 'package:course/repository/course_repository.dart';
import 'package:course/repository/course_supabase_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:supply/repository/supply_repository.dart';
import 'package:supply/repository/supply_supabase_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
SupplyRepository supplyRepository(Ref<SupplyRepository> ref) =>
    SupplySupabaseRepository(
        ref.watch(supabaseClient), ref.watch(preferenceRepositoryProvider));
