import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/domain/cases/ls.dart';
import 'package:soera_archive/app/domain/cases/pwd.dart';
import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';

final class MockExpression extends Mock implements Expression {}

final class MockContext<Type> extends Mock implements Context<String> {}

final class MockClient extends Mock implements Client {}

void main() {
  group('test PWD directive functionality', () {
    late PWD pwd;
    late LS ls;
    late Context<String> ctx;
    late Client client;
    late Expression strategy;
    setUp(() {
      strategy = MockExpression();
      ctx = MockContext<String>();
      client = MockClient();
      ls = LS.using(generationStrategy: strategy);
      pwd = PWD(ls: ls);
    });
    test(
      'path received successfully',
      () async {
        when(() => ctx.content).thenReturn('mock path');
        when(() => strategy.generateFrom('mock path'))
            .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield 'mock data';
        });
        final expected = '{"current_path": "${ctx.content}"}';
        await pwd.invoke(ctx, client).first.then((path) {
          expect(path, equals(expected));
          verify(() => ctx.content).called(3);
          verify(() => client.commit('mock expression')).called(1);
          verify(() => client.logs).called(1);
        });
      },
    );
    test(
      'path received error',
      () async {
        when(() => ctx.content).thenReturn('mock path');
        when(() => strategy.generateFrom('mock path'))
            .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield* Stream.error(const ServerError(message: 'mock error'));
        });
        await expectLater(
          () async => await pwd.invoke(ctx, client).first,
          throwsA(isA<ServerError>().having(
            (error) => error.toString(),
            'message',
            'server error: mock error',
          )),
        );
        verify(() => ctx.content).called(1);
        verify(() => client.commit('mock expression')).called(1);
        verify(() => client.logs).called(1);
      },
    );
  });
}
