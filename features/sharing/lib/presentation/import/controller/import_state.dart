import '../../../models/shared_schedule.dart';
import '../../../models/import_result.dart';

/// State for the import page
class ImportState {
  final bool isLoading;
  final bool isImporting;
  final SharedSchedule? schedule;
  final ImportResult? result;
  final String? errorMessage;
  final List<ImportConflict> pendingConflicts;
  final int currentConflictIndex;

  const ImportState({
    this.isLoading = true,
    this.isImporting = false,
    this.schedule,
    this.result,
    this.errorMessage,
    this.pendingConflicts = const [],
    this.currentConflictIndex = 0,
  });

  ImportState copyWith({
    bool? isLoading,
    bool? isImporting,
    SharedSchedule? schedule,
    ImportResult? result,
    String? errorMessage,
    List<ImportConflict>? pendingConflicts,
    int? currentConflictIndex,
  }) {
    return ImportState(
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      schedule: schedule ?? this.schedule,
      result: result ?? this.result,
      errorMessage: errorMessage,
      pendingConflicts: pendingConflicts ?? this.pendingConflicts,
      currentConflictIndex: currentConflictIndex ?? this.currentConflictIndex,
    );
  }

  bool get hasSchedule => schedule != null;
  bool get hasError => errorMessage != null;
  bool get hasConflicts => pendingConflicts.isNotEmpty;
  bool get isResolvingConflicts => hasConflicts && currentConflictIndex < pendingConflicts.length;

  ImportConflict? get currentConflict =>
      isResolvingConflicts ? pendingConflicts[currentConflictIndex] : null;

  String get sharerDisplayName => schedule?.sharerName ?? 'un ami';

  int get courseCount => schedule?.data.courses.length ?? 0;
  int get calendarCount => schedule?.data.calendarCourses.length ?? 0;
  int get supplyCount => schedule?.data.totalSupplies ?? 0;
}
