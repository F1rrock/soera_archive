import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/directive.dart';
import 'package:soera_archive/core/external/executable.dart';
import 'package:soera_archive/core/implementation/anonymous_exe.dart';

final class CD implements Directive {
  final Executable _ls;

  const CD({
    required final Executable ls,
  }) : _ls = ls;

  @override
  Executable accept(final String param) => AnonymousExe(
        origin: (
          final Context<String> ctx,
          final Client client,
        ) async* {
          final mockCtx = ctx.clone();
          mockCtx.goTo(param);
          final subscription = _ls.invoke(mockCtx, client).listen(null);
          await subscription.asFuture();
          ctx.goTo(param);
          yield '{"status": "OK"}';
        },
      );
}
