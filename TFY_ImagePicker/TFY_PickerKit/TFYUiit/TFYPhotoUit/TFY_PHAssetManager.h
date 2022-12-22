//
//  TFY_PHAssetManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PHAssetManager : NSObject

+ (BOOL)picker_IsGif:(PHAsset *)asset;

+ (PHImageRequestID)picker_GetPhotoDataWithAsset:(nullable id)asset completion:(nullable void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

+ (PHImageRequestID)picker_GetPhotoWithAsset:(nullable PHAsset *)phAsset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(UIImage *result,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

@end

NS_ASSUME_NONNULL_END
