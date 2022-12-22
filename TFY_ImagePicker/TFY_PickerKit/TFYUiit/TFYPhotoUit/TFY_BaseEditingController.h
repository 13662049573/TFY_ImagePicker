//
//  TFY_BaseEditingController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BaseEditingController : UIViewController
/** 是否隐藏状态栏 默认YES */
@property (nonatomic, assign) BOOL isHiddenStatusBar;

/// 自定义外观颜色
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *cancelButtonTitleColorNormal;

- (void)showProgressHUD;
- (void)hideProgressHUD;

- (void)showProgressVideoHUD;
- (void)setProgress:(float)progress;

- (void)showInfoMessage:(NSString *)text;
- (void)showErrorMessage:(NSString *)text;

/** 初始化 */
- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation;
@end

NS_ASSUME_NONNULL_END
