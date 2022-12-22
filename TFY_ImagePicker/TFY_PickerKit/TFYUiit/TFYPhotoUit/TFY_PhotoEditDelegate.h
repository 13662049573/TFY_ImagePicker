//
//  TFY_PhotoEditDelegate.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** +++++++++++++++++++++绘画代理+++++++++++++++++++++ */
@protocol TFYPhotoEditDrawDelegate <NSObject>
@optional
/** 开始绘画 */
- (void)picker_photoEditDrawBegan;
/** 结束绘画 */
- (void)picker_photoEditDrawEnded;
@end

/** +++++++++++++++++++++贴图代理+++++++++++++++++++++ */
@protocol TFYPhotoEditStickerDelegate <NSObject>
@optional
/** 点击贴图 isActive=YES 选中的情况下点击，可以通过getSelectSticker获取选中贴图 */
- (void)picker_photoEditStickerDidSelectViewIsActive:(BOOL)isActive;
/** 贴图移动开始，可以通过getSelectSticker获取选中贴图 */
- (void)picker_photoEditStickerMovingBegan;
/** 贴图移动结束，可以通过getSelectSticker获取选中贴图 */
- (void)picker_photoEditStickerMovingEnded;

@end

/** +++++++++++++++++++++模糊代理+++++++++++++++++++++ */
@protocol TFYPhotoEditSplashDelegate <NSObject>
@optional
/** 开始模糊 */
- (void)picker_photoEditSplashBegan;
/** 结束模糊 */
- (void)picker_photoEditSplashEnded;
@end

NS_ASSUME_NONNULL_BEGIN

@protocol TFY_PhotoEditDelegate <TFYPhotoEditDrawDelegate, TFYPhotoEditStickerDelegate, TFYPhotoEditSplashDelegate>

@end

NS_ASSUME_NONNULL_END
