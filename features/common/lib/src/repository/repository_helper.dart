import 'dart:io';

import 'package:common/src/models/network/network_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositoryHelper {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
}

Future<Either<Failure, T>> handleErrors<T>(Future<T> Function() fn) async {
  try {
    final result = await fn();
    return Right(result);
  } on SocketException catch (e) {
    return Left(NetworkFailure(e.message));
  } on FormatException catch (e) {
    return Left(ValidationFailure(e.message));
  } on PostgrestException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
