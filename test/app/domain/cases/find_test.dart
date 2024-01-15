import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/domain/cases/find.dart';
import 'package:soera_archive/app/domain/cases/ls.dart';
import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';

final class MockExpression extends Mock implements Expression {}

final class MockContext extends Mock implements Context<String> {}

final class MockClient extends Mock implements Client {}

void main() {
  group('test Find directive functionality', () {
    late Find find;
    late LS ls;
    late Context<String> ctx;
    late Client client;
    late Expression strategy;
    setUp(() {
      strategy = MockExpression();
      ctx = MockContext();
      client = MockClient();
      ls = LS.using(generationStrategy: strategy);
      find = Find(ls: ls);
    });
    test(
      'successfully find matches',
      () async {
        when(() => ctx.content).thenReturn('mock path');
        when(() => strategy.generateFrom('mock path'))
            .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield '{"folders": ["mock_folder1", "mock_folder2"], "files": ["mock_file1", "mock_file2"]}';
        });
        final exe = find.accept('folder1');
        await exe.invoke(ctx, client).first.then((response) {
          expect(response, '{"folders": ["mock_folder1"], "files": []}');
          verify(() => client.commit('mock expression')).called(1);
          verify(() => client.logs).called(1);
        });
      },
    );
    test(
      'receive error while try to find in current directory',
      () async {
        when(() => ctx.content).thenReturn('mock path');
        when(() => strategy.generateFrom('mock path'))
            .thenReturn('mock expression');
        when(() => client.commit('mock expression')).thenAnswer((_) async {});
        when(() => client.logs).thenAnswer((_) async* {
          yield* Stream.error(const ServerError(message: 'mock error'));
        });
        final exe = find.accept('folder');
        await expectLater(
          () async => await exe.invoke(ctx, client).first,
          throwsA(isA<ServerError>().having(
            (error) => error.toString(),
            'message',
            'server error: mock error',
          )),
        );
        verify(() => client.commit('mock expression')).called(1);
        verify(() => client.logs).called(1);
      },
    );
  });
}
