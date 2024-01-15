import 'dart:async';

import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class Console {
  final Context<String> _context;
  final Client _client;

  const Console({
    required final Context<String> ctx,
    required final Client client,
  })  : _context = ctx,
        _client = client;

  StreamSubscription<String> execute(final Executable exe) {
    return exe
        .invoke(_context, _client)
        .transform<String>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) => sink.add(data),
            handleError: (error, _, sink) => sink.add(error.toString()),
            handleDone: (sink) => sink.close(),
          ),
        )
        .listen(null, cancelOnError: false);
  }
}
