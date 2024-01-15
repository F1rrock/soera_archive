import 'dart:async';

import 'package:test/test.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';
import 'package:soera_archive/core/implementation/anonymous_exe.dart';

final class MockContext implements Context<String> {
  String _internal;

  MockContext() : _internal = '';
  MockContext._copied(final Context<String> copy) : _internal = copy.content;

  @override
  void goTo(final String resource) {
    _internal = resource;
  }

  @override
  String get content => _internal;

  @override
  Context<String> clone() => MockContext._copied(this);
}

final class MockClient implements Client {
  StreamController<String> _controller;

  MockClient() : _controller = StreamController();

  @override
  Future<void> commit(final String expression) async {
    _controller = StreamController();
    try {
      _controller.add(expression);
    } catch (error) {
      _controller.addError(error);
    } finally {
      _controller.close();
    }
  }

  @override
  Stream<String> get logs async* {
    yield* _controller.stream;
  }
}

Stream<String> mockOrigin(
  final Context<String> ctx,
  final Client client,
) async* {
  ctx.goTo('test');
  final expression = ctx.content;
  await client.commit(expression);
  yield* client.logs.asBroadcastStream();
  yield 'DONE';
}

void main() {
  group(
    'anonymous exe test',
    () {
      late Executable exe;
      late Stream<String> Function(Context<String>, Client) origin;
      late Context<String> ctx;
      late Client client;
      setUp(() {
        origin = mockOrigin;
        exe = AnonymousExe(origin: origin);
        ctx = MockContext();
        client = MockClient();
      });
      test(
        'same stream response',
        () async {
          final stream = exe.invoke(ctx, client);
          final expected = origin(ctx, client);
          await expectLater(
            stream,
            emitsInOrder(
              [
                'test',
                'DONE',
                emitsDone,
              ],
            ),
          );
          await expectLater(
            expected,
            emitsInOrder(
              [
                'test',
                'DONE',
                emitsDone,
              ],
            ),
          );
        },
      );
    },
  );
}
