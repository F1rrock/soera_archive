import 'dart:async';
import 'dart:convert';

import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

typedef _Response = ({List<String> folders, List<String> files});

final class YandexLSDecodedResponse implements Executable {
  final Executable _origin;

  static const _decodingErrorResponse = 'unresolved response';

  const YandexLSDecodedResponse({
    required final Executable origin,
  }) : _origin = origin;

  String _stringify(final Iterable<String> list) {
    final shape = list.map((element) => '"$element"').join(', ');
    return '[$shape]';
  }

  List<String> _fetchType(
    final String type,
    final _Response response,
  ) {
    final List<String> media;
    if (type == 'dir') {
      media = response.folders;
    } else if (type == 'file') {
      media = response.files;
    } else {
      throw _decodingErrorResponse;
    }
    return media;
  }

  StreamTransformer<String, String> get _handler =>
      StreamTransformer.fromHandlers(
          handleData: (data, sink) => sink.add(data),
          handleError: (error, __, sink) {
            final failedDecodeError = const ServerError(
              message: _decodingErrorResponse,
            );
            final actual = error is ServerError ? error : failedDecodeError;
            sink.addError(actual);
          });

  String _pack(final _Response response) {
    return '{"folders": ${_stringify(response.folders)}, "files": ${_stringify(response.files)}}';
  }

  _Response _map(final Iterable<dynamic> meta) {
    final response = (
      folders: <String>[],
      files: <String>[],
    );
    for (final element in meta) {
      final name = element['name'];
      final type = element['type'];
      final media = _fetchType(type, response);
      media.add(name);
    }
    return response;
  }

  @override
  Stream<String> invoke(
    final Context<String> ctx,
    final Client client,
  ) async* {
    yield* _origin.invoke(ctx, client).transform(json.decoder).map(
      (final dynamic log) {
        final meta = log["_embedded"]["items"];
        final response = _map(meta);
        return _pack(response);
      },
    ).transform(_handler);
  }
}
