//
//  TFY_PickerAlbum+SmartAlbum.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerAlbum.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYAlbumSmartAlbum) {
    TFYAlbumSmartAlbumVideos = 1,
    TFYAlbumSmartAlbumUserLibrary,
    TFYAlbumSmartAlbumLivePhoto,
    TFYAlbumSmartAlbumAnimated,
};

@interface TFY_PickerAlbum (SmartAlbum)
@property (nonatomic, readonly) TFYAlbumSmartAlbum smartAlbum NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
@end

NS_ASSUME_NONNULL_END
