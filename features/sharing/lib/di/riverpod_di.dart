import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/sharing_repository.dart';
import '../repository/sharing_supabase_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
SharingRepository sharingRepository(SharingRepositoryRef ref) {
  return SharingSupabaseRepository(Supabase.instance.client);
}
