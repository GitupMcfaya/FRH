class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class RecordNotFoundException extends RepositoryException {
  const RecordNotFoundException(super.message);
}

class ConflictException extends RepositoryException {
  const ConflictException(super.message);
}

class AuthenticationException extends RepositoryException {
  const AuthenticationException(super.message);
}

class ValidationException extends RepositoryException {
  const ValidationException(super.message);
}
