import 'package:soera_archive/app/config/app_config.dart';
import 'package:soera_archive/app/config/internal/injectable_config.dart';
import 'package:soera_archive/app/domain/cases/cd.dart';
import 'package:soera_archive/app/domain/cases/find.dart';
import 'package:soera_archive/app/domain/cases/ls.dart';
import 'package:soera_archive/app/domain/cases/pwd.dart';
import 'package:soera_archive/app/domain/entities/console.dart';
import 'package:soera_archive/app/domain/entities/file_system.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/api/yandex_rest.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/gateways/disk_resources.dart';
import 'package:soera_archive/app/infrastructure/yandex_disk/pipeline/yandex_ls_decoded_response.dart';
import 'package:soera_archive/core/external/bus.dart';
import 'package:soera_archive/core/external/executable.dart';

final class YandexDiskViaArchive implements Bus<AppConfig> {
  final String _token;

  const YandexDiskViaArchive({
    required final String token,
  }) : _token = token;

  Executable get _ls => const YandexLSDecodedResponse(
      origin: LS.using(
        generationStrategy: DiskResources(),
      ),
    );

  Console get _console => Console(
        ctx: FileSystem(),
        client: YandexRest(
          token: _token,
        ),
      );

  @override
  AppConfig config() {
    final ls = _ls;
    return InjectableConfig(
      console: _console,
      directives: {
        CD: CD(ls: ls),
        Find: Find(ls: ls),
      },
      executables: {
        LS: ls,
        PWD: PWD(ls: ls),
      },
    );
  }
}
