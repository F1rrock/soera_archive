import 'dart:convert';

import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/directive.dart';
import 'package:soera_archive/core/external/executable.dart';
import 'package:soera_archive/core/implementation/anonymous_exe.dart';

final class Find implements Directive {
  final Executable _ls;

  const Find({
    required final Executable ls,
  }) : _ls = ls;

  String _format(final String origin) => origin.toLowerCase().trim();

  Iterable<String> _filter(
    final List<dynamic> origin,
    final String referecnce,
  ) sync* {
    yield* origin
        .map(
          (element) => element.toString(),
        )
        .where(
          (element) => _format(element).contains(
            _format(referecnce),
          ),
        );
  }

  String _stringify(final Iterable<String> list) {
    final shape = list.map((element) => '"$element"').join(', ');
    return '[$shape]';
  }

  @override
  Executable accept(final String param) => AnonymousExe(
        origin: (
          final Context<String> ctx,
          final Client client,
        ) async* {
          final stream = _ls.invoke(ctx, client);
          yield* stream.transform(json.decoder).map(
            (final dynamic log) {
              final folders = _filter(log['folders'], param);
              final files = _filter(log['files'], param);
              return '{"folders": ${_stringify(folders)}, "files": ${_stringify(files)}}';
            },
          );
        },
      );
}
