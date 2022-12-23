//
//  TFY_AssetManager+Simple.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AssetManager (Simple)
/** 排序 YES */
@property (nonatomic, assign) BOOL sortAscendingByCreateDate;
/** 类型 TFY_PickingMediaTypeALL */
@property (nonatomic, assign) TFYPickingMediaType allowPickingType;

/**
 *   lincf, 16-07-28 17:07:38
 *
 *  Get Album 获得相机胶卷相册
 *
 *   fetchLimit        相片最大数量（IOS8之后有效）
 *   completion        回调结果
 */
- (void)getCameraRollAlbumFetchLimit:(NSInteger)fetchLimit completion:(void (^)(TFY_PickerAlbum *model))completion;


/**
 Get Album 获得所有相册/相册数组

  completion 回调结果
 */
- (void)getAllAlbums:(void (^)(NSArray<TFY_PickerAlbum *> *))completion;

/**
 *   lincf, 16-07-28 13:07:27
 *
 *  Get Assets 获得Asset数组
 *
 *   result            TFY_Album.result 相册对象
 *   fetchLimit        相片最大数量
 *   completion        回调结果
 */
- (void)getAssetsFromFetchResult:(id)result fetchLimit:(NSInteger)fetchLimit completion:(void (^)(NSArray<TFY_PickerAsset *> *models))completion;

/** 获得下标为index的单个照片 */
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index completion:(void (^)(TFY_PickerAsset *))completion;

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(TFY_PickerAlbum *)model completion:(void (^)(UIImage *postImage))completion;

@end

NS_ASSUME_NONNULL_END
