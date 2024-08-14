import 'package:intl_generator/generate_localized.dart';

// Flavor => Locale => sentences {flavor: {en: {test: message}}}
final Map<String, Map<String, Map<String, Message>>> _messages = {};

class ArbFile {
  final String locale;
  final Map<String, dynamic> content;
  final Map<String, List<String>> metaData;

  ArbFile({
    required this.locale,
    required this.content,
    required this.metaData,
  });

  factory ArbFile.parse(Map<String, dynamic> labels) {
    final Map<String, List<String>> metaData = {};

    labels.forEach((String id, messageData) {
      if (id.startsWith('@@')) {
        return;
      }

      if (id.startsWith('@')) {
        if (messageData.containsKey('placeholders_order')) {
          metaData[id.substring(1).toLowerCase()] = messageData['placeholders_order']!.cast<String>();
        } else if (messageData.containsKey('placeholders')) {
          metaData[id.substring(1).toLowerCase()] = Map.from(messageData['placeholders']!).keys.cast<String>().toList();
        } else {
          throw StateError('No metadata in ARB for $id, metadata are used to know arguments order, it\'s mandatory');
        }
      }
    });

    return ArbFile(
      locale: 'en',
      content: labels,
      metaData: metaData,
    );
  }
}
