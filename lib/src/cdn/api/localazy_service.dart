import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localazy_sdk/src/cdn/models/localazy_config.dart';
import 'package:localazy_sdk/src/cdn/models/localazy_locale.dart';
import 'package:localazy_sdk/src/common/api/api_exception.dart';
import 'package:localazy_sdk/src/common/util/util.dart';

class LocalazyService {
  static final String _baseUrl = 'https://delivery.localazy.com';

  LocalazyService._();

  static Future<LocalazyConfig> getConfig(String cdnId) async {
    var uri = '$_baseUrl/$cdnId/_e0.v2.json';

    var response = await http.get(Uri.parse(uri));
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch bundle info', response.statusCode, Util.formatJsonMessage(response.body));
    }

    var jsonResponse = convert.jsonDecode(response.body);

    return LocalazyConfig.fromJSON(jsonResponse);
  }

  static Future<Map<String, dynamic>> getFileContents(LocalazyLocale locale) async {
    var response = await http.get(Uri.parse('$_baseUrl${locale.uri}'));

    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch bundle data', response.statusCode, Util.formatJsonMessage(response.body));
    }

    // Manually decode the body with UTF-8 encoding
    // Converting response body to bytes
    final bytes = response.bodyBytes;

    // Decoding bytes with utf8 to handle special characters
    final jsonString = utf8.decode(bytes);

    final jsonResponse = jsonDecode(jsonString);

    return jsonResponse;
  }
}
