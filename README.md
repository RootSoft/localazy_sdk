# Localazy SDK

[![pub package](https://img.shields.io/pub/v/localazy_sdk.svg)](https://pub.dev/packages/localazy_sdk)

This package provides [Over-the-Air translation updates](#over-the-air-translation-updates) from the Localazy platform on top of the Intl package.

## Platform Support

| Android | iOS | Web | MacOS | Linux | Windows |
| :-----: | :-: | :-: | :---: | :---: | :-----: |
|    ✔    |  ✔  |  ✔  |   ✔   |   ✔   |    ✔    |

## Over-the-Air translation updates

Update translations for your Flutter applications over the air. [Learn more](https://localazy.com/tags/ota)

Works with projects that use Flutter Intl IDE plugin / `intl_utils`.

### Setup for Flutter Intl

1\. Update `pubspec.yaml` file

<pre>
dependencies:
  ...
  <b>localazy_sdk: ^1.0.0</b>
</pre>

2\. Trigger localization files generation by Flutter Intl IDE plugin or by [intl_utils](https://pub.dev/packages/intl_utils) library

3\. Initialize Localazy SDK

<pre>
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
<b>import 'package:localazy_sdk/localazy_sdk.dart';</b>
import 'generated/l10n.dart';

void main() {
  Localazy.init(
    'cdn id',
    fileName: 'intl.arb',
    cacheFolder: path.join((await getTemporaryDirectory()).path, 'translations'),
  );
  Localazy.setAppVersion('1.0.0');

  runApp(
    LocalazyApp(
      router: router,
    ),
  );
}

class LocalazyApp extends StatelessWidget {
  final GoRouter router;

  const LocalazyApp({
    required this.router,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: Env.appName,
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return LocalazyBuilder(
          defaultLocale: Locale(Intl.getCurrentLocale()),
          supportedLocales: S.delegate.supportedLocales,
          builder: (context) => child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
</pre>

<br/>
