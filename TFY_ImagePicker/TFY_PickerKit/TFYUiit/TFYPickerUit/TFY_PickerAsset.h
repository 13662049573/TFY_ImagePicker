//
//  TFY_PickerAsset.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import "TFY_AssetImageProtocol.h"
#import "TFY_AssetPhotoProtocol.h"
#import "TFY_AssetVideoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYAssetMediaType) {
    TFYAssetMediaTypePhoto = 0,
    TFYAssetMediaTypeVideo,
};

typedef NS_ENUM(NSUInteger, TFYAssetSubMediaType) {
    TFYAssetSubMediaTypeNone = 0,
    /** 动图 */
    TFYAssetSubMediaTypeGIF = 10,
    /** live photo */
    TFYAssetSubMediaTypeLivePhoto,
    /** 全景图、横图 */
    TFYAssetSubMediaTypePhotoPanorama = 50,
    /** 长图 */
    TFYAssetSubMediaTypePhotoPiiic,
};

@interface TFY_PickerAsset : NSObject

@property (nonatomic, readonly) id asset;             ///< PHAsset
@property (nonatomic, readonly) TFYAssetMediaType type;
@property (nonatomic, readonly) TFYAssetSubMediaType subType;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, copy, readonly) NSString *name;
/** 关闭livePhoto （ subType = TFYAssetSubMediaTypeLivePhoto is work ）default is No */
@property (nonatomic, assign) BOOL closeLivePhoto;


/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
- (instancetype)initWithAsset:(id)asset;

@end

@interface TFY_PickerAsset (preview)

/** 自定义缩略图 */
@property (nonatomic, readonly) UIImage *thumbnailImage;
/** 自定义预览图 */
@property (nonatomic, readonly) UIImage *previewImage;
/** 自定义视频URL */
@property (nonatomic, readonly) NSURL *previewVideoUrl;

- (instancetype)initWithObject:(id/* <TFY_PickerAssetProtocol> */)asset;

@end

NS_ASSUME_NONNULL_END
