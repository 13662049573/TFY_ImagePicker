//
//  UIScrollView+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYDragAutoScrollDirection) {
    TFYDragAutoScrollDirectionNone,
    TFYDragAutoScrollDirectionTop,
    TFYDragAutoScrollDirectionLeft,
    TFYDragAutoScrollDirectionBottom,
    TFYDragAutoScrollDirectionRight,
};
typedef void(^TFYDragAutoScrollChanged)(CGPoint position);

@interface UIScrollView (picker)

/** 自动滚动的方向 */
@property (nonatomic, readonly) TFYDragAutoScrollDirection autoScrollDirection;
/** 自动滚动的速度 默认4 越大越快 */
@property (nonatomic, assign) CGFloat autoScrollSpeed;

/** 自动滚动时的回调，一直滚动一直回调，跟didScroll一样 */
@property (nonatomic, copy, nullable) TFYDragAutoScrollChanged autoScrollChanged;

/** 检查是否开启自动滚动，一般来说它是与移动视图相互配合使用 */
- (BOOL)autoScrollForView:(UIView * __nullable)view;

@end

NS_ASSUME_NONNULL_END
