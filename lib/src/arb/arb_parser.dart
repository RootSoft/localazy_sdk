import 'package:intl_generator/generate_localized.dart';
import 'package:localazy_sdk/src/arb/arb_messages.dart';

class ArbParser {
  ArbMessages parse(String locale, Map<String, dynamic> data) {
    final metadata = parseMetaData(data);
    final messages = parseMessages(locale, data);

    return ArbMessages(
      metadata: metadata,
      messages: messages,
    );
  }

  Map<String, List<String>> parseMetaData(Map<String, dynamic> messages) {
    final Map<String, List<String>> metaData = {};

    messages.forEach((String id, messageData) {
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

    return metaData;
  }

  Map<String, Map<String, Message>> parseMessages(String locale, Map<String, dynamic> data) {
    final Map<String, Map<String, Message>> _messages = {};

    Map<String, Message> messages = {};

    data.forEach((id, messageData) {
      TranslatedMessage? message = _recreateIntlObjects(id, messageData, data['@$id'] ?? {});
      if (message != null) {
        messages[message.id] = message.translated!;
      }
    });

    if (_messages.containsKey(locale)) {
      _messages[locale]!.addAll(messages);
    } else {
      _messages[locale] = messages;
    }

    return _messages;
  }
}

/// Regenerate the original IntlMessage objects from the given [data]. For
/// things that are messages, we expect [id] not to start with "@" and
/// [data] to be a String. For metadata we expect [id] to start with "@"
/// and [data] to be a Map or null. For metadata we return null.
_BasicTranslatedMessage? _recreateIntlObjects(String id, data, Map metaData) {
  if (id.startsWith("@")) return null;
  if (data == null) return null;
  var parsed = _pluralAndGenderParser.parse(data).value;
  if (parsed is LiteralString && parsed.string.isEmpty) {
    parsed = _plainParser.parse(data).value;
  }
  return _BasicTranslatedMessage(id, parsed, metaData);
}

/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class _BasicTranslatedMessage extends TranslatedMessage {
  Map metaData;

  _BasicTranslatedMessage(String name, translated, this.metaData) : super(name, translated);

  @override
  List<MainMessage> get originalMessages =>
      (super.originalMessages.isEmpty) ? _findOriginals() : super.originalMessages;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  List<MainMessage> _findOriginals() => originalMessages = [];
}

final _pluralAndGenderParser = IcuParser().message;
final _plainParser = IcuParser().nonIcuMessage;
