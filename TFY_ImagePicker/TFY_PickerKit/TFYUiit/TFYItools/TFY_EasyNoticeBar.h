//
//  TFY_EasyNoticeBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYEasyNoticeBarDisplayType) {
    TFYEasyNoticeBarDisplayTypeInfo,
    TFYEasyNoticeBarDisplayTypeSuccess,
    TFYEasyNoticeBarDisplayTypeWarning,
    TFYEasyNoticeBarDisplayTypeError
};

@interface TFY_EasyNoticeBarConfig : NSObject
/**
 *   Notice title, default is nil.
 */
@property (nonatomic, copy) NSString *title;

/**
 *   NoticeBar display type, default is TFYEasyNoticeBarDisplayTypeInfo.
 */
@property (nonatomic, assign) TFYEasyNoticeBarDisplayType type;

/**
 *   Margin around the noticeBar, default is 20.0f.
 */
@property (nonatomic, assign) CGFloat margin;

/**
 *   Notice title color, default is black.
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 *   Background color, default is white.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *   UIStatusBarStyle, default is UIStatusBarStyleDefault.
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@interface TFY_EasyNoticeBar : UIView

@property (nonatomic, readonly) TFY_EasyNoticeBarConfig *config;

- (void)showWithDuration:(NSTimeInterval)duration;

+ (void)showAnimationWithConfig:(TFY_EasyNoticeBarConfig *)config;
+ (void)hideAll;

@end

NS_ASSUME_NONNULL_END
