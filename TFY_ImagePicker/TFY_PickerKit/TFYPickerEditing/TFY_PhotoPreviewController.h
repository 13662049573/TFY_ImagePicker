//
//  TFY_PhotoPreviewController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerBaseViewController.h"

@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYPhotoPreviewControllerPullDelegate <NSObject>

- (UIView *)picker_PhotoPreviewControllerPullBlackgroundView;

- (CGRect)picker_PhotoPreviewControllerPullItemRect:(TFY_PickerAsset *)asset;

@end

@interface TFY_PhotoPreviewController : TFY_PickerBaseViewController

@property (nonatomic, readonly) BOOL isPhotoPreview;

/// Return the new selected photos / 返回最新的选中图片数组
@property (nonatomic, copy) void (^backButtonClickBlock)(void);
@property (nonatomic, copy) void (^doneButtonClickBlock)(void);

/** 初始化 */
- (instancetype)initWithModels:(NSArray <TFY_PickerAsset *>*)models index:(NSInteger)index;
/** 图片预览模式 self.isPhotoPreview=YES */
- (instancetype)initWithPhotos:(NSArray <TFY_PickerAsset *>*)photos index:(NSInteger)index;

/** 总是显示预览框 */
@property (nonatomic, assign) BOOL alwaysShowPreviewBar;
/** 上一个界面的截图 */
@property (nonatomic, weak) id<TFYPhotoPreviewControllerPullDelegate> pulldelegate;


/** 3DTouch */
- (void)beginPreviewing:(UINavigationController *)navi;
- (void)endPreviewing;

@end

NS_ASSUME_NONNULL_END
