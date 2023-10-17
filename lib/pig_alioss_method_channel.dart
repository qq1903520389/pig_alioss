import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;

import 'pig_alioss_platform_interface.dart';

typedef progressCallback = Function(int progress);
/// An implementation of [PigAliossPlatform] that uses method channels.
class MethodChannelPigAlioss extends PigAliossPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pig_alioss');

  late Stream<dynamic> _eventStream;

  MethodChannelPigAlioss(){
    _eventStream =  const EventChannel("plugins/pig_alioss_event")
        .receiveBroadcastStream();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<String?> init(Map<String,String> map) async {

    final version = await methodChannel.invokeMethod<String>('init',map);
    return version;
  }
  @override
  Future<String?> fileUpload(String objectKey,String filePath,{Function(int progress)? progressCallback}) async {
    _eventStream.listen((dynamic event){
      Map<String, dynamic> user = convert.jsonDecode(event);
      if(objectKey==user["data"]["objectKey"]){
        progressCallback!(user["data"]["progress"]);
      }
    }, onError: (Object obj) {
      final PlatformException e = obj as PlatformException;
      throw e;
    }, onDone: (){
    }, cancelOnError: false);
    final version = await methodChannel.invokeMethod<String>('fileUpload',{"objectKey":objectKey,"filePath":filePath});
    return version;
  }
  @override
  Future<String?> fileDownload(String objectKey,{Function(int progress)? progressCallback}) async {
    _eventStream.listen((dynamic event){
      Map<String, dynamic> user = convert.jsonDecode(event);
      if(objectKey==user["data"]["objectKey"]){
        progressCallback!(user["data"]["progress"]);
      }
    }, onError: (Object obj) {
      final PlatformException e = obj as PlatformException;
      throw e;
    }, onDone: (){
    }, cancelOnError: false);
    final version = await methodChannel.invokeMethod<String>('fileDownload',{"objectKey":objectKey});
    return version;
  }

  @override
  Future<String?> picSelector() async {
    String? version = await methodChannel.invokeMethod<String>('picSelector');
    Map<String, dynamic> user = convert.jsonDecode(version!);
    return user["data"]["filePath"];
  }
}
