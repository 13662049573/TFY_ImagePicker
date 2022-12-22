//
//  TFY_PickerAlbum+SmartAlbum.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerAlbum+SmartAlbum.h"
#import <Photos/Photos.h>

@implementation TFY_PickerAlbum (SmartAlbum)

- (TFYAlbumSmartAlbum)smartAlbum
{
    if ([self.album isKindOfClass:[PHAssetCollection class]]) {
        PHAssetCollection *collection = (PHAssetCollection *)self.album;
        if (collection.assetCollectionType == PHAssetCollectionTypeSmartAlbum) {
            switch (collection.assetCollectionSubtype) {
                case PHAssetCollectionSubtypeSmartAlbumVideos:
                    return TFYAlbumSmartAlbumVideos;
                case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
                    return TFYAlbumSmartAlbumUserLibrary;
                case PHAssetCollectionSubtypeSmartAlbumLivePhotos:
                    return TFYAlbumSmartAlbumLivePhoto;
                case PHAssetCollectionSubtypeSmartAlbumAnimated:
                    return TFYAlbumSmartAlbumAnimated;
                default:
                    break;
            }
        }
    }
    return 0;
}

@end
