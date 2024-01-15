import 'package:test/test.dart';
import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/gateways/disk_resources.dart';

void main() {
  group(
    'testing yandex disk "disk resources" command',
    () {
      late Expression resources;
      setUp(() {
        resources = DiskResources();
      });
      test(
        'command build testing',
        () {
          final mockPath = 'folder/file';
          final expected = 'disk/resources?path=app:/folder/file';
          final response = resources.generateFrom(mockPath);
          expect(expected, equals(response));
        },
      );
    },
  );
}
