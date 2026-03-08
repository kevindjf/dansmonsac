import 'package:common/src/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/sharing_repository.dart';
import '../repository/sharing_supabase_repository.dart';
import '../services/schedule_serializer.dart';

part 'riverpod_di.g.dart';

@riverpod
SharingRepository sharingRepository(Ref ref) {
  return SharingSupabaseRepository(Supabase.instance.client);
}

@riverpod
ScheduleSerializer scheduleSerializer(Ref ref) {
  return ScheduleSerializer(ref.watch(databaseProvider));
}
