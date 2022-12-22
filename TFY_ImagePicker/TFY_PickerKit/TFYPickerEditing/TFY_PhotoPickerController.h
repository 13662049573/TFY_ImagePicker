//
//  TFY_PhotoPickerController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerBaseViewController.h"

@class TFY_PickerAlbum,TFY_PhotoPreviewController;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PhotoPickerController : TFY_PickerBaseViewController
@property (nonatomic, strong) TFY_PickerAlbum *model;
- (void)pushPhotoPrevireViewController:(TFY_PhotoPreviewController *)photoPreviewVc;
@end

NS_ASSUME_NONNULL_END
