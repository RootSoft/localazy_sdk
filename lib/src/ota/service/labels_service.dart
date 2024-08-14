import '../../sdk_data.dart';
import '../api/api.dart';
import '../api/api_exception.dart';
import '../model/release_data.dart';
import '../store/store.dart';

class LabelsService {
  static Future<ReleaseData?> getPersistedReleaseData(String distributionId) {
    return Store.getReleaseData(distributionId);
  }

  static Future<int> getLabels(String cdnId) async {
    int newReleaseVersion;

    try {
      var project = await Api.getProjectData(cdnId);
      var labels = await Api.getArbFile('');
      var releaseData = ReleaseData(version: 1, data: labels);

      SdkData.releaseData = releaseData;
      await Store.persistReleaseData('1.0', releaseData);

      // newReleaseVersion = bundleInfo.version;
    } on ApiException catch (e) {
      // clear cached data if necessary
      if (e.errorCode == 'release_not_found') {
        SdkData.releaseData = null;
        await Store.removePersistedReleaseData();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }

    return 1;
  }
}
