import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class Cache implements Executable {
  final Stream<String> _origin;

  const Cache({
    required final Stream<String> origin,
  }) : _origin = origin;

  @override
  Stream<String> invoke(
    final Context<String> ctx,
    final Client client,
  ) async* {
    yield* _origin;
  }
}
