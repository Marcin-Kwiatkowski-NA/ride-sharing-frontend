sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure() : super('Session expired. Please log in again.');
}

class UnknownFailure extends Failure {
  UnknownFailure(Object error) : super(error.toString());
}
