//
//  TFY_GifPlayerManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GifExecution) (CGImageRef imageData, NSString *key);
typedef void (^GifFail) (NSString *key);

@interface TFY_GifPlayerManager : NSObject

+ (TFY_GifPlayerManager *)shared;
/** 释放 */
+ (void)free;

/** 停止播放 */
- (void)stopGIFWithKey:(NSString *)key;
/** 暂停播放 */
- (void)suspendGIFWithKey:(NSString *)key;
/** 恢复播放 */
- (void)resumeGIFWithKey:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock;
/** 是否播放 */
- (BOOL)isGIFPlaying:(NSString *)key;
/** 是否存在 */
- (BOOL)containGIFKey:(NSString *)key;

/**
 *   lincf, 16-09-14 14:09:21
 *
 *  播放gif
 *
 *   gifPath        文件路径
 *   key            gif标记
 *   executionBlock 成功回调 循环回调 gif的每一帧
 *   failBlock      失败回调 一次
 */
- (void)transformGifPathToSampBufferRef:(NSString *)gifPath key:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock;

/**
 *   lincf, 16-09-14 14:09:41
 *
 *  播放gif
 *
 *   gifData        文件数据
 *   key            gif标记
 *   executionBlock 成功回调 循环回调 gif的每一帧
 *   failBlock      失败回调 一次
 */
- (void)transformGifDataToSampBufferRef:(NSData *)gifData key:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock;
@end

@interface TFY_PickerWeakProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
