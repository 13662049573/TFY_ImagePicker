//
//  TFY_AssetManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "TFY_PickerAlbum.h"
#import "TFY_PickerAsset.h"
#import "TFY_ResultImage.h"
#import "TFY_ResultVideo.h"
#import "TFY_ImagePickerPublic.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AssetManager : NSObject
+ (instancetype)manager NS_SWIFT_NAME(default());
+ (void)free;

/** default YES，fix image orientation */
@property (nonatomic, assign) BOOL shouldFixOrientation;
/** default YES，decode image */
@property (nonatomic, assign) BOOL shouldDecoded;

/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
//@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
//@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
/// 默认为YES，预览时自动播放live photo；否则需要长按照片才会播放。
@property (nonatomic, assign) BOOL autoPlayLivePhoto;

/** 默认相册对象 */
@property (nonatomic, readonly) ALAssetsLibrary *assetLibrary AL_DEPRECATED(4, "Use PHPhotoLibrary from the Photos framework instead");

/**
 *  @author lincf, 16-07-28 17:07:38
 *
 *  Get Album 获得相机胶卷相册
 *
 *  allowPickingType  媒体类型
 *  fetchLimit        相片最大数量（IOS8之后有效）
 *  ascending         顺序获取（IOS8之后有效）
 *  completion        回调结果
 */
- (void)getCameraRollAlbum:(TFYPickingMediaType)allowPickingType fetchLimit:(NSInteger)fetchLimit ascending:(BOOL)ascending completion:(nullable void (^)(TFY_PickerAlbum *model))completion;


/**
 Get Album 获得所有相册/相册数组

 allowPickingType  媒体类型
 ascending 顺序获取（IOS8之后有效）
 completion 回调结果
 */
- (void)getAllAlbums:(TFYPickingMediaType)allowPickingType ascending:(BOOL)ascending completion:(nullable void (^)(NSArray<TFY_PickerAlbum *> *))completion;

/**
 *  @author lincf, 16-07-28 13:07:27
 *
 *  Get Assets 获得Asset数组
 *
 *  result            LFAlbum.result 相册对象
 *  llowPickingType  媒体类型
 *  fetchLimit        相片最大数量
 *  ascending         顺序获取
 *  completion        回调结果
 */
- (void)getAssetsFromFetchResult:(id)result allowPickingType:(TFYPickingMediaType)allowPickingType fetchLimit:(NSInteger)fetchLimit ascending:(BOOL)ascending completion:(nullable void (^)(NSArray<TFY_PickerAsset *> *models))completion;

/** 获得下标为index的单个照片 */
- (void)getAssetFromFetchResult:(id)result
                        atIndex:(NSInteger)index
               allowPickingType:(TFYPickingMediaType)allowPickingType
                      ascending:(BOOL)ascending
                     completion:(nullable void (^)(TFY_PickerAsset *))completion;

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(TFY_PickerAlbum *)model ascending:(BOOL)ascending completion:(nullable void (^)(UIImage *postImage))completion;

/** 仅仅获取缩略图 */
- (PHImageRequestID)getThumbnailWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/** 获取照片对象 回调 image */
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(nullable void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/** 获取照片对象 回调 data (gif) */
- (PHImageRequestID)getPhotoDataWithAsset:(id)asset completion:(nullable void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoDataWithAsset:(id)asset completion:(nullable void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/** 获取照片对象 回调 live photo */
- (PHImageRequestID)getLivePhotoWithAsset:(id)asset completion:(nullable void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion API_AVAILABLE(ios(9.1));
- (PHImageRequestID)getLivePhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion API_AVAILABLE(ios(9.1));
- (PHImageRequestID)getLivePhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(nullable void (^)(PHLivePhoto *livePhoto,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed API_AVAILABLE(ios(9.1));

/** 停止获取照片对象 */
- (void)cancelImageRequest:(PHImageRequestID)requestID;

/**
 *  通过asset解析缩略图、标清图/原图、图片数据字典
 *
 *  asset      PHAsset／ALAsset
 *  isOriginal 是否原图
 *  completion 返回block 顺序：缩略图、原图、图片数据字典
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               completion:(nullable void (^)(TFY_ResultImage *resultImage))completion;
/**
 *  通过asset解析缩略图、标清图/原图、图片数据字典
 *
 *  asset      PHAsset／ALAsset
 *  isOriginal 是否原图
 *  pickingGif 是否需要处理GIF图片
 *  completion 返回block 顺序：缩略图、原图、图片数据字典 若返回LFResultObject对象则获取error错误信息。
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               pickingGif:(BOOL)pickingGif
               completion:(nullable void (^)(TFY_ResultImage *resultImage))completion;

/**
 通过asset解析缩略图、标清图/原图、图片数据字典
 
 asset PHAsset／ALAsset
 isOriginal 是否原图
 pickingGif 是否需要处理GIF图片
 compressSize 非原图的压缩大小
 thumbnailCompressSize 缩略图压缩大小
 completion 返回block 顺序：缩略图、标清图、图片数据字典 若返回LFResultObject对象则获取error错误信息。
 */
- (void)getPhotoWithAsset:(id)asset
               isOriginal:(BOOL)isOriginal
               pickingGif:(BOOL)pickingGif
             compressSize:(CGFloat)compressSize
    thumbnailCompressSize:(CGFloat)thumbnailCompressSize
               completion:(nullable void (^)(TFY_ResultImage *resultImage))completion;


/**
 通过asset解析缩略图、标清图/原图、图片数据字典

 asset PHAsset
 isOriginal 是否原图
 needThumbnail 需要缩略图
 completion  返回block 顺序：缩略图、标清图、图片数据字典
 */
- (void)getLivePhotoWithAsset:(id)asset
                   isOriginal:(BOOL)isOriginal
                needThumbnail:(BOOL)needThumbnail
                   completion:(nullable void (^)(TFY_ResultImage *resultImage))completion API_AVAILABLE(ios(9.1));

/// Get video 获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;
- (void)getVideoResultWithAsset:(id)asset
                     presetName:(NSString *)presetName
                          cache:(BOOL)cache
                     completion:(nullable void (^)(TFY_ResultVideo *resultVideo))completion;

/**
 *  lincf, 16-06-15 13:06:26
 *
 *  视频压缩并缓存压缩后视频 (将视频格式变为mp4)
 *
 *  asset      PHAsset／ALAsset
 *  presetName 压缩预设名称 nil则默认为AVAssetExportPreset1280x720
 *  completion 回调压缩后视频路径，可以复制或剪切
 */
- (void)compressAndCacheVideoWithAsset:(id)asset
                            presetName:(NSString *)presetName
                            completion:(nullable void (^)(NSString *path))completion;

/// 检查照片的大小是否超过最大值
- (void)checkPhotosBytesMaxSize:(NSArray <TFY_PickerAsset *>*)photos maxBytes:(NSInteger)maxBytes completion:(nullable void (^)(BOOL isPass))completion;
/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray <TFY_PickerAsset *>*)photos completion:(nullable void (^)(NSString *totalBytesStr, NSInteger totalBytes))completion;

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (NSInteger)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

- (NSString *)getAssetIdentifier:(id)asset;

/// 检查照片大小是否满足最小要求
//- (BOOL)isPhotoSelectableWithAsset:(id)asset;
- (CGSize)photoSizeWithAsset:(id)asset;

/// 获取照片名称
- (void)requestForAsset:(id)asset complete:(nullable void (^)(NSString *name))complete;

/// Return Cache Path 返回压缩缓存视频路径
+ (NSString *)CacheVideoPath;

/** 清空视频缓存 */
+ (BOOL)cleanCacheVideoPath;

- (NSURL *)getURLInPlayer:(AVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
