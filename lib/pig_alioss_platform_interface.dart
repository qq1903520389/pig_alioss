import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pig_alioss_method_channel.dart';

abstract class PigAliossPlatform extends PlatformInterface {
  /// Constructs a PigAliossPlatform.
  PigAliossPlatform() : super(token: _token);

  static final Object _token = Object();

  static PigAliossPlatform _instance = MethodChannelPigAlioss();

  /// The default instance of [PigAliossPlatform] to use.
  ///
  /// Defaults to [MethodChannelPigAlioss].
  static PigAliossPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PigAliossPlatform] when
  /// they register themselves.
  static set instance(PigAliossPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> init(Map<String,String> map) {
    throw UnimplementedError('init() has not been implemented.');
  }
  Future<String?> fileUpload(String objectKey,String filePath,{Function(int progress)? progressCallback}) {
    throw UnimplementedError('fileUpload() has not been implemented.');
  }
  Future<String?> fileDownload( String objectKey,{Function(int progress)? progressCallback}) {
    throw UnimplementedError('fileDownload() has not been implemented.');
  }
  Future<String?> picSelector() {
    throw UnimplementedError('picSelector() has not been implemented.');
  }
}
