//
//  TFY_AssetManager+Simple.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager+Simple.h"

@implementation TFY_AssetManager (Simple)
@dynamic sortAscendingByCreateDate, allowPickingType;

- (BOOL)sortAscendingByCreateDate_iOS8
{
    /** 倒序情况下。iOS8的result已支持倒序,这里的排序应该为顺序 */
    BOOL ascending = self.sortAscendingByCreateDate;
    if (@available(iOS 8.0, *)){
        if (!self.sortAscendingByCreateDate) {
            ascending = !self.sortAscendingByCreateDate;
        }
    }
    return ascending;
}

/**
 *   lincf, 16-07-28 17:07:38
 *
 *  Get Album 获得相机胶卷相册
 *
 *   fetchLimit        相片最大数量（IOS8之后有效）
 *   completion        回调结果
 */
- (void)getCameraRollAlbumFetchLimit:(NSInteger)fetchLimit completion:(void (^)(TFY_PickerAlbum *model))completion
{
    [self getCameraRollAlbum:self.allowPickingType fetchLimit:fetchLimit ascending:self.sortAscendingByCreateDate completion:completion];
}


/**
 Get Album 获得所有相册/相册数组

  completion 回调结果
 */
- (void)getAllAlbums:(void (^)(NSArray<TFY_PickerAlbum *> *))completion
{
    [self getAllAlbums:self.allowPickingType ascending:self.sortAscendingByCreateDate completion:completion];
}

/**
 *   lincf, 16-07-28 13:07:27
 *
 *  Get Assets 获得Asset数组
 *
 *   result            TFY_PickerAlbum.result 相册对象
 *   fetchLimit        相片最大数量
 *   completion        回调结果
 */
- (void)getAssetsFromFetchResult:(id)result fetchLimit:(NSInteger)fetchLimit completion:(void (^)(NSArray<TFY_PickerAsset *> *models))completion
{
    [self getAssetsFromFetchResult:result allowPickingType:self.allowPickingType fetchLimit:fetchLimit ascending:self.sortAscendingByCreateDate_iOS8 completion:completion];
}

/** 获得下标为index的单个照片 */
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index completion:(void (^)(TFY_PickerAsset *))completion
{
    [self getAssetFromFetchResult:result atIndex:index allowPickingType:self.allowPickingType ascending:self.sortAscendingByCreateDate_iOS8 completion:completion];
}

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(TFY_PickerAlbum *)model completion:(void (^)(UIImage *postImage))completion
{
    [self getPostImageWithAlbumModel:model ascending:self.sortAscendingByCreateDate_iOS8 completion:completion];
}
@end
