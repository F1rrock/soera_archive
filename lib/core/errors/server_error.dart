final class ServerError implements Exception {
  final String _message;

  const ServerError({
    required final String message,
  }) : _message = message;

  @override
  String toString() => 'server error: $_message';
}