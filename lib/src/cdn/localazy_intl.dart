import 'package:intl_generator/generate_localized.dart';

final Map<String, List<String>> metaData = {};
// Flavor => Locale => sentences {flavor: {en: {test: message}}}
final Map<String, Map<String, Map<String, Message>>> _messages = {};

/// Delegate to manage locales and flavors
class LocalazyIntl {
  static const defaultFlavorName = 'default';

  // Default locale of your app, this will be use to fallback to this locale
  final String defaultLocale;

  // Default flavor of your app, this will be use to fallback to this flavor
  final String defaultFlavor;

  String _currentFlavor = defaultFlavorName;

  LocalazyIntl(this.defaultLocale, this.defaultFlavor);
}
