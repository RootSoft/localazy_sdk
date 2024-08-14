import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../util/util.dart';
import 'api_exception.dart';

class Api {
  static final String _baseUrl = 'https://delivery.localazy.com';

  Api._();

  static Future<Map<String, dynamic>> getProjectData(String cdnId) async {
    var uri = '$_baseUrl/$cdnId/_e0.v2.json';

    var response = await http.get(Uri.parse(uri));
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch bundle info', response.statusCode, Util.formatJsonMessage(response.body));
    }

    var jsonResponse = convert.jsonDecode(response.body);

    return jsonResponse;
  }

  static Future<Map<String, dynamic>> getArbFile(String uri) async {
    var response = await http.get(Uri.parse(
        'https://delivery.localazy.com/_a771516613839971759118509cfb/_e0/902617aee1039c084b97abcd24756dda1f120cdc/en/intl.arb'));

    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch bundle data', response.statusCode, Util.formatJsonMessage(response.body));
    }

    var jsonResponse = convert.jsonDecode(response.body);

    return jsonResponse;
  }
}
