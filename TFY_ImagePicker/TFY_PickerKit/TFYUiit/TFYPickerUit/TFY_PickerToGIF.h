//
//  TFY_PickerToGIF.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <CoreServices/CoreServices.h>
#import <WebKit/WebKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TFYGIFSize) {
    TFYGIFSizeVeryLow  = 2,
    TFYGIFSizeLow      = 3,
    TFYGIFSizeMedium   = 5,
    TFYGIFSizeHigh     = 7,
    TFYGIFSizeOriginal = 10
};

@interface TFY_PickerToGIF : NSObject

/**
 解析视频转换为GIF图片

  videoURL 视频地址
  loopCount 循环次数 0=无限循环
  completionBlock 回调gif地址
 */
+ (void)optimalGIFfromURL:(NSURL*)videoURL loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock;

/**
 解析视频转换为GIF图片

  videoURL 视频地址
  delayTime 每张图片的停留时间
  loopCount 循环次数 0=无限循环
  TFYGIFSize gif图片质量
  completionBlock 回调gif地址
 */
+ (void)createGIFfromURL:(NSURL*)videoURL delayTime:(NSTimeInterval)delayTime loopCount:(NSUInteger)loopCount TFYGIFSize:(TFYGIFSize)TFYGIFSize completion:(void(^)(NSURL *GifURL))completionBlock;

@end

NS_ASSUME_NONNULL_END
