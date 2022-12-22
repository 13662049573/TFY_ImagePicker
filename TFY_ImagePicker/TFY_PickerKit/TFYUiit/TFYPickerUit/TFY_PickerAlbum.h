//
//  TFY_PickerAlbum.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerAlbum : NSObject

@property (nonatomic, readonly) NSString *name;        ///< The album name
@property (nonatomic, readonly) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, readonly) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, readonly) id album NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;             /// PHAssetCollection
@property (nonatomic, strong) TFY_PickerAsset *posterAsset;    /** 封面对象 */

/** 缓存数据 */
@property (nonatomic, strong) NSArray <TFY_PickerAsset *>*models;

- (instancetype)initWithAlbum:(id)album result:(id)result;

- (void)changedAlbum:(id /*PHAssetCollection*/)album NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
- (void)changedResult:(id /*PHFetchResult*/)result NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;

@end

NS_ASSUME_NONNULL_END
