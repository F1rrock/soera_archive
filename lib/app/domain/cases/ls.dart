import 'package:soera_archive/app/domain/gateways/expression.dart';
import 'package:soera_archive/core/external/client.dart';
import 'package:soera_archive/core/external/context.dart';
import 'package:soera_archive/core/external/executable.dart';

final class LS implements Executable {
  final Expression _generationStrategy;

  const LS.using({
    required final Expression generationStrategy,
  }) : _generationStrategy = generationStrategy;

  @override
  Stream<String> invoke(
    final Context<String> ctx,
    final Client client,
  ) async* {
    final currentPath = ctx.content;
    final expression = _generationStrategy.generateFrom(
      currentPath,
    );
    await client.commit(expression);
    yield* client.logs;
  }
}
