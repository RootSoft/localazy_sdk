import 'package:localazy_sdk/src/common/gen_l10n/localizely_gen_l10n.dart';
import 'package:localazy_sdk/src/in_context_editing/model/in_context_editing_data.dart';
import 'package:localazy_sdk/src/in_context_editing/model/translation_change_typed.dart';
import 'package:localazy_sdk/src/sdk_data.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'localizely_gen_l10n_test.mocks.dart';

@GenerateMocks([InContextEditingData])
void main() {
  setUp(() {
    SdkData.inContextEditingData = null;
  });

  group('Localizely gen_l10n interceptor for In-Context Editing', () {
    test('Test get translation when message is simple', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(
          TranslationChangeTyped(type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Literal message'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey);

      expect(response, equals('Literal message'));
    });

    test('Test get translation when message contains plain placeholder', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Message with {value}.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        'some value'
      ], {
        "@stringKey": {
          "placeholders": {
            "value": {"type": "String"}
          }
        }
      });

      expect(response, equals('Message with some value.'));
    });

    test('Test get translation when message contains formatted DateTime placeholder', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Message created: {date}.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        DateTime(2022, 5, 10, 12, 0)
      ], {
        "@stringKey": {
          "placeholders": {
            "date": {"type": "DateTime", "format": "yMd"}
          }
        }
      });

      expect(response, equals('Message created: 5/10/2022.'));
    });

    test('Test get translation when message contains custom formatted DateTime placeholder', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Message created: {date}.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        DateTime(2022, 5, 10, 12, 0)
      ], {
        "@stringKey": {
          "placeholders": {
            "date": {"type": "DateTime", "format": "EEE, M/d/y", "isCustomDateFormat": "true"}
          }
        }
      });

      expect(response, equals('Message created: Tue, 5/10/2022.'));
    });

    test('Test get translation when message contains formatted number placeholder', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Messages: {number}.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        1250000
      ], {
        "@stringKey": {
          "placeholders": {
            "number": {
              "type": "num",
              "format": "compactLong",
            }
          }
        }
      });

      expect(response, equals('Messages: 1.25 million.'));
    });

    test('Test get translation when message contains decimal-digits formatted number placeholder', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(
          TranslationChangeTyped(type: 'change_typed', locale: 'en_US', key: 'stringKey', value: 'Total: {amount}.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        1250000
      ], {
        "@stringKey": {
          "placeholders": {
            "amount": {
              "type": "num",
              "format": "currency",
              "optionalParameters": {"decimalDigits": 2, "symbol": "\$"}
            }
          }
        }
      });

      expect(response, equals('Total: \$1,250,000.00.'));
    });

    test('Test get translation when message is plural', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed',
          locale: 'en_US',
          key: 'stringKey',
          value: '{count, plural, =1 {{count} item} other {{count} items}}'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        5
      ], {
        "@stringKey": {
          "placeholders": {
            "count": {"type": "num"}
          }
        }
      });

      expect(response, equals('5 items'));
    });

    test('Test get translation when message is select', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed',
          locale: 'en_US',
          key: 'stringKey',
          value: '{gender, select, male {Mr {name}} female {Mrs {name}} other {User {name}}}'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        'female',
        'Jane'
      ], {
        "@stringKey": {
          "placeholders": {
            "gender": {"type": "String"},
            "name": {"type": "String"}
          }
        }
      });

      expect(response, equals('Mrs Jane'));
    });

    test('Test get translation when message is compound', () {
      var locale = 'en_US';
      var stringKey = 'stringKey';

      var mockedInContextEditingData = MockInContextEditingData();
      when(mockedInContextEditingData.getEditedData(locale, stringKey)).thenReturn(TranslationChangeTyped(
          type: 'change_typed',
          locale: 'en_US',
          key: 'stringKey',
          value:
              'The {gender, select, male {Mr {name}} female {Mrs {name}} other {User {name}}} has {count, plural, =1 {{count} apple} other {{count} apples}} and {amount} in pocket.'));
      SdkData.inContextEditingData = mockedInContextEditingData;

      var response = LocalizelyGenL10n.getText(locale, stringKey, [
        'male',
        'John',
        3,
        234.5
      ], {
        "@stringKey": {
          "placeholders": {
            "gender": {"type": "String"},
            "name": {"type": "String"},
            "count": {"type": "int"},
            "amount": {
              "type": "num",
              "format": "compactCurrency",
              "optionalParameters": {"decimalDigits": 2, "symbol": "\$"}
            }
          }
        }
      });

      expect(response, equals('Mr John has 3 apples and \$234.50 in pocket.'));
    }, skip: true, tags: 'not_implemented');
  });
}
