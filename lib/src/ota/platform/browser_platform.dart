import 'dart:html' as html;

import 'platform.dart';
import 'platform_exception.dart';
import '../model/persisted_release_data.dart';
import '../../common/util/util.dart';

Platform createPlatform() => BrowserPlatform();

class BrowserPlatform implements Platform {
  @override
  String getLocale() {
    return Util.canonicalizedLocale(html.window.navigator.language);
  }

  @override
  Future<PersistedReleaseData?> getPersistedReleaseData() =>
      throw PlatformException();

  @override
  Future<void> savePersistedReleaseData(PersistedReleaseData data) =>
      throw PlatformException();

  @override
  Future<void> removePersistedReleaseData() => throw PlatformException();
}
