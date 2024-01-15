import 'package:soera_archive/core/external/context.dart';

final class FileSystem implements Context<String> {
  String _path;

  FileSystem() : _path = '';
  FileSystem._copied({
    required final Context<String> origin,
  }) : _path = origin.content;

  @override
  Context<String> clone() => FileSystem._copied(origin: this);

  @override
  String get content => _path;

  String _format(final String origin) => origin
      .split('/')
      .where(
        (element) => element.trim() != '',
      )
      .join('/');

  @override
  void goTo(final String resource) {
    final formatted = _format(resource);
    for (final folder in formatted.split('/')) {
      if (folder == '..') {
        final restruct = _path.split('/')..removeLast();
        _path = restruct.join('/');
      } else {
        _path += '/$folder';
      }
    }
    _path = _format(_path);
  }
}
