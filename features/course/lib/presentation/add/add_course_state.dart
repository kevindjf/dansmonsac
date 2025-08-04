class AddCourseState {
  final String courseName;
  final bool isLoading;
  final String? errorCourseName;

  AddCourseState(this.courseName, this.isLoading, this.errorCourseName);

  factory AddCourseState.initial() {
    return AddCourseState('', false, null);
  }

  AddCourseState copyWith(
      {String? courseName, bool? isLoading, String? errorCourseName}) {
    var state =  AddCourseState(courseName ?? this.courseName,
        isLoading ?? this.isLoading, errorCourseName);
    return state;

  }
}
