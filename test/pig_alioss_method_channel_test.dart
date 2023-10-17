import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pig_alioss/pig_alioss_method_channel.dart';

void main() {
  MethodChannelPigAlioss platform = MethodChannelPigAlioss();
  const MethodChannel channel = MethodChannel('pig_alioss');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
