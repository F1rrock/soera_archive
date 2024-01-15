import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/domain/entities/console.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class MockContext<Type> extends Mock implements Context<Type> {}

final class MockClient extends Mock implements Client {}

final class MockExe extends Mock implements Executable {}

void main() {
  group(
    'test open directive functionality',
    () {
      late Console console;
      late Context<String> ctx;
      late Client client;
      late Executable exe;
      setUp(() {
        ctx = MockContext<String>();
        client = MockClient();
        console = Console(ctx: ctx, client: client);
        exe = MockExe();
      });
      test(
        'console executes successfully',
        () {
          when(() => exe.invoke(ctx, client)).thenAnswer((_) async* {
            yield 'mock response 1';
            yield 'mock response 2';
          });
          final subscription = console.execute(exe);
          final controller = StreamController<String>();
          subscription
            ..onData(
              (data) => controller.add(data),
            )
            ..onError(
              (error) => fail('error'),
            )
            ..onDone(
              () => controller.close(),
            );
          subscription.asFuture().then((_) {
            expectLater(
              controller.stream,
              emitsInOrder([
                'mock response 1',
                'mock response 2',
                emitsDone,
              ]),
            );
          });
        },
      );

      test(
        'console executes error',
        () {
          when(() => exe.invoke(ctx, client)).thenAnswer((_) async* {
            yield* Stream.error('mock error');
          });
          final subscription = console.execute(exe);
          final controller = StreamController<String>();
          subscription
            ..onData(
              (data) => controller.add(data),
            )
            ..onError(
              (error) => fail('error'),
            )
            ..onDone(
              () => controller.close(),
            );
          subscription.asFuture().then((_) {
            expectLater(
              controller.stream,
              emitsInOrder([
                'mock error',
                emitsDone,
              ]),
            );
          });
        },
      );
    },
  );
}
