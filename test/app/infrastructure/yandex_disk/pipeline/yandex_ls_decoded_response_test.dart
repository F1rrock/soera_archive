import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/pipeline/yandex_ls_decoded_response.dart';
import 'package:soera_archive/core/errors/server_error.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class MockLS extends Mock implements Executable {}

final class MockContext<Type> extends Mock implements Context<String> {}

final class MockClient extends Mock implements Client {}

void main() {
  group(
    'yandex response decoder testing',
    () {
      late Executable responseDecoder;
      late Executable ls;
      late Context<String> ctx;
      late Client client;
      setUp(() {
        ls = MockLS();
        ctx = MockContext();
        client = MockClient();
        responseDecoder = YandexLSDecodedResponse(
          origin: ls,
        );
      });
      test(
        'decoded response successfully',
        () {
          when(() => ls.invoke(ctx, client)).thenAnswer((_) async* {
            yield '''
            {
              "_embedded": {
                "items": [
                  {
                    "name": "mock folder",
                    "type": "dir"
                  },
                  {
                    "name": "mock file",
                    "type": "file"
                  }
                ]
              }
            }
          ''';
          });
          final stream = responseDecoder.invoke(ctx, client);
          final expected =
              '{"folders": ["mock folder"], "files": ["mock file"]}';
          expectLater(
              stream,
              emitsInOrder([
                expected,
                emitsDone,
              ]));
        },
      );
      test(
        'decoding response error',
        () {
          when(() => ls.invoke(ctx, client)).thenAnswer((_) async* {
            yield 'some mock message';
          });
          final stream = responseDecoder.invoke(ctx, client);
          final expected = 'server error: unresolved response';
          expectLater(
            stream,
            emitsError(
              (error) => error.toString() == expected,
            ),
          );
        },
      );
      test(
        'rest api returns an error',
        () {
          when(() => ls.invoke(ctx, client)).thenAnswer((_) async* {
            yield* Stream.error(ServerError(message: 'unauthorized'));
          });
          final stream = ls.invoke(ctx, client);
          final expected = 'server error: unauthorized';
          expectLater(
            stream,
            emitsError(
              (error) => error.toString() == expected,
            ),
          );
        },
      );
    },
  );
}
