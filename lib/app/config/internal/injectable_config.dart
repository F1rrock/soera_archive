import 'package:soera_archive/app/config/app_config.dart';
import 'package:soera_archive/app/domain/entities/console.dart';
import 'package:soera_archive/core/errors/entity_not_found.dart';
import 'package:soera_archive/core/external/directive.dart';
import 'package:soera_archive/core/external/executable.dart';

final class InjectableConfig implements AppConfig {
  final Console _console;
  final Map<Type, Directive> _directives;
  final Map<Type, Executable> _executables;

  const InjectableConfig({
    required final Console console,
    required final Map<Type, Directive> directives,
    required final Map<Type, Executable> executables,
  })  : _console = console,
        _directives = directives,
        _executables = executables;

  @override
  Console get console => _console;

  @override
  Directive directive<Entity>() {
    final response = _directives[Entity];
    if (response == null) {
      throw const EntityNotFound();
    }
    return response;
  }

  @override
  Executable executable<Entity>() {
    final response = _executables[Entity];
    if (response == null) {
      throw const EntityNotFound();
    }
    return response;
  }
}
