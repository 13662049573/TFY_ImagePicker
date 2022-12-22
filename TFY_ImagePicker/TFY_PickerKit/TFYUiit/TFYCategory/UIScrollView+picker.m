//
//  UIScrollView+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "UIScrollView+picker.h"
#import <objc/runtime.h>

static const char * TFYDragAutoScrollAutoScrollDirectionKey = "TFYDragAutoScrollAutoScrollDirectionKey";
static const char * TFYDragAutoScrollAutoScrollTimerKey = "TFYDragAutoScrollAutoScrollTimerKey";
static const char * TFYDragAutoScrollAutoScrollSpeedKey = "TFYDragAutoScrollAutoScrollSpeedKey";
static const char * TFYDragAutoScrollAutoScrollChangedBlockKey = "TFYDragAutoScrollAutoScrollChangedBlockKey";
static const char * TFYDragAutoScrollAutoScrollSnapshotViewKey = "TFYDragAutoScrollAutoScrollSnapshotViewKey";

@interface UIScrollView (picker)

/** 计时器 */
@property (nonatomic, strong) CADisplayLink *autoScrollTimer;
@property (nonatomic, weak) UIView *autoSnapshotView;

@end

@implementation UIScrollView (picker)

- (TFYDragAutoScrollDirection)autoScrollDirection
{
    return [objc_getAssociatedObject(self, TFYDragAutoScrollAutoScrollDirectionKey) integerValue];
}

- (void)setAutoScrollDirection:(TFYDragAutoScrollDirection)autoScrollDirection
{
    objc_setAssociatedObject(self, TFYDragAutoScrollAutoScrollDirectionKey, @(autoScrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CADisplayLink *)autoScrollTimer
{
    return objc_getAssociatedObject(self, TFYDragAutoScrollAutoScrollTimerKey);
}

- (void)setAutoScrollTimer:(CADisplayLink *)autoScrollTimer
{
    objc_setAssociatedObject(self, TFYDragAutoScrollAutoScrollTimerKey, autoScrollTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)autoScrollSpeed
{
    NSNumber *num = objc_getAssociatedObject(self, TFYDragAutoScrollAutoScrollSpeedKey);
    if (num) {
        return [num floatValue];
    }
    return 4.0;
}

- (void)setAutoScrollSpeed:(CGFloat)autoScrollSpeed
{
    objc_setAssociatedObject(self, TFYDragAutoScrollAutoScrollSpeedKey, @(autoScrollSpeed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFYDragAutoScrollChanged)autoScrollChanged
{
    return objc_getAssociatedObject(self, TFYDragAutoScrollAutoScrollChangedBlockKey);
}

- (void)setAutoScrollChanged:(TFYDragAutoScrollChanged)autoScrollChanged
{
    objc_setAssociatedObject(self, TFYDragAutoScrollAutoScrollChangedBlockKey, autoScrollChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)autoSnapshotView
{
    return objc_getAssociatedObject(self, TFYDragAutoScrollAutoScrollSnapshotViewKey);
}

- (void)setAutoSnapshotView:(UIView *)autoSnapshotView
{
    objc_setAssociatedObject(self, TFYDragAutoScrollAutoScrollSnapshotViewKey, autoSnapshotView, OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark -  检查截图是否到达整个collectionView的边缘，并作出响应
- (BOOL)autoScrollForView:(UIView *)view
{
    TFYDragAutoScrollDirection autoScrollDirection = TFYDragAutoScrollDirectionNone;
    self.autoSnapshotView = view;
    if (view) {
        CGRect covertRect = [view.superview convertRect:view.frame toView:self];
        if (self.bounds.size.width < self.contentSize.width) {
            CGFloat minX = CGRectGetMinX(covertRect);
            CGFloat maxX = CGRectGetMaxX(covertRect);
            if (minX < self.contentOffset.x) {
                autoScrollDirection = TFYDragAutoScrollDirectionLeft;
            } else
                if (maxX > self.bounds.size.width + self.contentOffset.x) {
                    autoScrollDirection = TFYDragAutoScrollDirectionRight;
                }
        } else if (self.bounds.size.height < self.contentSize.height) {
            CGFloat minY = CGRectGetMinY(covertRect);
            CGFloat maxY = CGRectGetMaxY(covertRect);
            if (minY < self.contentOffset.y) {
                autoScrollDirection = TFYDragAutoScrollDirectionTop;
            } else
                if (maxY > self.bounds.size.height + self.contentOffset.y) {
                    autoScrollDirection = TFYDragAutoScrollDirectionBottom;
                }
        }
    }
    if (autoScrollDirection == TFYDragAutoScrollDirectionNone) {
        [self stopAutoScrollTimer];
        self.autoScrollDirection = autoScrollDirection;
    } else {
        self.autoScrollDirection = autoScrollDirection;
        [self startAutoScrollTimer];
        return YES;
    }
    return NO;
}

#pragma mark - timer methods
/**
 *  创建定时器并运行
 */
- (void)startAutoScrollTimer{
    if (!self.autoScrollTimer) {
        self.autoScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [self.autoScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
/**
 *  停止定时器并销毁
 */
- (void)stopAutoScrollTimer{
    if (self.autoScrollTimer) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
}

#pragma mark - 开始自动滚动
 
- (void)startAutoScroll{
    CGFloat pixelSpeed = self.autoScrollSpeed;
    
    switch (self.autoScrollDirection) {
        case TFYDragAutoScrollDirectionTop:
        {
            if (self.contentOffset.y > 0) {
                [self setContentOffset:CGPointMake(self.contentOffset.x, MAX(self.contentOffset.y - pixelSpeed, 0))];
            } else {
                [self stopAutoScrollTimer];
            }
        }
            break;
        case TFYDragAutoScrollDirectionLeft:
        {
            if (self.contentOffset.x > 0) {
                [self setContentOffset:CGPointMake(MAX(self.contentOffset.x - pixelSpeed, 0), self.contentOffset.y)];
            } else {
                [self stopAutoScrollTimer];
            }
        }
            break;
        case TFYDragAutoScrollDirectionBottom:
        {
            if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {
                [self setContentOffset:CGPointMake(self.contentOffset.x, MIN(self.contentOffset.y + pixelSpeed, self.contentSize.height-self.bounds.size.height))];
            } else {
                [self stopAutoScrollTimer];
            }
        }
            break;
        case TFYDragAutoScrollDirectionRight:
        {
            if (self.contentOffset.x + self.bounds.size.width < self.contentSize.width) {
                [self setContentOffset:CGPointMake(MIN(self.contentOffset.x + pixelSpeed, self.contentSize.width-self.bounds.size.width), self.contentOffset.y)];
            } else {
                [self stopAutoScrollTimer];
            }
        }
            break;
        default:
            break;
    }
    
    if (self.autoScrollChanged) {
        CGRect covertRect = [self.autoSnapshotView.superview convertRect:self.autoSnapshotView.frame toView:self];
        self.autoScrollChanged(CGPointMake(CGRectGetMidX(covertRect), CGRectGetMidY(covertRect)));
    }
}

@end
