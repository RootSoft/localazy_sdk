import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:localazy_sdk/localazy_sdk.dart';

class LocalazyBuilder extends StatefulWidget {
  final Locale defaultLocale;
  final List<Locale> supportedLocales;
  final WidgetBuilder builder;

  const LocalazyBuilder({
    super.key,
    required this.defaultLocale,
    required this.supportedLocales,
    required this.builder,
  });

  @override
  State<LocalazyBuilder> createState() => _LocalazyBuilderState();
}

class _LocalazyBuilderState extends State<LocalazyBuilder> with WidgetsBindingObserver {
  List<String> _supportedLocales = [];

  @override
  void initState() {
    _supportedLocales = widget.supportedLocales.map((l) => l.languageCode).toList();

    updateTranslations(Intl.getCurrentLocale());
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    // final locale = findSupportedLocale(
    //   locales: locales ?? [],
    //   supportedLocales: widget.supportedLocales,
    //   defaultLocale: widget.defaultLocale,
    // );

    updateTranslations(Intl.getCurrentLocale());
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> updateTranslations(String locale) async {
    final supportsLocale = _supportedLocales.contains(Intl.shortLocale(locale));

    if (!supportsLocale) {
      return;
    }

    Localazy.setLocale(locale);
    Localazy.updateTranslations();
  }

  Locale findSupportedLocale({
    required List<Locale> locales,
    required List<Locale> supportedLocales,
    required Locale defaultLocale,
  }) {
    for (var locale in locales) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale; // Return the supported locale found
        }
      }
    }

    return defaultLocale;
  }
}
