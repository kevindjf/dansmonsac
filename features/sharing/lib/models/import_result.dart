/// Result of an import operation
class ImportResult {
  final List<String> createdCourses;
  final List<String> skippedCourses;
  final List<ImportConflict> conflicts;
  final int calendarEntriesImported;
  final String? errorMessage;

  ImportResult({
    this.createdCourses = const [],
    this.skippedCourses = const [],
    this.conflicts = const [],
    this.calendarEntriesImported = 0,
    this.errorMessage,
  });

  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get isSuccess => !hasError;

  ImportResult copyWith({
    List<String>? createdCourses,
    List<String>? skippedCourses,
    List<ImportConflict>? conflicts,
    int? calendarEntriesImported,
    String? errorMessage,
  }) {
    return ImportResult(
      createdCourses: createdCourses ?? this.createdCourses,
      skippedCourses: skippedCourses ?? this.skippedCourses,
      conflicts: conflicts ?? this.conflicts,
      calendarEntriesImported:
          calendarEntriesImported ?? this.calendarEntriesImported,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Represents a conflict during import
class ImportConflict {
  final String courseName;
  final List<String> existingSupplies;
  final List<String> importedSupplies;
  final String? existingCourseId;
  ConflictResolution? resolution;

  ImportConflict({
    required this.courseName,
    required this.existingSupplies,
    required this.importedSupplies,
    this.existingCourseId,
    this.resolution,
  });

  /// Supplies that exist in imported but not in existing
  List<String> get newSupplies =>
      importedSupplies.where((s) => !existingSupplies.contains(s)).toList();

  /// Supplies that would be removed if replaced
  List<String> get removedSupplies =>
      existingSupplies.where((s) => !importedSupplies.contains(s)).toList();

  /// Merged supplies (union of both)
  List<String> get mergedSupplies =>
      {...existingSupplies, ...importedSupplies}.toList();
}

/// How the user chose to resolve a conflict
enum ConflictResolution {
  keepExisting,
  replace,
  merge,
}
