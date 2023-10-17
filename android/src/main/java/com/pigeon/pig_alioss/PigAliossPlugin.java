package com.pigeon.pig_alioss;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pigeon.pig_alioss.service.AliOssService;

import java.lang.ref.WeakReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/** PigAliossPlugin */
public class PigAliossPlugin implements FlutterPlugin, MethodCallHandler , ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private EventChannel eventChannel;
  private EventChannel.EventSink mSink;
  //事件派发流
  private EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
      mSink = sink;
//            System.out.println(".....................\n");
//            System.out.println("--------" + ((o != null) ? o.toString() : "") + "--------");
//            System.out.println("--------" + ((sink != null) ? sink.toString() : "") + "--------");
//            Toast.makeText(PigPayApplication.getContext(), "sdfasadf", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onCancel(Object o) {
      eventChannel = null;
      mSink = null;
    }
  };


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pig_alioss");
    channel.setMethodCallHandler(this);
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "plugins/pig_alioss_event");
    eventChannel.setStreamHandler(streamHandler);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "init":
        AliOssService.getInstance().init(call, result,mSink);
        break;
      case "fileUpload":
        AliOssService.getInstance().fileUpload(call, result,mSink);
        break;
      case "fileDownload":
        AliOssService.getInstance().fileDownload(call, result,mSink);
        break;
      case "picSelector":
        AliOssService.getInstance().picSelector(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }


  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    WeakReference<Activity> activity = new WeakReference<>(binding.getActivity());
    binding.addActivityResultListener(onActivityResultListener);
    PigAliOssApplication.setActivity(activity.get());
    PigAliOssApplication.setBinding(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    PigAliOssApplication.setBinding(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    PigAliOssApplication.setActivity(null);
  }

  PluginRegistry.ActivityResultListener onActivityResultListener = new PluginRegistry.ActivityResultListener() {
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
      AliOssService.getInstance().onActivityResult(requestCode,resultCode,data);
      return false;
    }
  };
}
