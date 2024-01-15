import 'dart:io';

extension AddHeadersAsJson on HttpHeaders {
  void addAll(final Map<String, dynamic> json) {
    for (final header in json.entries) {
      add(header.key, header.value);
    }
  }
}