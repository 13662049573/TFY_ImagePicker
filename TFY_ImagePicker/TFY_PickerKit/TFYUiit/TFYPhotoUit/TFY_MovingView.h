//
//  TFY_MovingView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import "TFY_StickerItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_MovingView : UIView
/** active sticker view */
+ (void)setActiveEmoticonView:(TFY_MovingView * __nullable)view;

/** 初始化 */
- (instancetype)initWithItem:(TFY_StickerItem *)item;

/** 缩放率 minScale~maxScale */
- (void)setScale:(CGFloat)scale;
- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation;

/** 最小缩放率 默认0.2 */
@property (nonatomic, assign) CGFloat minScale;
/** 最大缩放率 默认3.0 */
@property (nonatomic, assign) CGFloat maxScale;

/** 显示界面的缩放率，例如在UIScrollView上显示，scrollView放大了5倍，movingView的视图控件会显得较大，这个属性是适配当前屏幕的比例调整控件大小 */
@property (nonatomic, assign) CGFloat screenScale;

/** Delayed deactivated time */
@property (nonatomic, assign) CGFloat deactivatedDelay;


@property (nonatomic, readonly) UIView *view;
@property (nonatomic, strong) TFY_StickerItem *item;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly, getter=isActive) BOOL active;

/** 区分isActive，参数的isActive是旧值，view.isActive是新值 */
@property (nonatomic, copy, nullable) void(^tapEnded)(TFY_MovingView *view, BOOL isActive);
@property (nonatomic, copy, nullable) void(^movingBegan)(TFY_MovingView *view);
@property (nonatomic, copy, nullable) void(^movingChanged)(TFY_MovingView *view, CGPoint locationPoint);
@property (nonatomic, copy, nullable) void(^movingEnded)(TFY_MovingView *view);
/** active发送变化时激活 */
@property (nonatomic, copy, nullable) void(^movingActived)(TFY_MovingView *view);

@property (nonatomic, copy, nullable) BOOL(^moveCenter)(CGRect rect);

@end

NS_ASSUME_NONNULL_END
