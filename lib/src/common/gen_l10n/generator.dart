// This file incorporates work covered by the following copyright and
// permission notice:
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//
//     Redistribution and use in source and binary forms, with or without modification,
//     are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials provided
//     with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//     contributors may be used to endorse or promote products derived
//     from this software without specific prior written permission.
//
//     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//     ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//     --------------------------------------------------------------------------------
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//     Use of this source code is governed by a BSD-style license that can be
//     found in the LICENSE file.
//
// Partially modified code of the gen_l10n tool.
// https://github.com/flutter/flutter/tree/6428624c10424e846491f51422ebe6aa16278a6d

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import 'gen_l10n_types.dart';

Future<void> generate() async {
  final config = await getGenL10nConfig();

  final templateArbFilePath = path.join(config.arbDir, config.templateArbFile);
  final templateArbFile = File(templateArbFilePath);
  final templateArbFileContents = await templateArbFile.readAsString();

  final lyLocalizationsFileContents = generateLyLocalizationsContents(templateArbFileContents, config);

  File lyLocalizationsFile = File(path.join(config.outputDir, 'localizely_localizations.dart'));

  await lyLocalizationsFile.create(recursive: true);

  await lyLocalizationsFile.writeAsString(lyLocalizationsFileContents, mode: FileMode.writeOnly, flush: true);
}

String generateLyLocalizationsContents(String templateArbFileContents, GenL10nConfig config) {
  var buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/widgets.dart';");
  buffer.writeln("import 'package:flutter_localizations/flutter_localizations.dart';");
  buffer.writeln("import 'package:localazy_sdk/localizely_sdk.dart';");
  buffer.writeln('');
  buffer.writeln("import '${config.outputLocalizationFile}';");
  buffer.writeln('');
  buffer.writeln('class LocalizelyLocalizations extends ${config.outputClass} {');
  buffer.writeln('\tfinal ${config.outputClass} _fallback;');
  buffer.writeln('');
  buffer.writeln(
      '\tLocalizelyLocalizations(String locale, ${config.outputClass} fallback) : _fallback = fallback, super(locale);');
  buffer.writeln('');
  buffer.writeln(
      '\tstatic const LocalizationsDelegate<${config.outputClass}> delegate = _LocalizelyLocalizationsDelegate();');
  buffer.writeln('');
  buffer.writeln(
      '\tstatic const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[');
  buffer.writeln('\t\tdelegate,');
  buffer.writeln('\t\tGlobalMaterialLocalizations.delegate,');
  buffer.writeln('\t\tGlobalCupertinoLocalizations.delegate,');
  buffer.writeln('\t\tGlobalWidgetsLocalizations.delegate,');
  buffer.writeln('\t];');
  buffer.writeln('');
  buffer.writeln('\tstatic const List<Locale> supportedLocales = ${config.outputClass}.supportedLocales;');
  buffer.writeln('');

  var arb = AppResourceBundle.parse(templateArbFileContents);
  var messages = arb.resourceIds.map((id) => Message(arb.resources, id, false)).toList(growable: false);
  for (var message in messages) {
    var id = message.resourceId;

    buffer.writeln('\t@override');
    if (message.placeholders.isEmpty) {
      buffer.writeln("\tString get $id => LocalizelyGenL10n.getText(localeName, '$id') ?? _fallback.$id;");
    } else {
      var params = _generateMethodParameters(message).join(', ');
      var values = message.placeholders.map((placeholder) => placeholder.name).join(', ');
      var metadata = _generateMetadata(message);
      buffer.writeln(
          "\tString $id($params) => LocalizelyGenL10n.getText(localeName, '$id', [$values], $metadata) ?? _fallback.$id($values);");
    }
    buffer.writeln('');
  }
  buffer.writeln('}');
  buffer.writeln('');
  buffer.writeln('class _LocalizelyLocalizationsDelegate extends LocalizationsDelegate<${config.outputClass}> {');
  buffer.writeln('\tconst _LocalizelyLocalizationsDelegate();');
  buffer.writeln('');
  buffer.writeln('\t@override');
  buffer.writeln(
      '\tFuture<${config.outputClass}> load(Locale locale) => ${config.outputClass}.delegate.load(locale).then((fallback) {');
  buffer.writeln('\t\tLocalizelyGenL10n.setCurrentLocale(locale.toString());');
  buffer.writeln('\t\treturn LocalizelyLocalizations(locale.toString(), fallback);');
  buffer.writeln('\t});');
  buffer.writeln('');
  buffer.writeln('\t@override');
  buffer.writeln('\tbool isSupported(Locale locale) => ${config.outputClass}.supportedLocales.contains(locale);');
  buffer.writeln('');
  buffer.writeln('\t@override');
  buffer.writeln('\tbool shouldReload(_LocalizelyLocalizationsDelegate old) => false;');
  buffer.writeln('}');

  return buffer.toString();
}

Map<String, Object> _generateMetadata(Message message) {
  Map<String, Object> combine(Map<String, Object> acc, Map<String, Object> curr) => ({...acc, ...curr});

  return {
    '"@${message.resourceId}"': {
      '"placeholders"': {
        ...message.placeholders
            .map((placeholder) => ({
                  '"${placeholder.name}"': {
                    ...(placeholder.type != null
                        ? {
                            '"type"': '"${placeholder.type}"',
                          }
                        : {}),
                    ...(placeholder.format != null ? {'"format"': '"${placeholder.format}"'} : {}),
                    ...(placeholder.optionalParameters.isNotEmpty
                        ? {
                            '"optionalParameters"': {
                              ...placeholder.optionalParameters
                                  .map((optionalParameter) => ({
                                        '"${optionalParameter.name}"': optionalParameter.value is String
                                            ? '"${optionalParameter.value}"'
                                            : '${optionalParameter.value}'
                                      }))
                                  .fold(<String, Object>{}, combine)
                            }
                          }
                        : {}),
                    ...(placeholder.isCustomDateFormat == true ? {'"isCustomDateFormat"': '"true"'} : {})
                  }
                }))
            .fold(<String, Object>{}, combine)
      }
    }
  };
}

List<String> _generateMethodParameters(Message message) {
  assert(message.placeholders.isNotEmpty);
  final Placeholder? countPlaceholder = message.isPlural ? message.getCountPlaceholder() : null;
  return message.placeholders.map((Placeholder placeholder) {
    final String? type = placeholder == countPlaceholder ? 'num' : placeholder.type;
    return '$type ${placeholder.name}';
  }).toList();
}

Future<GenL10nConfig> getGenL10nConfig() async {
  File l10nFile = File('l10n.yaml');

  if (!await l10nFile.exists()) {
    throw GenL10nException("The 'l10n.yaml' file does not exist.");
  }

  String l10nFileContents = await l10nFile.readAsString();

  var l10nYaml = yaml.loadYaml(l10nFileContents);

  bool syntheticPackage = l10nYaml['synthetic-package'] ?? true;
  String arbDir = l10nYaml['arb-dir'] ?? path.join('lib', 'l10n');
  String outputDir =
      syntheticPackage ? path.join('.dart_tool', 'flutter_gen', 'gen_l10n') : l10nYaml['output-dir'] ?? arbDir;
  String templateArbFile = l10nYaml['template-arb-file'] ?? 'app_en.arb';
  String outputLocalizationFile = l10nYaml['output-localization-file'] ?? 'app_localizations.dart';
  String outputClass = l10nYaml['output-class'] ?? 'AppLocalizations';

  return GenL10nConfig(
    arbDir: arbDir,
    outputDir: outputDir,
    templateArbFile: templateArbFile,
    outputLocalizationFile: outputLocalizationFile,
    outputClass: outputClass,
    syntheticPackage: syntheticPackage,
  );
}

/// The configuration for the gen_l10n tool.
///
/// More info: https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#
class GenL10nConfig {
  String arbDir;
  String outputDir;
  String templateArbFile;
  String outputLocalizationFile;
  String outputClass;
  bool syntheticPackage;

  GenL10nConfig(
      {required this.arbDir,
      required this.outputDir,
      required this.templateArbFile,
      required this.outputLocalizationFile,
      required this.outputClass,
      required this.syntheticPackage});
}

class GenL10nException implements Exception {
  final String message;

  GenL10nException(this.message);

  @override
  String toString() => 'GenL10nException: $message';
}
