
import 'pig_alioss_platform_interface.dart';

class PigAlioss {
  Future<String?> getPlatformVersion() {
    return PigAliossPlatform.instance.getPlatformVersion();
  }
  Future<String?> init(Map<String,String> map) {
    return PigAliossPlatform.instance.init(map);
  }
  Future<String?> fileUpload( String objectKey,String filePath,{Function(int progress)? progressCallback})  {
    return PigAliossPlatform.instance.fileUpload(objectKey,filePath,progressCallback: progressCallback);
  }
  Future<String?> fileDownload( String objectKey,{Function(int progress)? progressCallback}) {
    return PigAliossPlatform.instance.fileDownload(objectKey,progressCallback: progressCallback);
  }
  Future<String?> picSelector() {
    return PigAliossPlatform.instance.picSelector();
  }
}
