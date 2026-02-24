import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when a use case doesn't need any parameters
class NoParams {
  const NoParams();
}
