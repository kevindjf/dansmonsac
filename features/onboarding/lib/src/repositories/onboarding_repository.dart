import 'package:course/models/cours_with_supplies.dart';
import 'package:dartz/dartz.dart';
import 'package:onboarding/src/models/command/pack_time_command.dart';
import 'package:common/src/models/network/network_failure.dart';

abstract class OnboardingRepository{
    Future<Either<Failure, void>> storePackTime(PackTimeCommand command);
    Future<Either<Failure,CourseWithSupplies>> storeCourse(String courseName,List<String> supplies);
}