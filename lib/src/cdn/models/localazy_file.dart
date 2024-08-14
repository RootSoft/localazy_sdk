import 'package:collection/collection.dart';
import 'package:localazy_sdk/src/cdn/models/localazy_locale.dart';

class LocalazyFile {
  final String id;
  final String file;
  final String library;
  final String module;
  final String buildType;
  final String timestamp;
  final List<String> productFlavors;
  final List<LocalazyLocale> locales;

  LocalazyFile({
    required this.id,
    required this.file,
    required this.locales,
    required this.library,
    required this.module,
    required this.buildType,
    required this.productFlavors,
    required this.timestamp,
  });

  LocalazyLocale? getLocale(String locale) {
    return locales.firstWhereOrNull((element) {
      final fileLocale = element.region.isEmpty ? element.language : '${element.language}_${element.region}';
      return fileLocale.toLowerCase() == locale.toLowerCase();
    });
  }

  factory LocalazyFile.fromJSON(String id, Map<String, dynamic> data) {
    return LocalazyFile(
      id: id,
      file: data['file'],
      locales:
          data['locales'].map((data) => LocalazyLocale.fromJSON(data)).cast<LocalazyLocale>().toList(growable: false),
      buildType: data['buildType'],
      module: data['module'],
      library: data['library'],
      productFlavors: data['productFlavors'].cast<String>(),
      timestamp: data['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file': file,
      'locales': locales.map((locale) => locale.toJson()).toList(),
      'buildType': buildType,
      'module': module,
      'library': library,
      'productFlavors': productFlavors,
      'timestamp': timestamp,
    };
  }
}
