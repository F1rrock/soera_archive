import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/api/yandex_rest.dart';
import 'package:soera_archive/core/external/client.dart';

final class MockHttpClient extends Mock implements HttpClient {}

final class MockHttpClientRequest extends Mock implements HttpClientRequest {}

final class MockHttpHeaders extends Mock implements HttpHeaders {}

final class MockHttpClientResponse extends Mock implements HttpClientResponse {}

final class FakeUri extends Fake implements Uri {}

void main() {
  group(
    'yandex disk rest api testing',
    () {
      late Client yandexApi;
      late HttpClientResponse response;
      setUp(() {
        registerFallbackValue(FakeUri());
        final request = MockHttpClientRequest();
        final headers = MockHttpHeaders();
        final http = MockHttpClient();
        response = MockHttpClientResponse();
        yandexApi = YandexRest.client(token: 'mock', client: http);
        when(() => http.getUrl(any())).thenAnswer((_) async => request);
        when(() => request.headers).thenReturn(headers);
        when(() => headers.add(any(), any())).thenReturn(null);
        when(() => request.close()).thenAnswer((_) async => response);
      });
      test(
        'server respond successfully',
        () {
          when(() => response.statusCode).thenReturn(200);
          when(() => response.transform(utf8.decoder)).thenAnswer((_) async* {
            yield 'mock data 1';
            yield 'mock data 2';
            yield 'mock data 3';
          });
          yandexApi.commit('mock expression').then((_) {
            final response = yandexApi.logs;
            expectLater(
                response,
                emitsInOrder([
                  'mock data 1',
                  'mock data 2',
                  'mock data 3',
                  emitsDone,
                ]));
          });
        },
      );
      test(
        'server respond an error',
        () {
          when(() => response.statusCode).thenReturn(200);
          when(() => response.transform(utf8.decoder)).thenAnswer((_) async* {
            yield* Stream.error('mock error');
          });
          yandexApi.commit('mock expression').then((_) {
            final response = yandexApi.logs;
            final expected = 'server error: mock error';
            expectLater(
              response,
              emitsError(
                (error) => error.toString() == expected,
              ),
            );
          });
        },
      );
      test(
        'server status code refers to error',
        () {
          when(() => response.statusCode).thenReturn(500);
          when(() => response.transform(utf8.decoder)).thenAnswer((_) async* {
            yield 'mock data';
          });
          yandexApi.commit('mock expression').then((_) {
            final response = yandexApi.logs;
            final expected = 'server error: client respond error with status code: 500';
            expectLater(
              response,
              emitsError(
                (error) => error.toString() == expected,
              ),
            );
          });
        },
      );
    },
  );
}
