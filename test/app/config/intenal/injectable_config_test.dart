import 'package:mocktail/mocktail.dart';
import 'package:soera_archive/app/config/app_config.dart';
import 'package:soera_archive/app/config/internal/injectable_config.dart';
import 'package:soera_archive/app/domain/entities/console.dart';
import 'package:soera_archive/core/errors/entity_not_found.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/directive.dart';
import 'package:soera_archive/core/external/executable.dart';
import 'package:test/test.dart';

final class MockContext<Type> extends Mock implements Context<Type> {}

final class MockClient extends Mock implements Client {}

final class MockDirective extends Mock implements Directive {}

final class MockExecutable extends Mock implements Executable {}

void main() {
  group(
    'testing injectable config functionality',
    () {
      late AppConfig config;
      late Console console;
      late Directive directive;
      late Executable exe;
      setUp(() {
        console = Console(
          ctx: MockContext(),
          client: MockClient(),
        );
        directive = MockDirective();
        exe = MockExecutable();
        config = InjectableConfig(
          console: console,
          directives: {
            MockDirective: directive,
          },
          executables: {
            MockExecutable: exe,
          },
        );
      });
      test(
        'console getter should return internal console',
        () {
          final actual = config.console;
          expect(actual, equals(console));
        },
      );
      test(
        'found directive successfully',
        () {
          final response = config.directive<MockDirective>();
          expect(response, equals(directive));
        },
      );
      test(
        'found exe successfully',
        () {
          final response = config.executable<MockExecutable>();
          expect(response, equals(exe));
        },
      );
      test(
        'can\'t found directive by type',
        () {
          expect(
            () => config.directive<Fake>(),
            throwsA(
              isA<EntityNotFound>(),
            ),
          );
        },
      );
      test(
        'can\'t found exe by type',
        () {
          expect(
            () => config.executable<Fake>(),
            throwsA(
              isA<EntityNotFound>(),
            ),
          );
        },
      );
    },
  );
}
