//
//  UIViewController+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (picker)
@property (nonatomic, readonly) UIPanGestureRecognizer *picker_dropShadowPanGestureRecognizer API_AVAILABLE(ios(13.0));
@end

NS_ASSUME_NONNULL_END
