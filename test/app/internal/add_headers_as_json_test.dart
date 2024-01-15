import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:soera_archive/app/infrastructure/internal/add_headers_as_json.dart';

final class MockHttpHeaders extends Mock implements HttpHeaders {
  final List<({String header, dynamic value})> _headers;

  MockHttpHeaders() : _headers = [];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.add(
      (
        header: name,
        value: value,
      ),
    );
  }

  @override
  String toString() => _headers.toString();
}

void main() {
  group(
    'add headers as json testing',
    () {
      late HttpHeaders headers;
      setUp(() {
        headers = MockHttpHeaders();
      });
      test(
        'correctly add headers as json',
        () {
          final json = {
            'header1': 'value1',
            'header2': 'value2',
          };
          headers.addAll(json);
          final expected = '[(header: header1, value: value1), (header: header2, value: value2)]';
          final response = headers.toString();
          expect(response, equals(expected));
        },
      );
    },
  );
}
