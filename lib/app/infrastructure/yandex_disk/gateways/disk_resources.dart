import 'package:soera_archive/app/domain/gateways/expression.dart';

final class DiskResources implements Expression {
  static const _command = 'disk/resources?path=app:/<PATH>&limit=1000';

  const DiskResources();

  @override
  String generateFrom(final String param) => _command.replaceAll(
        '<PATH>',
        param,
      );
}
