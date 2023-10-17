//
//  FlutterPluginEvent.h
//  pig_alioss
//
//  Created by 周立强 on 2023/9/12.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PigAliOssFlutterPluginEvent : NSObject<FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterEventChannel* eventChannel;

@end

NS_ASSUME_NONNULL_END
