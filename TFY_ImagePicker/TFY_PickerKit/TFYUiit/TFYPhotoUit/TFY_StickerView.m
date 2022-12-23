//
//  TFY_StickerView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_StickerView.h"
#import "TFY_MovingView.h"
#import "TFY_MovingRemoveView.h"
#import "NSObject+picker.h"
#import "TFYItools.h"

NSString *const kTFYStickerViewData_movingView = @"TFYStickerViewData_movingView";

NSString *const kTFYStickerViewData_movingView_content = @"TFYStickerViewData_movingView_content";

NSString *const kTFYStickerViewData_movingView_center = @"TFYStickerViewData_movingView_center";
NSString *const kTFYStickerViewData_movingView_scale = @"TFYStickerViewData_movingView_scale";
NSString *const kTFYStickerViewData_movingView_minScale = @"TFYStickerViewData_movingView_minScale";
NSString *const kTFYStickerViewData_movingView_maxScale = @"TFYStickerViewData_movingView_maxScale";
NSString *const kTFYStickerViewData_movingView_rotation = @"TFYStickerViewData_movingView_rotation";

@interface TFY_StickerView ()
@property (nonatomic, weak) TFY_MovingView *selectMovingView;

@property (nonatomic, assign, getter=isHitTestSubView) BOOL hitTestSubView;

@property (nonatomic, weak) TFY_MovingRemoveView *movingRemoveView;
/** 缓存对象，不用每次显示都创建。 */
@property (nonatomic, strong) TFY_MovingRemoveView *cacheMovingRemoveView;
@end

@implementation TFY_StickerView

+ (void)stickerViewDeactivated
{
    [TFY_MovingView setActiveEmoticonView:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    _screenScale = 1.f;
    _minScale = .3f;
    _maxScale = 3.f;
}

#pragma mark - 解除响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    self.hitTestSubView = [view isDescendantOfView:self];
    return (view == self ? nil : view);
}

- (BOOL)isEnable
{
    return self.isHitTestSubView && self.selectMovingView.isActive;
}

- (void)setTapEnded:(void (^)(TFY_StickerItem *, BOOL))tapEnded
{
    _tapEnded = tapEnded;
    for (TFY_MovingView *subView in self.subviews) {
        if ([subView isKindOfClass:[TFY_MovingView class]]) {
            if (tapEnded) {
                __weak typeof(self) weakSelf = self;
                [subView setTapEnded:^(TFY_MovingView *view, BOOL isActive) {
                    weakSelf.tapEnded(view.item, isActive);
                }];
            } else {
                [subView setTapEnded:nil];
            }
        }
    }
}

- (void)setMoveCenter:(BOOL (^)(CGRect))moveCenter
{
    _moveCenter = moveCenter;
    for (TFY_MovingView *subView in self.subviews) {
        if ([subView isKindOfClass:[TFY_MovingView class]]) {
            if (moveCenter) {
                __weak typeof(self) weakSelf = self;
                [subView setMoveCenter:^BOOL (CGRect rect) {
                    return weakSelf.moveCenter(rect);
                }];
            } else {
                [subView setMoveCenter:nil];
            }
        }
    }
}

/** 激活选中的贴图 */
- (void)activeSelectStickerView
{
    [TFY_MovingView setActiveEmoticonView:self.selectMovingView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    [self.selectMovingView removeFromSuperview];
}

/** 获取选中贴图的内容 */
- (TFY_StickerItem *)getSelectStickerItem
{
    return self.selectMovingView.item;
}

/** 更改选中贴图内容 */
- (void)changeSelectStickerItem:(TFY_StickerItem *)item
{
    self.selectMovingView.item = item;
}

/** 创建可移动视图 */
- (TFY_MovingView *)createBaseMovingView:(TFY_StickerItem *)item active:(BOOL)active
{
    
    TFY_MovingView *movingView = [[TFY_MovingView alloc] initWithItem:item];
    /** 屏幕中心 */
    movingView.center = [self convertPoint:TFYAppWindow().center fromView:(UIView *)TFYAppWindow()];
    
    [self addSubview:movingView];
    
    __weak typeof(self) weakSelf = self;
    [movingView setMovingActived:^(TFY_MovingView * _Nonnull view) {
        if (view.isActive) {
            weakSelf.selectMovingView = view;
        } else { /** selectMovingView就让它一直存活吧。 */
            /** 取消激活时，清空selectMovingView */
//            if (weakSelf.selectMovingView == view) {
//                weakSelf.selectMovingView = nil;
//            }
        }
    }];
    
    
    if (self.tapEnded) {
        [movingView setTapEnded:^(TFY_MovingView * _Nonnull view, BOOL isActive) {
            weakSelf.tapEnded(view.item, isActive);
        }];
    }
    
    if (self.movingBegan) {
        [movingView setMovingBegan:^(TFY_MovingView * _Nonnull view) {
            weakSelf.movingBegan(view.item);
            [weakSelf showMovingRemoveView];
        }];
    }
    
    [movingView setMovingChanged:^(TFY_MovingView * _Nonnull view, CGPoint locationPoint) {
        BOOL isContains = CGRectContainsPoint(weakSelf.movingRemoveView.frame, locationPoint);
        if (weakSelf.movingRemoveView.isSelected && !isContains) {
            [weakSelf dismissMovingRemoveView:YES];
        } else {
            weakSelf.movingRemoveView.selected = isContains;
        }
    }];
    
    if (self.movingEnded) {
        [movingView setMovingEnded:^(TFY_MovingView * _Nonnull view) {
            weakSelf.movingEnded(view.item);
            if (weakSelf.movingRemoveView.isSelected) {
                [weakSelf removeSelectStickerView];
                [weakSelf dismissMovingRemoveView:NO];
            } else {
                [weakSelf dismissMovingRemoveView:YES];
            }
        }];
    }
    
    if (self.moveCenter) {
        [movingView setMoveCenter:^BOOL (CGRect rect) {
            return weakSelf.moveCenter(rect);
        }];
    }
    
    if (active) {
        [TFY_MovingView setActiveEmoticonView:movingView];
    }
    
    return movingView;
}

- (void)createStickerItem:(TFY_StickerItem *)item
{
    TFY_MovingView *movingView = [self createBaseMovingView:item active:YES];
    
    /** 屏幕缩放率 */
    movingView.screenScale = self.screenScale;
    
    /** 区别文字情况，文字采用固定缩放率 */
    if (item.text) {
        movingView.minScale = self.minScale;
        movingView.maxScale = self.maxScale;
        [movingView setScale:1.0/self.screenScale];
    } else { /** 采用动态屏幕大小与贴图大小比例缩放率 */
        /** 最小缩放率 */
        CGFloat ratio = self.minScale;
        movingView.minScale = MIN( (ratio * [UIScreen mainScreen].bounds.size.width * 0.5) / movingView.view.frame.size.width, (ratio * [UIScreen mainScreen].bounds.size.height * 0.5) / movingView.view.frame.size.height)/self.screenScale;
        /** 最大缩放率 */
        ratio = self.maxScale;
        movingView.maxScale = MIN( (ratio * [UIScreen mainScreen].bounds.size.width * 0.5) / movingView.view.frame.size.width, (ratio * [UIScreen mainScreen].bounds.size.height * 0.5) / movingView.view.frame.size.height)/self.screenScale;
        ratio = 0.35f;
        CGFloat scale = MIN( (ratio * [UIScreen mainScreen].bounds.size.width) / movingView.view.frame.size.width, (ratio * [UIScreen mainScreen].bounds.size.height) / movingView.view.frame.size.height);
        [movingView setScale:scale/self.screenScale];
    }
    
    [self picker_showInView:TFYAppWindow() maskRects:@[[NSValue valueWithCGRect:[self convertRect:movingView.frame toView:nil]]] withTips:@[[NSBundle picker_localizedStringForKey:@"_LFME_UserGuide_StickerView_MovingView_Pinch"]]];
}

/** 贴图数量 */
- (NSUInteger)count
{
    return self.subviews.count;
}

- (void)setScreenScale:(CGFloat)screenScale
{
    if (screenScale > 0) {
        _screenScale = screenScale;
        for (TFY_MovingView *subView in self.subviews) {
            if ([subView isKindOfClass:[TFY_MovingView class]]) {
                subView.screenScale = screenScale;
            }
        }
    }
}

- (TFY_MovingRemoveView *)cacheMovingRemoveView
{
    if (_cacheMovingRemoveView == nil) {
        _cacheMovingRemoveView = [[TFY_MovingRemoveView alloc] initWithFrame:CGRectMake((self.bounds.size.width-150)/2, self.bounds.size.height - 100 - 30, 150, 100)];
    }
    return _cacheMovingRemoveView;
}

- (void)showMovingRemoveView
{
    if (self.movingRemoveView == nil) {
        TFY_MovingRemoveView *movingRemoveView = self.cacheMovingRemoveView;
        /** 还原默认值 */
        movingRemoveView.alpha = 0.0;
        movingRemoveView.selected = NO;
        /** 优化用户体验，判断当前movingView的位置，调整movingRemoveView的显示位置 */
        CGRect rect = movingRemoveView.frame;
        if (self.selectMovingView.center.y > self.center.y) {
            rect.origin.y = 30;
        } else {
            rect.origin.y = self.bounds.size.height - 100 - 30;
        }
        movingRemoveView.frame = rect;
        [self addSubview:movingRemoveView];
        self.movingRemoveView = movingRemoveView;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.movingRemoveView.alpha = 1.0;
    }];
}

- (void)dismissMovingRemoveView:(BOOL)animated
{
    TFY_MovingRemoveView *movingRemoveView = self.movingRemoveView;
    self.movingRemoveView = nil;
    if (movingRemoveView) {
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                movingRemoveView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [movingRemoveView removeFromSuperview];
            }];
        } else {
            [movingRemoveView removeFromSuperview];
        }
    }
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    NSMutableArray *movingDatas = [@[] mutableCopy];
    for (TFY_MovingView *view in self.subviews) {
        if ([view isKindOfClass:[TFY_MovingView class]]) {

            [movingDatas addObject:@{kTFYStickerViewData_movingView_content:view.item
                                     , kTFYStickerViewData_movingView_scale:@(view.scale)
                                     , kTFYStickerViewData_movingView_minScale:@(view.minScale)
                                     , kTFYStickerViewData_movingView_maxScale:@(view.maxScale)
                                     , kTFYStickerViewData_movingView_rotation:@(view.rotation)
                                     , kTFYStickerViewData_movingView_center:[NSValue valueWithCGPoint:view.center]
                                     }];
        }
    }
    if (movingDatas.count) {
        return @{kTFYStickerViewData_movingView:[movingDatas copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *movingDatas = data[kTFYStickerViewData_movingView];
    if (movingDatas.count) {
        for (NSDictionary *movingData in movingDatas) {
            
            
            TFY_StickerItem *item = movingData[kTFYStickerViewData_movingView_content];
            CGFloat scale = [movingData[kTFYStickerViewData_movingView_scale] floatValue];
            CGFloat minScale = [movingData[kTFYStickerViewData_movingView_minScale] floatValue];
            CGFloat maxScale = [movingData[kTFYStickerViewData_movingView_maxScale] floatValue];
            CGFloat rotation = [movingData[kTFYStickerViewData_movingView_rotation] floatValue];
            CGPoint center = [movingData[kTFYStickerViewData_movingView_center] CGPointValue];
            
            TFY_MovingView *view = [self createBaseMovingView:item active:NO];
            view.minScale = minScale;
            view.maxScale = maxScale;
            [view setScale:scale rotation:rotation];
            view.center = center;
        }
    }
}

@end
