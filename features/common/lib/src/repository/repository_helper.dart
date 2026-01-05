import 'dart:io';

import 'package:common/src/models/network/network_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositoryHelper {
  static Future<void> initialize() async {
    await Supabase.initialize(
        url: "https://zlekjficktlntawczjdf.supabase.co", // Remplace par ton URL
        anonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsZWtqZmlja3RsbnRhd2N6amRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MDMxNDAsImV4cCI6MjA4MzE3OTE0MH0.R21JpibM5aqpB0KCh4Ksc3xQiZfF6TIw0O5LaucwJhc");
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
