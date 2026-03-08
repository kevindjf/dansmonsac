import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:supply/repository/supply_repository.dart';
import 'package:supply/repository/supply_drift_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
SupplyRepository supplyRepository(Ref<SupplyRepository> ref) =>
    SupplyDriftRepository(ref.watch(databaseProvider));
