//
//  PigAliOssService.m
//  pig_alioss
//
//  Created by 周立强 on 2023/9/11.
//

#import "OSsTestMacros.h"

#import "PigAliOssService.h"
#import "DownloadService.h"
#import "OSSWrapper.h"
#import "OSSManager.h"



static id _instance = nil;  //定义static全局变量


@interface PigAliOssService ()
{
    NSString * uploadFilePath;
    int originConstraintValue;
}
@property (nonatomic, copy) NSString *downloadURLString;
@property (nonatomic, copy) NSString *headURLString;

@property (nonatomic, strong) OSSClient *mClient;
@property (nonatomic, strong) DownloadService *downloadService;
@property (nonatomic, strong) OSSWrapper *oss;


@end

@implementation PigAliOssService

+ (id) instance {
    // 先判断_instance是否为空
    if (_instance == nil) {
        // 为空则初始化
        _instance = [[self alloc] init];
    }
    // 返回实例
    return _instance;
}

- (void)initOss:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult{
    [self setCall:call];
    [self setFlutterResult:flutterResult];
    NSString *ossEndpoint = [call.arguments objectForKey:@"ossEndpoint"]!=nil?[call.arguments objectForKey:@"ossEndpoint"]:OSS_ENDPOINT;
    NSString *stsServerUrl = [call.arguments objectForKey:@"stsServerUrl"]!=nil?[call.arguments objectForKey:@"stsServerUrl"]:OSS_STSTOKEN_URL;
    NSString *callback = [call.arguments objectForKey:@"callback"]!=nil?[call.arguments objectForKey:@"callback"]:@"";
    NSString *imgServerUrl = [call.arguments objectForKey:@"imgServerUrl"]!=nil?[call.arguments objectForKey:@"imgServerUrl"]:@"";
    NSString *bucketName = [call.arguments objectForKey:@"bucketName"]!=nil?[call.arguments objectForKey:@"bucketName"]:OSS_BUCKET_PRIVATE;
    
    [[PigAliOssService instance] setOssEndpoint:ossEndpoint];
    [[PigAliOssService instance] setStsServerUrl:stsServerUrl];
    [[PigAliOssService instance] setImgServerUrl:imgServerUrl];
    [[PigAliOssService instance] setBucketName:bucketName];
    [[PigAliOssService instance] setCallback:callback];
    
    PigAliOssService* pigAliOssService = [PigAliOssService instance];
    
    // 针对只有一个region下bucket的数据上传下载操作时,可以将client实例给App单例持有。
    id<OSSCredentialProvider> credentialProvider = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:pigAliOssService.stsServerUrl];
    OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
    cfg.maxRetryCount = 3;
    cfg.timeoutIntervalForRequest = 15;
    cfg.isHttpdnsEnable = NO;
    cfg.crc64Verifiable = YES;
    
    OSSClient *defaultClient = [[OSSClient alloc] initWithEndpoint:pigAliOssService.ossEndpoint credentialProvider:credentialProvider clientConfiguration:cfg];
    [OSSManager sharedManager].defaultClient = defaultClient;
    
    OSSClient *defaultImgClient = [[OSSClient alloc] initWithEndpoint:pigAliOssService.ossEndpoint credentialProvider:credentialProvider clientConfiguration:cfg];
    [OSSManager sharedManager].imageClient = defaultImgClient;
    
    [OSSLog enableLog];// 开启sdk的日志功能
    [self setupOSS];
}

- (void)fileUpload:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink{
    [self setCall:call];
    [self setFlutterResult:flutterResult];
    [self setEventSink:eventSink];
    
    NSString *filePath = [call.arguments objectForKey:@"filePath"]!=nil?[call.arguments objectForKey:@"filePath"]:uploadFilePath;
    NSString *objectKey = [call.arguments objectForKey:@"objectKey"]!=nil?[call.arguments objectForKey:@"objectKey"]:@"";
    
    //NSString * key =  @"app/456.png";
    if (![self verifyFileName:objectKey]) {
        return;
    }
    
    NSString *funcStr = @"普通上传";
    //NSString * objectKey = key;
    [self.oss asyncPutImage:objectKey localFilePath:uploadFilePath andProgress:^(float progress) {
        NSString* eventchannelName = [NSString stringWithFormat:@"%f", progress];
        OSSLogDebug(@"上传文件进度: %f", progress);
        if(eventSink){
            eventSink([self msgResult:@1 andMsg:@"上传进度" andData:@{
                @"action":@"uploadProgress",
                @"progress":eventchannelName,
                @"objectKey":objectKey
            }]);
        }
        
    } success:^(id result) {
        NSDictionary *datas = (NSDictionary *)result;
        if(datas&&flutterResult){
            PigAliOssService* pigAliOssService = [PigAliOssService instance];
            NSString *objectKey = [datas objectForKey:@"objectKey"];
            NSString *filePath = [datas objectForKey:@"filePath"];
            NSString* path = [NSString stringWithFormat:@"%@%@",pigAliOssService.imgServerUrl,objectKey];
            flutterResult([self msgResult:@1 andMsg:@"上传成功" andData:@{
                @"url":path,
                @"filePath":filePath
            }]);
        }
        //[self showMessage:funcStr inputMessage:@"success"];
    } failure:^(NSError *error) {
        flutterResult([self msgResult:@0 andMsg:@"上传失败" andData:@{
            @"info":error.localizedDescription
        }]);
        //[self showMessage:funcStr inputMessage:error.localizedDescription];
    }];
}



- (void)fileDownload:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink{
    [self setCall:call];
    [self setFlutterResult:flutterResult];
    [self setEventSink:eventSink];
    
    NSString *objectKey = [call.arguments objectForKey:@"objectKey"]!=nil?[call.arguments objectForKey:@"objectKey"]:@"app/";
    

//    NSString * key =  @"app/456.png";
    if (![self verifyFileName:objectKey]) {
        return;
    }
    NSString *funcStr = @"普通下载";
//    NSString * objectKey = key;
    [self.oss asyncGetImage:objectKey andProgress:^(float progress) {
        NSString* eventchannelName = [NSString stringWithFormat:@"%f", progress];
        OSSLogDebug(@"下载文件进度: %f", progress);
        if(eventSink){
            eventSink([self msgResult:@1 andMsg:@"下载进度" andData:@{
                @"action":@"downloadProgress",
                @"progress":eventchannelName,
                @"objectKey":objectKey
            }]);
        }
       
    } success:^(id result) {
        NSDictionary *datas = (NSDictionary *)result;
        if(flutterResult&&datas){
            PigAliOssService* pigAliOssService = [PigAliOssService instance];
            NSString *objectKey = [datas objectForKey:@"objectKey"];
            NSString *filePath = [datas objectForKey:@"filePath"];
            NSString* path = [NSString stringWithFormat:@"%@%@",pigAliOssService.imgServerUrl,objectKey];
            flutterResult([self msgResult:@1 andMsg:@"下载成功" andData:@{
                @"url":path,
                @"filePath":filePath
            }]);
        }
//        [self showMessage:funcStr inputMessage:@"success"];
    } failure:^(NSError *error) {
        if(flutterResult){
            flutterResult([self msgResult:@0 andMsg:@"下载失败" andData:@{
                @"info":error.localizedDescription
            }]);
        }
//        [self showMessage:funcStr inputMessage:error.localizedDescription];
    }];
}




#pragma mark - cancelFileUpload 取消上传
- (void)cancelFileUpload:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult{
    uploadFilePath = @"";
}

//#pragma mark - triggerCallbackClicked 上传回调
//- (IBAction)triggerCallbackClicked:(id)sender {
//    NSString *funcStr = @"上传回调";
//
//    [self.oss triggerCallbackWithObjectKey:_ossTextFileName.text success:^(id result) {
//        [self showMessage:funcStr inputMessage:@"success"];
//    } failure:^(NSError *error) {
//        [self showMessage:funcStr inputMessage:error.localizedDescription];
//    }];
//}


- (BOOL)verifyFileName:(NSString *) objectKey{
    if (objectKey == nil || [objectKey length] == 0) {
        [self showMessage:@"填写错误" inputMessage:@"文件名不能为空！"];
        return NO;
    }
    return YES;
}

- (void)showMessage:(NSString *)putType
       inputMessage:(NSString*)message {
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:putType message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:defaultAction];
    [self.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - onOssButtonSelectPic 相册选择器和拍照
- (void)picSelector:(FlutterMethodCall*)call andResult:(FlutterResult)flutterResult andEvent:(FlutterEventSink) eventSink{
    [self setCall:call];
    [self setFlutterResult:flutterResult];
    [self setEventSink:eventSink];
    NSString * title = @"选择";
    NSString * cancelButtonTitle = @"取消";
    NSString * picButtonTitle = @"拍照";
    NSString * photoButtonTitle = @"从相册选择";
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * picAction = [UIAlertAction actionWithTitle:picButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.rootViewController presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction * photoAction = [UIAlertAction actionWithTitle:photoButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.rootViewController  presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:cancelAction];
        [alert addAction:picAction];
        [alert addAction:photoAction];
    } else {
        [alert addAction:cancelAction];
        [alert addAction:photoAction];
    }
    [self.rootViewController  presentViewController:alert animated:YES completion:nil];
}

#pragma mark - imagePickerController 相册选择器和拍照 --回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"image width:%f, height:%f", image.size.width, image.size.height);
    [self saveImage:image withName:@"currentImage"];
}
#pragma mark - imagePickerControllerDidCancel 相册选择器和拍照 --取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    if(self.eventSink){
//        self.eventSink([self msgResult:@0 andMsg:@"取消操作" andData:@{
//            @"type":@"picSelector",
//        }]);
//    }
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - saveImage 相册选择后 --保存
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
    uploadFilePath = fullPath;
    NSLog(@"uploadFilePath : %@", uploadFilePath);
    
    if(self.flutterResult){
        self.flutterResult([self msgResult:@1 andMsg:@"操作成功" andData:@{
            @"filePath":uploadFilePath
        }]);
    }
}



- (void)setupOSS {
    _oss = [[OSSWrapper alloc] init];
}
#pragma mark - initDownloadURLs 下载地址初始化
- (void)initDownloadURLs {
    OSSPlainTextAKSKPairCredentialProvider *pCredential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
    _mClient = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT credentialProvider:pCredential];
    OSSTask *downloadURLTask = [_mClient presignConstrainURLWithBucketName:@"pigeon-shop-app" withObjectKey:OSS_DOWNLOAD_FILE_NAME withExpirationInterval:1800];
    _downloadURLString = downloadURLTask.result;
    
    OSSTask *headURLTask = [_mClient presignConstrainURLWithBucketName:@"pigeon-shop-app" withObjectKey:OSS_DOWNLOAD_FILE_NAME httpMethod:@"HEAD" withExpirationInterval:1800 withParameters:nil];
    //    [OSSManager sharedManager]
    _headURLString = headURLTask.result;
}



- (NSString *)msgResult:(NSNumber *)state andMsg:(NSString *)msg{
 
    
    NSDictionary *resultDictionary =
    @{
        @"state":state,
        @"msg": msg,
    };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  jsonString;
}
- (NSString *)msgResult:(NSNumber *)state andMsg:(NSString *)msg andData:(NSDictionary *)data{
 
    
    NSDictionary *resultDictionary =
    @{
        @"state":state,
        @"msg": msg,
        @"data": data,
    };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  jsonString;
}


- (BOOL)ossApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    return YES;
}

@end
