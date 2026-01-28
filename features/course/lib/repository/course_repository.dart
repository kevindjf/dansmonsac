import 'package:common/src/models/network/network_failure.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:dartz/dartz.dart';

abstract class CourseRepository {
  Future<Either<Failure,CourseWithSupplies>> store(AddCourseCommand command);
  Future<Either<Failure,List<CourseWithSupplies>>> fetchCourses();
  Future<Either<Failure,void>> deleteCourse(String id);
  Future<Either<Failure,void>> updateCourseName(String id, String newName);
}