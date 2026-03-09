import '../../../models/shared_schedule_data.dart';

/// State for the share page
class ShareState {
  final bool isLoading;
  final bool isGenerating;
  final bool isSyncing;
  final bool syncFailed; // True if the last sync attempt failed
  final String? code;
  final String sharerName;
  final SharedScheduleData? data;
  final String? errorMessage;

  const ShareState({
    this.isLoading = true,
    this.isGenerating = false,
    this.isSyncing = false,
    this.syncFailed = false,
    this.code,
    this.sharerName = '',
    this.data,
    this.errorMessage,
  });

  ShareState copyWith({
    bool? isLoading,
    bool? isGenerating,
    bool? isSyncing,
    bool? syncFailed,
    String? code,
    String? sharerName,
    SharedScheduleData? data,
    String? errorMessage,
  }) {
    return ShareState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isSyncing: isSyncing ?? this.isSyncing,
      syncFailed: syncFailed ?? this.syncFailed,
      code: code ?? this.code,
      sharerName: sharerName ?? this.sharerName,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  bool get hasCode => code != null && code!.isNotEmpty;
  bool get hasError => errorMessage != null;

  /// Accès safe au code (retourne chaîne vide si null)
  String get safeCode => code ?? '';

  int get courseCount => data?.courses.length ?? 0;
  int get calendarCount => data?.calendarCourses.length ?? 0;
  int get supplyCount => data?.totalSupplies ?? 0;
}
