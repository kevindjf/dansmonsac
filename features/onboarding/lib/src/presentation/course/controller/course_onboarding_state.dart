class CourseOnboardingState {
  final String courseName;
  final bool isLoading;
  final List<String> supplies;
  final String? errorCourseName;

  CourseOnboardingState(
      this.courseName, this.isLoading, this.supplies, this.errorCourseName);

  factory CourseOnboardingState.initial() {
    return CourseOnboardingState('', false, [], null);
  }

  CourseOnboardingState copyWith(
      {String? courseName,
      bool? isLoading,
      List<String>? supplies,
      String? errorCourseName}) {
    return CourseOnboardingState(
        courseName ?? this.courseName,
        isLoading ?? this.isLoading,
        supplies ?? this.supplies,
        errorCourseName);
  }
}
