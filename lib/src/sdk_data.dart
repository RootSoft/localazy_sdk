import 'in_context_editing/model/in_context_editing_data.dart';
import 'ota/model/label.dart';
import 'ota/model/release_data.dart';

class SdkData {
  static String? appBuildNumber;
  static ReleaseData? releaseData;
  static InContextEditingData? inContextEditingData;

  SdkData._();

  static bool get hasReleaseData => releaseData != null;

  static bool get hasInContextEditingData => inContextEditingData != null;

  static int? get releaseVersion => releaseData?.version;

  static Map<String, Label>? getData(String locale) => releaseData?.data != null ? releaseData!.data[locale] : null;
}
