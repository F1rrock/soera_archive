import 'package:soera_archive/app/domain/entities/console.dart';
import 'package:soera_archive/core/external/directive.dart';
import 'package:soera_archive/core/external/executable.dart';

abstract class AppConfig {
  Directive directive<Entity>();
  Executable executable<Entity>();
  Console get console;
}