import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';

abstract class Executable {
  Stream<String> invoke(final Context<String> ctx, final Client client);
}