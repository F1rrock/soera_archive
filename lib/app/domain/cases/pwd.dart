import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class PWD implements Executable {
  final Executable _ls;

  const PWD({
    required final Executable ls,
  }) : _ls = ls;

  @override
  Stream<String> invoke(
    final Context<String> ctx,
    final Client client,
  ) async* {
    final subscription = _ls.invoke(ctx, client).listen(null);
    await subscription.asFuture();
    yield '{"current_path": "${ctx.content}"}';
  }
}
