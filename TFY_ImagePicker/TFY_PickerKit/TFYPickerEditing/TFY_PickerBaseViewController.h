//
//  TFY_PickerBaseViewController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerBaseViewController : UIViewController
/** 是否隐藏导航栏 默认NO */
@property (nonatomic, assign) BOOL isHiddenNavBar;

/** 是否隐藏状态 默认NO */
@property (nonatomic, assign) BOOL isHiddenStatusBar;

/** 导航栏高度+状态栏 */
- (CGFloat)navigationHeight;
/** 不计算导航栏的屏幕大小 */
- (CGRect)viewFrameWithoutNavigation;

/** 相机权限 */
- (void)requestAccessForCameraCompletionHandler:(void (^)(void))handler;
@end

NS_ASSUME_NONNULL_END
