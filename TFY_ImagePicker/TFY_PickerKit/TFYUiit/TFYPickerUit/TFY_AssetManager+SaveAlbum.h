//
//  TFY_AssetManager+SaveAlbum.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AssetManager (SaveAlbum)
/** 保存图片到自定义相册 */
- (void)saveImageToCustomPhotosAlbumWithTitle:(nullable NSString *)title images:(nullable NSArray <UIImage *>*)images complete:(nullable void (^)(NSArray <id /* PHAsset/ALAsset */>*assets,NSError *error))complete;
- (void)saveImageToCustomPhotosAlbumWithTitle:(nullable NSString *)title imageDatas:(nullable NSArray <NSData *>*)imageDatas complete:(nullable void (^)(NSArray <id /* PHAsset/ALAsset */>*assets ,NSError *error))complete;

/** 保存视频到自定义相册 */
- (void)saveVideoToCustomPhotosAlbumWithTitle:(nullable NSString *)title videoURLs:(nullable NSArray <NSURL *>*)videoURLs complete:(nullable void(^)(NSArray <id /* PHAsset/ALAsset */>*assets, NSError *error))complete;

/** 删除相册中的媒体文件 */
- (void)deleteAssets:(nullable NSArray <id /* PHAsset/ALAsset */ > *)assets complete:(nullable void (^)(NSError *error))complete;

/** 删除相册 */
- (void)deleteAssetCollections:(NSArray <PHAssetCollection *> *)collections complete:(void (^)(NSError *error))complete NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
- (void)deleteAssetCollections:(NSArray <PHAssetCollection *> *)collections deleteAssets:(BOOL)deleteAssets complete:(void (^)(NSError *error))complete NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
@end

NS_ASSUME_NONNULL_END
