import 'package:soera_archive/core/external/executable.dart';

abstract class Directive {
  Executable accept(final String param);
}