import 'dart:convert' as convert;

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum CodeGenerator { flutterIntl, genL10n }

class Util {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  static Future<String?> getAppBuildNumber() async {
    String? appBuildNumber;

    try {
      var packageInfo = await PackageInfo.fromPlatform();
      appBuildNumber = packageInfo.version;
    } catch (e) {
      _logger.w('Failed to detect app version');
    }

    return appBuildNumber;
  }

  /// Converts to inline json message.
  static String formatJsonMessage(String jsonMessage) {
    try {
      var decoded = convert.jsonDecode(jsonMessage);
      return convert.jsonEncode(decoded);
    } catch (e) {
      return jsonMessage;
    }
  }

  static bool isValidSemanticVersion(String value) {
    final maxSegmentValue = 2147483647;
    final semanticVersionRegExp = RegExp(r'^([0-9]+)\.([0-9]+)\.([0-9]+)$');

    if (semanticVersionRegExp.hasMatch(value)) {
      var segments = value.split('.');
      var exceededSegments = segments.where((segment) => int.parse(segment) > maxSegmentValue);

      return exceededSegments.isEmpty;
    }

    return false;
  }

  static CodeGenerator? detectCodeGenerator() {
    return CodeGenerator.flutterIntl;
  }

  static bool isMetadataSet() => detectCodeGenerator() != null;

  static String getCurrentLocale() {
    return Intl.getCurrentLocale();
  }
}
