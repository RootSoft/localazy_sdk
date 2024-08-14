// This file incorporates work covered by the following copyright and
// permission notice:
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//
//     Redistribution and use in source and binary forms, with or without modification,
//     are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials provided
//     with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//     contributors may be used to endorse or promote products derived
//     from this software without specific prior written permission.
//
//     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//     ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//     --------------------------------------------------------------------------------
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//     Use of this source code is governed by a BSD-style license that can be
//     found in the LICENSE file.
//
// Partially modified code of the gen_l10n tool.
// https://github.com/flutter/flutter/tree/6428624c10424e846491f51422ebe6aa16278a6d

import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

import 'gen_l10n_types.dart';
import '../../ota/gen_l10n/gen_l10n.dart' as ota;
import '../../in_context_editing/gen_l10n/gen_l10n.dart' as inctx;

class LocalizelyGenL10n {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // This field represents the last loaded locale in the (gen_l10n) Flutter app.
  //
  // Note: A single app can load several locales simultaneously,
  // so this field should not be used for accessing the localization messages.
  static String? _currentLocale;

  static void setCurrentLocale(String locale) {
    _currentLocale = locale;
  }

  static String? getCurrentLocale() {
    return _currentLocale;
  }

  static String? getText(String locale, String stringKey,
      [List<Object> args = const [], Map<String, Object> metadata = const {}]) {
    var inctxText = inctx.getText(locale, stringKey);
    if (inctxText != null) {
      try {
        var message = Message(
          {stringKey: inctxText, ...metadata},
          stringKey,
          metadata.isNotEmpty,
        );

        return _handleMessage(locale, message, args);
      } catch (e) {
        _logger.w(
            "String '$stringKey' received in In-Context Editing for locale '$locale' has not-well formatted message.",
            error: e);
        return '\u26A0️ Invalid message';
      }
    }

    var otaText = ota.getText(locale, stringKey);
    if (otaText != null) {
      try {
        var message = Message(
          {stringKey: otaText, ...metadata},
          stringKey,
          metadata.isNotEmpty,
        );

        return _handleMessage(locale, message, args);
      } catch (e) {
        _logger.w(
            "String '$stringKey' received via Over-the-Air for locale '$locale' has not-well formatted message.",
            error: e);
        return null;
      }
    }

    return null;
  }

  static String? _handleMessage(
      String locale, Message message, List<Object> args) {
    if (message.isPlural) {
      return _handlePlural(locale, message, args);
    } else if (message.isSelect) {
      return _handleSelect(locale, message, args);
    } else if (message.placeholders.isNotEmpty) {
      return _handlePlaceholders(locale, message, message.value, args);
    } else {
      return message.value;
    }
  }

  static String? _handlePlaceholders(
      String locale, Message message, String? buffer,
      [List<Object> args = const []]) {
    if (buffer == null) return null;

    final countPlaceholder =
        message.isPlural ? message.getCountPlaceholder() : null;

    var placeholders = message.placeholders;
    for (var i = 0; i < placeholders.length; i++) {
      final arg = args[i];
      final placeholder = placeholders[i];
      final placeholderOptionalParameters = {
        for (var v in placeholder.optionalParameters) v.name: v.value
      };

      String result;
      if (placeholder.isDate) {
        result = _formatDateTime(locale, placeholder.format, arg as DateTime);
      } else if (placeholder.isNumber || placeholder == countPlaceholder) {
        result = _formatNumber(locale, placeholder.format,
            placeholderOptionalParameters, arg as num);
      } else {
        result = arg.toString();
      }

      buffer = buffer?.replaceAll('{${placeholder.name}}', result);
    }

    return buffer;
  }

  static String _formatDateTime(String locale, String? format, DateTime value) {
    return intl.DateFormat(format, locale).format(value);
  }

  static String _formatNumber(String locale, String? format,
      Map<String, Object> optionalParameters, num value) {
    switch (format) {
      case 'compact':
        return intl.NumberFormat.compact(locale: locale).format(value);
      case 'compactCurrency':
        return intl.NumberFormat.compactCurrency(
                locale: locale,
                name: optionalParameters['name'] as String?,
                symbol: optionalParameters['symbol'] as String?,
                decimalDigits: optionalParameters['decimalDigits'] as int?)
            .format(value);
      case 'compactSimpleCurrency':
        return intl.NumberFormat.compactSimpleCurrency(
                locale: locale,
                name: optionalParameters['name'] as String?,
                decimalDigits: optionalParameters['decimalDigits'] as int?)
            .format(value);
      case 'compactLong':
        return intl.NumberFormat.compactLong(locale: locale).format(value);
      case 'currency':
        return intl.NumberFormat.currency(
                locale: locale,
                name: optionalParameters['name'] as String?,
                symbol: optionalParameters['symbol'] as String?,
                decimalDigits: optionalParameters['decimalDigits'] as int?,
                customPattern: optionalParameters['customPattern'] as String?)
            .format(value);
      case 'decimalPattern':
        return intl.NumberFormat.decimalPattern().format(value);
      case 'decimalPercentPattern':
        return intl.NumberFormat.decimalPercentPattern(
                locale: locale,
                decimalDigits: optionalParameters['decimalDigits'] as int?)
            .format(value);
      case 'percentPattern':
        return intl.NumberFormat.percentPattern().format(value);
      case 'scientificPattern':
        return intl.NumberFormat.scientificPattern().format(value);
      case 'simpleCurrency':
        return intl.NumberFormat.simpleCurrency(
                locale: locale,
                name: optionalParameters['name'] as String?,
                decimalDigits: optionalParameters['decimalDigits'] as int?)
            .format(value);
      default:
        return value.toString();
    }
  }

  static String? _handlePlural(String locale, Message message,
      [List<Object> args = const []]) {
    const pluralIds = ['=0', '=1', '=2', 'few', 'many', 'other'];

    final String easyMessage =
        _replacePlaceholdersBraces(message.value, message.placeholders, '##');

    var processedPluralIds = pluralIds
        .map((key) => _extractPlural(easyMessage, key))
        .map((extracted) => message.placeholders.fold<String?>(
            extracted,
            (extracted, placeholder) => extracted?.replaceAll(
                '#${placeholder.name}#', '{${placeholder.name}}')))
        .map((normalized) =>
            _handlePlaceholders(locale, message, normalized, args))
        .toList(growable: false);

    final Placeholder countPlaceholder = message.getCountPlaceholder();
    num howMany = args[message.placeholders.indexOf(countPlaceholder)] as num;

    return intl.Intl.pluralLogic(
      howMany,
      locale: locale,
      zero: processedPluralIds[0],
      one: processedPluralIds[1],
      two: processedPluralIds[2],
      few: processedPluralIds[3],
      many: processedPluralIds[4],
      other: processedPluralIds[5],
    );
  }

  static String? _extractPlural(String easyMessage, String pluralKey) {
    final expRE = RegExp('($pluralKey)\\s*{([^}]+)}');
    final match = expRE.firstMatch(easyMessage);
    if (match != null && match.groupCount == 2) {
      return match.group(2)!;
    } else {
      return null;
    }
  }

  static String? _handleSelect(String locale, Message message,
      [List<Object> args = const []]) {
    final String easyMessage =
        _replacePlaceholdersBraces(message.value, message.placeholders, '##');

    final Map<Object, String> cases = {};

    final RegExpMatch? selectMatch =
        RegExp(r'\{([\w\s,]*),\s*select\s*,\s*([\w\d]+\s*\{.*\})+\s*\}')
            .firstMatch(easyMessage);
    String? choice;
    if (selectMatch != null && selectMatch.groupCount == 2) {
      choice = selectMatch.group(1);
      final String pattern = selectMatch.group(2)!;
      final RegExp patternRE = RegExp(r'\s*([\w\d]+)\s*\{(.*?)\}');
      for (final RegExpMatch patternMatch in patternRE.allMatches(pattern)) {
        if (patternMatch.groupCount == 2) {
          String value = patternMatch
              .group(2)!
              .replaceAll("'", r"\'")
              .replaceAll('"', r'\"');

          value = message.placeholders.fold(
              value,
              (previousValue, placeholder) => value.replaceAll(
                  '#${placeholder.name}#', '{${placeholder.name}}'));

          value = _handlePlaceholders(locale, message, value, args)!;

          cases.putIfAbsent(patternMatch.group(1)!, () => value);
        }
      }
    }

    if (choice == null || cases.isEmpty) {
      return null;
    }

    int index = message.placeholders
        .indexWhere((placeholder) => placeholder.name == choice);
    Object choiceValue = args[index];

    return intl.Intl.select(choiceValue, cases);
  }

  /// To make it easier to parse plurals or select messages, temporarily replace
  /// each "{placeholder}" parameter with "#placeholder#" for example.
  static String _replacePlaceholdersBraces(
    String translationForMessage,
    Iterable<Placeholder> placeholders,
    String replacementBraces,
  ) {
    assert(replacementBraces.length == 2);
    String easyMessage = translationForMessage;
    for (final Placeholder placeholder in placeholders) {
      easyMessage = easyMessage.replaceAll(
        '{${placeholder.name}}',
        '${replacementBraces[0]}${placeholder.name}${replacementBraces[1]}',
      );
    }
    return easyMessage;
  }
}
