import 'dart:io';
import 'package:common/src/models/network/network_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositoryHelper {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://slivvtpmeorrykdsllpl.supabase.co", // Remplace par ton URL
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsaXZ2dHBtZW9ycnlrZHNsbHBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NjI1MjMsImV4cCI6MjA1NzQzODUyM30.j5fv5wc1KvLzIS6Ig6ZOydW-DYK5ksqxmNYIkV3hvpw", // Remplace par ta clé anonyme
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
