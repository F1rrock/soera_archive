import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:soera_archive/app/infrastructure/internal/add_headers_as_json.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';

final class YandexRest implements Client {
  final String _token;
  final HttpClient _client;
  StreamController<String> _controller;

  static const _url = 'https://cloud-api.yandex.net/v1/<EXPRESSION>';
  static final _headersTemplate = {
    'Authorization': "OAuth <TOKEN>",
    'Accept': "application/json",
    'Content-Type': "application/json",
  };

  factory YandexRest({
    required final String token,
  }) =>
      YandexRest.client(
        token: token,
        client: HttpClient(),
      );

  YandexRest.client({
    required final String token,
    required final HttpClient client,
  })  : _token = token,
        _client = client,
        _controller = StreamController();

  Map<String, dynamic> get _headers => {
        ..._headersTemplate,
      }..update(
          'Authorization',
          (value) => value.replaceAll('<TOKEN>', _token),
        );

  StreamSubscription<String> _pipe(final HttpClientResponse response) {
    return response.transform(utf8.decoder).listen(
          null,
          cancelOnError: false,
        )
      ..onData(
        (data) => _controller.add(data),
      )
      ..onError(
        (error) => _controller.addError(error),
      )
      ..onDone(() => _controller.done);
  }

  Future<void> _handle(final HttpClientResponse response) async {
    final status = response.statusCode;
    if (status != 200) {
      final body = await response.transform(utf8.decoder).join();
      throw 'client respond error with status code: $status and body: $body';
    }
  }

  @override
  Future<void> commit(final String expression) async {
    final url = _url.replaceAll('<EXPRESSION>', expression);
    try {
      _controller = StreamController();
      final request = await _client.getUrl(Uri.parse(url));
      request.headers.addAll(_headers);
      final response = await request.close();
      await _handle(response);
      final subsription = _pipe(response);
      await subsription.asFuture();
    } catch (error) {
      _controller.addError(ServerError(message: error.toString()));
    } finally {
      _controller.close();
    }
  }

  @override
  Stream<String> get logs => _controller.stream.asBroadcastStream();
}
