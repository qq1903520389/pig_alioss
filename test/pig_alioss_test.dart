import 'package:flutter_test/flutter_test.dart';
import 'package:pig_alioss/pig_alioss.dart';
import 'package:pig_alioss/pig_alioss_platform_interface.dart';
import 'package:pig_alioss/pig_alioss_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPigAliossPlatform 
    with MockPlatformInterfaceMixin
    implements PigAliossPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  

  @override
  Future<String?> init(Map<String, String> map) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<String?> picSelector() {
    // TODO: implement picSelector
    throw UnimplementedError();
  }

  @override
  Future<String?> fileDownload(String objectKey, {Function(int progress)? progressCallback}) {
    // TODO: implement fileDownload
    throw UnimplementedError();
  }

  @override
  Future<String?> fileUpload(String objectKey, String filePath, {Function(int progress)? progressCallback}) {
    // TODO: implement fileUpload
    throw UnimplementedError();
  }

  

}

void main() {
  final PigAliossPlatform initialPlatform = PigAliossPlatform.instance;

  test('$MethodChannelPigAlioss is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPigAlioss>());
  });

  test('getPlatformVersion', () async {
    PigAlioss pigAliossPlugin = PigAlioss();
    MockPigAliossPlatform fakePlatform = MockPigAliossPlatform();
    PigAliossPlatform.instance = fakePlatform;
  
    expect(await pigAliossPlugin.getPlatformVersion(), '42');
  });
}
