import 'dart:convert';
import 'dart:io';

import 'package:localazy_sdk/src/arb/arb_parser.dart';
import 'package:localazy_sdk/src/cdn/api/localazy_service.dart';
import 'package:localazy_sdk/src/cdn/localazy_data.dart';
import 'package:localazy_sdk/src/cdn/models/localazy_config.dart';
import 'package:path/path.dart' as path;

class LocalazyCdnApi {
  LocalazyCdnApi._();

  static Future<LocalazyData?> getCachedData({
    required String cdnId,
    required String fileName,
    required String languageCode,
    required String cacheFolder,
  }) async {
    final config = await getCachedConfig(cdnId: cdnId, cacheFolder: cacheFolder);
    final translations = await getCachedTranslations(
      cdnId: cdnId,
      cacheFolder: cacheFolder,
      fileName: fileName,
      languageCode: languageCode,
    );

    if (config == null || translations == null) {
      return null;
    }

    final parser = ArbParser();
    final messages = parser.parse(languageCode, translations);

    return LocalazyData(
      config: config,
      messages: messages,
    );
  }

  static Future<LocalazyConfig?> getCachedConfig({
    required String cdnId,
    required String cacheFolder,
  }) async {
    final remoteConfigFileName = '${cdnId}_remote_config.json';
    final remoteConfigFile = File(path.join(cacheFolder, remoteConfigFileName));

    try {
      final content = await remoteConfigFile.readAsString();
      final config = LocalazyConfig.fromJSON(jsonDecode(content));

      return config;
    } catch (ex) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCachedTranslations({
    required String cdnId,
    required String cacheFolder,
    required String fileName,
    required String languageCode,
  }) async {
    final arbFileName = '${cdnId}_${languageCode}_$fileName';
    final arbFile = File(path.join(cacheFolder, arbFileName));

    try {
      final content = await arbFile.readAsString();
      final config = jsonDecode(content) as Map<String, dynamic>;

      return config;
    } catch (ex) {
      return null;
    }
  }

  static Future<LocalazyData> syncTranslations({
    required String cdnId,
    required String languageCode,
    required String fileName,
    required String cacheFolder,
    String? flavor,
  }) async {
    final remoteConfigFileName = '${cdnId}_remote_config.json';

    // Get the Localazy Config
    final config = await LocalazyService.getConfig(cdnId);

    // Store the config
    final remoteConfigFile = await File(path.join(cacheFolder, remoteConfigFileName)).create(recursive: true);
    await remoteConfigFile.writeAsBytes(config.toBytes());

    // Find the locale to load
    final file = config.getFile(fileName);
    final locale = file?.getLocale(languageCode);

    if (file == null || locale == null) {
      throw Exception('"$fileName" or "$languageCode" is not found on Localazy.');
    }

    // Fetch the translations
    final translations = await LocalazyService.getFileContents(locale);

    // Store the translations
    await _saveInCache(
      cdnId: cdnId,
      fileName: fileName,
      languageCode: locale.language,
      cacheFolder: cacheFolder,
      translations: translations,
    );

    final parser = ArbParser();
    final messages = parser.parse(languageCode, translations);

    return LocalazyData(
      config: config,
      messages: messages,
    );
  }

  static Future<void> _saveInCache({
    required String cdnId,
    required String fileName,
    required String languageCode,
    required String cacheFolder,
    required Map<String, dynamic> translations,
  }) async {
    final arbFileName = '${cdnId}_${languageCode}_$fileName';
    final arbFile = await File(path.join(cacheFolder, arbFileName)).create(recursive: true);
    await arbFile.writeAsString(jsonEncode(translations));
  }
}
