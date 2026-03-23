enum RepositoryErrorType {
  network,
  auth,
  schema,
  unknown,
}

class RepositoryError {
  final RepositoryErrorType type;
  final String message;
  final Object? cause;

  const RepositoryError({
    required this.type,
    required this.message,
    this.cause,
  });
}

class RepositoryResult<T> {
  final T? data;
  final RepositoryError? error;

  const RepositoryResult._({
    this.data,
    this.error,
  });

  const RepositoryResult.success(T data) : this._(data: data);
  const RepositoryResult.failure(RepositoryError error) : this._(error: error);

  bool get isSuccess => error == null;
}

RepositoryErrorType mapRepositoryErrorType(Object error) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('socket') ||
      msg.contains('failed host lookup') ||
      msg.contains('network') ||
      msg.contains('timeout')) {
    return RepositoryErrorType.network;
  }
  if (msg.contains('auth') ||
      msg.contains('jwt') ||
      msg.contains('permission denied') ||
      msg.contains('not authorized')) {
    return RepositoryErrorType.auth;
  }
  if (msg.contains('column') ||
      msg.contains('relation') ||
      msg.contains('schema') ||
      msg.contains('postgrest') ||
      msg.contains('invalid input syntax')) {
    return RepositoryErrorType.schema;
  }
  return RepositoryErrorType.unknown;
}
