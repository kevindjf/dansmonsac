import 'dart:ffi';

import 'package:common/src/models/network/network_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supply/models/command/add_supply_command.dart';

import '../models/supply.dart';

abstract class SupplyRepository {
  Future<Either<Failure,Supply>> store(AddSupplyCommand command);

  Future<Either<Failure,void>>deleteSupply(String id);
}