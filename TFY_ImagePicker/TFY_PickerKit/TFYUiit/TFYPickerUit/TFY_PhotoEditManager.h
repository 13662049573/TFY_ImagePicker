//
//  TFY_PhotoEditManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>

@class TFY_PhotoEdit,TFY_PickerAsset,TFY_ResultImage;
NS_ASSUME_NONNULL_BEGIN

@interface TFY_PhotoEditManager : NSObject

+ (instancetype)manager NS_SWIFT_NAME(default());
+ (void)free;

/** 设置编辑对象 */
- (void)setPhotoEdit:(TFY_PhotoEdit *)obj forAsset:(TFY_PickerAsset *)asset;
/** 获取编辑对象 */
- (TFY_PhotoEdit *)photoEditForAsset:(TFY_PickerAsset *)asset;


/**
 *  通过asset解析缩略图、标清图/原图、图片数据字典
 *
 *   asset      TFY_PickerAsset
 *   isOriginal 是否原图
 *   completion 返回block 顺序：缩略图、标清图、图片数据字典
 */
- (void)getPhotoWithAsset:(TFY_PickerAsset *)asset
               isOriginal:(BOOL)isOriginal
               completion:(void (^)(TFY_ResultImage *resultImage))completion;


/**
 通过asset解析缩略图、标清图/原图、图片数据字典

  asset TFY_PickerAsset
  isOriginal 是否原图
  compressSize 非原图的压缩大小
  thumbnailCompressSize 缩略图压缩大小
  completion 返回block 顺序：缩略图、标清图、图片数据字典
 */
- (void)getPhotoWithAsset:(TFY_PickerAsset *)asset
               isOriginal:(BOOL)isOriginal
             compressSize:(CGFloat)compressSize
    thumbnailCompressSize:(CGFloat)thumbnailCompressSize
               completion:(void (^)(TFY_ResultImage *resultImage))completion;
@end

NS_ASSUME_NONNULL_END
