import 'package:course/models/suggested_supply.dart';

class AddCourseState {
  final String courseName;
  final bool isLoading;
  final String? errorCourseName;
  final List<SuggestedSupply> suggestedSupplies;

  AddCourseState(
    this.courseName,
    this.isLoading,
    this.errorCourseName,
    this.suggestedSupplies,
  );

  factory AddCourseState.initial() {
    return AddCourseState('', false, null, []);
  }

  AddCourseState copyWith(
      {String? courseName,
      bool? isLoading,
      String? errorCourseName,
      List<SuggestedSupply>? suggestedSupplies}) {
    var state = AddCourseState(
        courseName ?? this.courseName,
        isLoading ?? this.isLoading,
        errorCourseName,
        suggestedSupplies ?? this.suggestedSupplies);
    return state;
  }
}
