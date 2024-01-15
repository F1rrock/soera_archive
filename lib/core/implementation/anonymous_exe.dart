import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class AnonymousExe implements Executable {
  final Stream<String> Function(Context<String>, Client) _origin;

  const AnonymousExe({
    required final Stream<String> Function(Context<String>, Client) origin,
  }) : _origin = origin;

  @override
  Stream<String> invoke(final Context<String> ctx, final Client client) =>
      _origin(ctx, client);
}
