/// Classe abstraite représentant un item dans la liste
class CourseItemUI {
  final String id;
  final String title;
  final bool isExpand;
  final List<SupplyItemUI> supplies;

  CourseItemUI(
      {required this.id,
      required this.title,
      required this.supplies,
      required this.isExpand});

  CourseItemUI copyWith({String? title, bool? isExpand, List<SupplyItemUI>? supplies}) {
    return CourseItemUI(
        id: id,
        title: title ?? this.title,
        supplies: supplies ?? this.supplies,
        isExpand: isExpand ?? this.isExpand);
  }
}

/// Item pour une fourniture avec checkbox
class SupplyItemUI {
  final String id;
  final String name;
  bool isChecked;

  SupplyItemUI({required this.id, required this.name, this.isChecked = false});
}

abstract class CourseListState {}

class LoadingCourseListState extends CourseListState {}

class ErrorCourseListState extends CourseListState {}

class DataCourseListState extends CourseListState {
  final List<CourseItemUI> items;

  DataCourseListState(this.items);
}
