import 'package:glob/glob.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import './generator.dart';

Builder localizelyBuilder(BuilderOptions options) => LocalizelyBuilder();

class LocalizelyBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$package$': [
          '.dart_tool/flutter_gen/gen_l10n/localizely_localizations.dart'
        ]
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      final config = await getGenL10nConfig();
      final templateArbFilePath =
          path.join(config.arbDir, config.templateArbFile);

      await for (final input in buildStep.findAssets(Glob('**.arb'))) {
        final isTemplateArbFile = path.equals(input.path, templateArbFilePath);
        if (isTemplateArbFile) {
          final templateArbFileContents = await buildStep.readAsString(input);

          final lyLocalizationsFileContents =
              generateLyLocalizationsContents(templateArbFileContents, config);

          final lyLocalizationsFilePath =
              path.join(config.outputDir, 'localizely_localizations.dart');

          AssetId output =
              AssetId(buildStep.inputId.package, lyLocalizationsFilePath);

          await buildStep.writeAsString(output, lyLocalizationsFileContents);
        }
      }
    } on GenL10nException {
      // skip - missing config for gen_l10n indicates that another tool is used for localization (e.g. Flutter Intl)
    }
  }
}
