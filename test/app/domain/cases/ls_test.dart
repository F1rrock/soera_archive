import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soera_archive/app/domain/cases/ls.dart';
import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';

final class MockExpression extends Mock implements Expression {}

final class MockContext<Type> extends Mock implements Context<Type> {}

final class MockClient extends Mock implements Client {}

void main() {
  group(
    'test LS directive functionality',
    () {
      late LS ls;
      late Expression strategy;
      late Context<String> ctx;
      late Client client;
      setUp(() {
        strategy = MockExpression();
        ctx = MockContext<String>();
        client = MockClient();
        ls = LS.using(
          generationStrategy: strategy,
        );
        when(() => ctx.content).thenReturn('mock path');
        when(() => strategy.generateFrom('mock path'))
            .thenReturn('mock expression');
      });
      test(
        'client respond data successfully',
        () {
          when(() => client.commit('mock expression')).thenAnswer((_) async {});
          when(() => client.logs).thenAnswer((_) async* {
            yield 'response 1';
            yield 'response 2';
            yield 'response 3';
          });
          final stream = ls.invoke(ctx, client);
          expectLater(
            stream,
            emitsInOrder([
              'response 1',
              'response 2',
              'response 3',
              emitsDone,
            ]),
          );
          verifyNever(() => ctx.content);
          verifyNever(() => strategy.generateFrom('mock path'));
          verifyNever(() => client.commit('mock expression'));
          verifyNever(() => client.logs);
        },
      );
      test(
        'client respond an error',
        () {
          when(() => client.commit('mock expression')).thenAnswer((_) async {
            throw const ServerError(message: 'mock exception');
          });
          final stream = ls.invoke(ctx, client);
          expectLater(
            stream,
            emitsError(isA<ServerError>().having(
              (error) => error.toString(),
              'message',
              'server error: mock exception',
            )),
          );
          verifyNever(() => ctx.content);
          verifyNever(() => strategy.generateFrom('mock path'));
          verifyNever(() => client.commit('mock expression'));
          verifyNever(() => client.logs);
        },
      );
    },
  );
}
