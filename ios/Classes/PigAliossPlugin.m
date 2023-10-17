#import "PigAliossPlugin.h"
#import "PigAliOssService.h"
#import "PigAliOssFlutterPluginEvent.h"

@implementation PigAliossPlugin

//事件处理
PigAliOssFlutterPluginEvent *pluginEvent;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"pig_alioss"
                                     binaryMessenger:[registrar messenger]];
    PigAliossPlugin* instance = [[PigAliossPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
    
    //事件处理
    pluginEvent = [[PigAliOssFlutterPluginEvent alloc] init];
    //NSString* eventchannelName = [NSString stringWithFormat:@"plugins/activity_indicator_event_%lld", viewId];
    NSString* eventchannelName = @"plugins/pig_alioss_event";
    pluginEvent.eventChannel = [FlutterEventChannel
                                eventChannelWithName:eventchannelName
                                binaryMessenger:[registrar messenger]];
    [pluginEvent.eventChannel setStreamHandler:pluginEvent];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        
        [[PigAliOssService instance] initOss:call andResult:result];
        result(@"初始化成功");
        
    } else if ([@"fileUpload" isEqualToString:call.method]) {
        [[PigAliOssService instance] fileUpload:call andResult:result andEvent:pluginEvent.eventSink];
    } else if ([@"fileDownload" isEqualToString:call.method]) {
        [[PigAliOssService instance] fileDownload:call andResult:result andEvent:pluginEvent.eventSink];
    } else if ([@"picSelector" isEqualToString:call.method]) {
        [[PigAliOssService instance] picSelector:call andResult:result andEvent:pluginEvent.eventSink];
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.rootViewController = application.delegate.window.rootViewController;
    
    [[PigAliOssService instance] setRootViewController:self.rootViewController];
    [[PigAliOssService instance] ossApplication:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

@end
