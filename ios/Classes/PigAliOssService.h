//
//  PigAliOssService.h
//  pig_alioss
//
//  Created by 周立强 on 2023/9/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <AliyunOSSiOS/OSSService.h>


NS_ASSUME_NONNULL_BEGIN

@interface PigAliOssService : NSObject<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nullable, nonatomic,strong) UIViewController *rootViewController API_AVAILABLE(ios(4.0));

@property (nonatomic, strong) FlutterResult flutterResult;
@property (nonatomic, strong) FlutterMethodCall *call;
@property (nonatomic, strong) FlutterEventSink eventSink;

@property (nonatomic, copy)   NSString *ossEndpoint;
@property (nonatomic, copy)   NSString *stsServerUrl;
@property (nonatomic, copy)   NSString *bucketName;
@property (nonatomic, copy)   NSString *imgServerUrl;
@property (nonatomic, copy)   NSString *callback;




+ (id) instance;

- (void)initOss:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult;
- (void)fileUpload:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink;
- (void)fileDownload:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink;
- (void)picSelector:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink;
- (BOOL)ossApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
@end

NS_ASSUME_NONNULL_END
