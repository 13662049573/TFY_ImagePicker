//
//  TFY_PhotoEditManager.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoEditManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TFY_ImagePickerPublic.h"
#import "TFY_PickerAsset.h"
#import "TFY_ResultObjectproperty.h"
#import "TFY_AssetManager.h"
#import "TFY_PhotoEdit.h"
#import "TFYCategory.h"

@interface TFY_PhotoEditManager ()
@property (nonatomic, strong) NSMutableDictionary *photoEditDict;
@end

@implementation TFY_PhotoEditManager
static TFY_PhotoEditManager *manager;

+ (instancetype)manager {
    if (manager == nil) {
        manager = [[self alloc] init];
        manager.photoEditDict = [@{} mutableCopy];
    }
    return manager;
}

+ (void)free
{
    [manager.photoEditDict removeAllObjects];
    manager = nil;
}

- (void)setPhotoEdit:(TFY_PhotoEdit *)obj forAsset:(TFY_PickerAsset *)asset
{
    __weak typeof(self) weakSelf = self;
    if (asset.asset) {
        if (asset.name.length) {
            if (obj) {
                [weakSelf.photoEditDict setObject:obj forKey:asset.name];
            } else {
                [weakSelf.photoEditDict removeObjectForKey:asset.name];
            }
        } else {
            [[TFY_AssetManager manager] requestForAsset:asset.asset complete:^(NSString *name) {
                if (name.length) {
                    if (obj) {
                        [weakSelf.photoEditDict setObject:obj forKey:name];
                    } else {
                        [weakSelf.photoEditDict removeObjectForKey:name];
                    }
                }
            }];
        }
    }
}

- (TFY_PhotoEdit *)photoEditForAsset:(TFY_PickerAsset *)asset
{
    __weak typeof(self) weakSelf = self;
    __block TFY_PhotoEdit *photoEdit = nil;
    if (asset.asset) {
        if (asset.name.length) {
            photoEdit = [weakSelf.photoEditDict objectForKey:asset.name];
        } else {
            [[TFY_AssetManager manager] requestForAsset:asset.asset complete:^(NSString *name) {
                if (name.length) {
                    photoEdit = [weakSelf.photoEditDict objectForKey:name];
                }
            }];
        }
    }
    return photoEdit;
}

/**
 通过asset解析缩略图、标清图/原图、图片数据字典
 
  asset TFY_PickerAsset
  isOriginal 是否原图
  completion 返回block 顺序：缩略图、标清图、图片数据字典
 */
- (void)getPhotoWithAsset:(TFY_PickerAsset *)asset
               isOriginal:(BOOL)isOriginal
               completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    [self getPhotoWithAsset:asset isOriginal:isOriginal compressSize:kCompressSize thumbnailCompressSize:kThumbnailCompressSize completion:completion];
}

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
               completion:(void (^)(TFY_ResultImage *resultImage))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGFloat thumbnailCompress = (thumbnailCompressSize <=0 ? kThumbnailCompressSize : thumbnailCompressSize);
        CGFloat sourceCompress = (compressSize <=0 ? kCompressSize : compressSize);
        
        TFY_PhotoEdit *photoEdit = [self photoEditForAsset:asset];
        NSString *imageName = asset.name;
        
        /** 图片数据 */
        NSData *sourceData = nil; NSData *thumbnailData = nil;
        UIImage *thumbnail = nil; UIImage *source = nil;
        
        /** 原图 */
        source = photoEdit.editPreviewImage;
        sourceData = photoEdit.editPreviewData;
        
        BOOL isGif = source.images.count;
        
        if (isGif) { /** GIF图片处理方式 */
            if (!isOriginal) {
                CGFloat imageRatio = 0.7f;
                /** 标清图 */
                sourceData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                source = [UIImage picker_imageWithImageData:sourceData];
            }
        } else {
            if (!isOriginal) { /** 标清图 */
                NSData *newSourceData = [source picker_fastestCompressImageDataWithSize:sourceCompress imageSize:sourceData.length];
                if (newSourceData) {
                    /** 可压缩的 */
                    sourceData = newSourceData;
                    source = [UIImage picker_imageWithImageData:sourceData];
                }
            }
        }
        /** 图片宽高 */
        CGSize imageSize = source.size;
        
        if (thumbnailCompressSize > 0) {
            if (isGif) {
                CGFloat minWidth = MIN(imageSize.width, imageSize.height);
                /** 缩略图 */
                CGFloat imageRatio = 0.5f;
                if (minWidth > 100.f) {
                    imageRatio = 50.f/minWidth;
                }
                /** 缩略图 */
                thumbnailData = [source picker_fastestCompressAnimatedImageDataWithScaleRatio:imageRatio];
                thumbnail = [UIImage picker_imageWithImageData:thumbnailData];
            } else {
                /** 缩略图 */
                NSData *newThumbnailData = [source picker_fastestCompressImageDataWithSize:thumbnailCompress imageSize:sourceData.length];
                if (newThumbnailData) {
                    /** 可压缩的 */
                    thumbnailData = newThumbnailData;
                } else {
                    thumbnailData = [NSData dataWithData:sourceData];
                }
                thumbnail = [UIImage picker_imageWithImageData:thumbnailData];
            }
        }
        
        TFY_ResultImage *result = [TFY_ResultImage new];
        result.asset = asset.asset;
        result.thumbnailImage = thumbnail;
        result.thumbnailData = thumbnailData;
        result.originalImage = source;
        result.originalData = sourceData;
        
        TFY_PickerResultInfo *info = [TFY_PickerResultInfo new];
        result.info = info;
        
        /** 图片文件名 */
        info.name = imageName;
        /** 图片大小 */
        info.byte = sourceData.length;
        /** 图片宽高 */
        info.size = imageSize;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(result);
        });
    });
}
@end
