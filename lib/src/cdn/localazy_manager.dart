import 'package:intl/intl.dart';
import 'package:intl_generator/generate_localized.dart';
import 'package:localazy_sdk/src/cdn/localazy_data.dart';

String _getString(String locale, String id, Message message, List<Object> args, Map<String, List<String>> metadata) {
  if (message is LiteralString) {
    return message.string;
  } else if (message is CompositeMessage) {
    final s = StringBuffer();
    for (var element in message.pieces) {
      s.write(_getString(locale, id, element, args, metadata));
    }
    return s.toString();
  }
  if (message is VariableSubstitution) {
    final index = metadata[id]!.indexWhere((key) => key.toLowerCase() == message.variableName.toLowerCase());
    if (index == -1 && args.length > 1) {
      throw StateError(
          'No meta data "placeholders_order" found for $id, be sure you generate your ARB with intl_generator or intl_flavors');
    }
    return index == -1 ? args.first.toString() : args[index].toString();
  } else if (message is Gender) {
    final index = metadata[id]!.indexWhere((key) => key.toLowerCase() == message.mainArgument!.toLowerCase());
    return Intl.genderLogic(
      args[index].toString(),
      locale: locale,
      other: _getString(locale, id, message.other!, args, metadata),
      male: _getString(locale, id, message.male ?? message.other!, args, metadata),
      female: _getString(locale, id, message.female ?? message.other!, args, metadata),
    );
  } else if (message is Plural) {
    final index = metadata[id]!.indexWhere((key) => key.toLowerCase() == message.mainArgument!.toLowerCase());
    return Intl.pluralLogic(
      args[index] as num,
      locale: locale,
      other: _getString(locale, id, message.other!, args, metadata),
      few: _getString(locale, id, message.few ?? message.other!, args, metadata),
      many: _getString(locale, id, message.many ?? message.other!, args, metadata),
      one: _getString(locale, id, message.one ?? message.other!, args, metadata),
      two: _getString(locale, id, message.two ?? message.other!, args, metadata),
      zero: _getString(locale, id, message.zero ?? message.other!, args, metadata),
    );
  } else {
    print('Unsupported type ${message.runtimeType}');
  }
  return '';
}

class LocalazyManager {
  static String? appBuildNumber;
  static LocalazyData? config;
  static String? locale;

  LocalazyManager._();

  static bool get hasReleaseData => config?.messages != null;

  static String? getMessage(
    String? locale,
    String? name,
    List<Object>? args,
  ) {
    // If passed null, use the default.
    final knownLocale = Intl.shortLocale(locale ?? LocalazyManager.locale ?? 'en');
    final metadata = config?.messages?.metadata;
    final messages = config?.messages?.messages[knownLocale];

    if (name == null || messages == null || metadata == null) {
      return null;
    }

    if (!messages.containsKey(name)) {
      return null;
    }

    final sentence = messages[name];
    if (sentence == null) {
      return null;
    }

    try {
      return _getString(knownLocale, name.toLowerCase(), sentence, args ?? [], metadata);
    } catch (ex) {
      return null;
    }
  }
}
