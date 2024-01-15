abstract class Client {
  Future<void> commit(final String expression);
  Stream<String> get logs;
}