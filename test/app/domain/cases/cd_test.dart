import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/domain/cases/cd.dart';
import 'package:soera_archive/app/domain/cases/ls.dart';
import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';

final class MockExpression extends Mock implements Expression {}

final class MockContext implements Context<String> {
  String _internal;

  MockContext() : _internal = 'root:';
  MockContext._copied(final Context<String> copy) : _internal = copy.content;

  @override
  void goTo(final String resource) {
    _internal += '/$resource';
  }

  @override
  String get content => _internal;

  @override
  Context<String> clone() => MockContext._copied(this);
}

final class MockClient extends Mock implements Client {}

void main() {
  group('test CD directive functionality', () {
    late CD cd;
    late LS ls;
    late Context<String> ctx;
    late Client client;
    late Expression strategy;
    setUp(() {
      strategy = MockExpression();
      ctx = MockContext();
      client = MockClient();
      ls = LS.using(generationStrategy: strategy);
      cd = CD(ls: ls);
    });
    test(
      'successfully change directory',
      () async {
        when(() => strategy.generateFrom(any()))
          .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield 'mock data';
        });
        final exe = cd.accept('folder');
        expect(ctx.content, 'root:');
        await exe.invoke(ctx, client).first.then((response) {
          expect(response, '{"status": "OK"}');
          expect(ctx.content, 'root:/folder');
          verify(() => client.commit('mock expression')).called(1);
          verify(() => client.logs).called(1);
        });
      },
    );
    test(
      'receive error while try to change directory',
      () async {
        when(() => strategy.generateFrom(any()))
          .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield* Stream.error(const ServerError(message: 'mock error'));
        });
        final exe = cd.accept('folder');
        final oldValue = ctx.content;
        await expectLater(
          () async => await exe.invoke(ctx, client).first,
          throwsA(isA<ServerError>().having(
            (error) => error.toString(),
            'message',
            'server error: mock error',
          )),
        );
        expect(oldValue, equals(ctx.content));
        verify(() => client.commit('mock expression')).called(1);
        verify(() => client.logs).called(1);
      },
    );
  });
}
