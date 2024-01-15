import 'package:test/test.dart';
import 'package:soera_archive/app/domain/entities/file_system.dart';
import 'package:soera_archive/core/external/context.dart';

void main() {
  group(
    'tesing disk functionality',
    () {
      late Context<String> fileSystem;
      setUp(() {
        fileSystem = FileSystem();
      });
      test(
        'go to the path from root',
        () {
          final mockPath = 'folder1/folder2';
          fileSystem.goTo(mockPath);
          final expected = 'folder1/folder2';
          final response = fileSystem.content;
          expect(response, equals(expected));
        },
      );
      test(
        'go to the path from root step by step',
        () {
          fileSystem.goTo('folder1');
          fileSystem.goTo('folder2');
          final expected = 'folder1/folder2';
          final response = fileSystem.content;
          expect(response, equals(expected));
        },
      );
      test(
        'leave folders test',
        () {
          fileSystem.goTo('folder1');
          fileSystem.goTo('folder2');
          fileSystem.goTo('folder3');
          fileSystem.goTo('../..');
          fileSystem.goTo('folder4');
          final expected = 'folder1/folder4';
          final response = fileSystem.content;
          expect(expected, equals(response));
        },
      );
      test(
        'trim slashes from paths',
        () {
          fileSystem.goTo('/folder1/folder2/');
          fileSystem.goTo('folder3/');
          fileSystem.goTo('/../../');
          fileSystem.goTo('/folder4');
          final expected = 'folder1/folder4';
          final response = fileSystem.content;
          expect(response, equals(expected));
        },
      );
    },
  );
}
