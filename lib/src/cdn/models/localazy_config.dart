import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:localazy_sdk/src/cdn/models/localazy_file.dart';

class LocalazyConfig {
  final List<LocalazyFile> files;

  LocalazyConfig(this.files);

  LocalazyFile? getFile(String fileName) {
    return files.firstWhereOrNull((element) {
      return element.file.toLowerCase() == fileName.toLowerCase();
    });
  }

  factory LocalazyConfig.fromJSON(Map<String, dynamic> json) {
    return LocalazyConfig(
      json['files']
          .entries
          .map((entry) => LocalazyFile.fromJSON(entry.key, entry.value))
          .toList(growable: false)
          .cast<LocalazyFile>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'files': {
        for (var file in files) file.id: file.toJson(),
      },
    };
  }

  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));
}
