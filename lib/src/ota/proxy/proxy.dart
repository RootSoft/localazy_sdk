// ignore_for_file:implementation_imports
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';
import 'package:localazy_sdk/src/cdn/localazy_manager.dart';
import 'package:logger/logger.dart';

class MessageLookupProxy implements MessageLookup {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final MessageLookup _messageLookup;

  MessageLookupProxy.from(MessageLookup messageLookup)
      : _messageLookup = (messageLookup is UninitializedLocaleData) ? CompositeMessageLookup() : messageLookup;

  @override
  void addLocale(String localeName, Function findLocale) {
    _messageLookup.addLocale(localeName, findLocale);
  }

  @override
  String? lookupMessage(String? messageText, String? locale, String? name, List<Object>? args, String? meaning,
      {MessageIfAbsent? ifAbsent}) {
    try {
      var currentLocale = locale ?? Intl.getCurrentLocale();
      var message = LocalazyManager.getMessage(currentLocale, name, args);

      if (message == null || args == null) {
        return _messageLookup.lookupMessage(messageText, locale, name, args, meaning, ifAbsent: ifAbsent);
      }

      // var translation = label.getTranslation(argsMap);
      // if (translation == null) {
      //   _logger.w(
      //       "String '${label.key}' received Over-the-air for locale '$currentLocale' has not-well formatted message.");
      //   return _messageLookup.lookupMessage(messageText, locale, name, args, meaning, ifAbsent: ifAbsent);
      // }

      return message;
    } catch (e) {
      _logger.w('Failed to lookup message.', error: e);
      return _messageLookup.lookupMessage(messageText, locale, name, args, meaning, ifAbsent: ifAbsent);
    }
  }
}
