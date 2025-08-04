import 'package:supply/models/supply.dart';

class CourseWithSupplies {
  final String id;
  final String name;
  final List<Supply> supplies;

  CourseWithSupplies(
      {required this.id, required this.name, required this.supplies});

  factory CourseWithSupplies.fromJson(Map<String, dynamic> json) {
    return CourseWithSupplies(
      id: json['id'],
      name: json['course_name'],
      supplies: (json['course_supplies'] as List?)
              ?.map((cs) => Supply.fromJson(cs['supplies']))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'CourseWithSupplies{name: $name, supplies: $supplies}';
  }

  CourseWithSupplies copyWith({String? id, String? name, List<Supply>? supplies}) {
    return CourseWithSupplies(
      id: id ?? this.id,
      name: name ?? this.name,
      supplies: supplies ?? this.supplies,
    );
  }
}
