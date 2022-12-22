//
//  TFY_VideoUtils.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_VideoUtils : NSObject

/** 视频压缩URL */
+ (void)encodeVideoWithURL:(NSURL *)videoURL outPath:(NSString *)outPath complete:(void (^)(BOOL isSuccess, NSError *error))complete;
+ (void)encodeVideoWithURL:(NSURL *)videoURL outPath:(NSString *)outPath presetName:(NSString *)presetName complete:(void (^)(BOOL isSuccess, NSError *error))complete;

/** 视频压缩Asset */
+ (void)encodeVideoWithAsset:(AVAsset *)asset outPath:(NSString *)outPath complete:(void (^)(BOOL isSuccess, NSError *error))complete;
+ (void)encodeVideoWithAsset:(AVAsset *)asset outPath:(NSString *)outPath presetName:(NSString *)presetName complete:(void (^)(BOOL isSuccess, NSError *error))complete;

/*
 * 获取第N帧的图片
 *videoURL:视频地址(本地/网络)
 *time      :第N帧
 */
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (CGSize)videoNaturalSizeWithPath:(NSString *)path;

+ (long long)videoSectionTimeWithPath:(NSString *)path;

+ (BOOL)videoCanPlayWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
