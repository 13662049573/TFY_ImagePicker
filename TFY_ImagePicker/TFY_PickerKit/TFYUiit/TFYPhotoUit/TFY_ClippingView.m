//
//  TFY_ClippingView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ClippingView.h"
#import <AVFoundation/AVFoundation.h>
#import "TFY_ZoomingView.h"
#import "TFYCategory.h"
#import "TFY_ImageCoder.h"

#define kRound(x) (round(x*100000)/100000)

#define kRoundFrame(rect) CGRectMake(kRound(rect.origin.x), kRound(rect.origin.y), kRound(rect.size.width), kRound(rect.size.height))

#define kDefaultMaximumZoomScale 5.f

NSString *const kTFYClippingViewData = @"TFYClippingViewData";

NSString *const kTFYClippingViewData_frame = @"TFYClippingViewData_frame";
NSString *const kTFYClippingViewData_zoomScale = @"TFYClippingViewData_zoomScale";
NSString *const kTFYClippingViewData_contentSize = @"TFYClippingViewData_contentSize";
NSString *const kTFYClippingViewData_contentOffset = @"TFYClippingViewData_contentOffset";
NSString *const kTFYClippingViewData_minimumZoomScale = @"TFYClippingViewData_minimumZoomScale";
NSString *const kTFYClippingViewData_maximumZoomScale = @"TFYClippingViewData_maximumZoomScale";
NSString *const kTFYClippingViewData_clipsToBounds = @"TFYClippingViewData_clipsToBounds";
NSString *const kTFYClippingViewData_transform = @"TFYClippingViewData_transform";
NSString *const kTFYClippingViewData_angle = @"TFYClippingViewData_angle";

NSString *const kTFYClippingViewData_first_minimumZoomScale = @"TFYClippingViewData_first_minimumZoomScale";

NSString *const kTFYClippingViewData_zoomingView = @"TFYClippingViewData_zoomingView";

@interface TFY_ClippingView ()<UIScrollViewDelegate>

@property (nonatomic, weak) TFY_ZoomingView *zoomingView;

/** 开始的基础坐标 */
@property (nonatomic, assign) CGRect normalRect;
/** 处理完毕的基础坐标（因为可能会被父类在缩放时改变当前frame的问题，导致记录坐标不正确） */
@property (nonatomic, assign) CGRect saveRect;
/** 首次缩放后需要记录最小缩放值，否则在多次重复编辑后由于大小发生改变，导致最小缩放值不准确，还原不回实际大小 */
@property (nonatomic, assign) CGFloat first_minimumZoomScale;
/** 旋转系数 */
@property (nonatomic, assign) NSInteger angle;
/** 默认最大化缩放 */
@property (nonatomic, assign) CGFloat defaultMaximumZoomScale;

/** 记录剪裁前的数据 */
@property (nonatomic, assign) CGRect old_frame;
@property (nonatomic, assign) CGFloat old_zoomScale;
@property (nonatomic, assign) CGSize old_contentSize;
@property (nonatomic, assign) CGPoint old_contentOffset;
@property (nonatomic, assign) CGFloat old_minimumZoomScale;
@property (nonatomic, assign) CGFloat old_maximumZoomScale;
@property (nonatomic, assign) CGAffineTransform old_transform;
@property (nonatomic, assign) NSInteger old_angle;

@end

@implementation TFY_ClippingView

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
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    self.delegate = self;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = kDefaultMaximumZoomScale;
    self.defaultMaximumZoomScale = kDefaultMaximumZoomScale;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = YES;
    self.angle = 0;
    self.offsetSuperCenter = CGPointZero;
    self.useGesture = NO;
    
    TFY_ZoomingView *zoomingView = [[TFY_ZoomingView alloc] initWithFrame:self.bounds];
    __weak typeof(self) weakSelf = self;
    zoomingView.moveCenter = ^BOOL(CGRect rect) {
        /** 判断缩放后贴图是否超出边界线 */
        CGRect newRect = [weakSelf.zoomingView convertRect:rect toView:weakSelf];
        CGRect clipTransRect = CGRectApplyAffineTransform(weakSelf.frame, weakSelf.transform);
        CGRect screenRect = (CGRect){weakSelf.contentOffset, clipTransRect.size};
        screenRect = CGRectInset(screenRect, 44/weakSelf.screenScale, 44/weakSelf.screenScale);
        return !CGRectIntersectsRect(screenRect, newRect);
    };
    [self addSubview:zoomingView];
    self.zoomingView = zoomingView;
    
    /** 默认编辑范围 */
    _editRect = self.bounds;
    
    // 实现TFY_EditingProtocol协议
    {
        self.picker_protocolxecutor = self.zoomingView;
    }
}

- (void)dealloc
{
    // 释放TFY_EditingProtocol协议
    [self clearProtocolxecutor];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image durations:nil];
}
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations
{
    _image = image;
    [self setZoomScale:1.f];
    if (image) {
        if (self.frame.size.width < self.frame.size.height) {
            self.defaultMaximumZoomScale = [UIScreen mainScreen].bounds.size.width * kDefaultMaximumZoomScale / self.frame.size.width;
        } else {
            self.defaultMaximumZoomScale = [UIScreen mainScreen].bounds.size.height * kDefaultMaximumZoomScale / self.frame.size.height;
        }
        self.maximumZoomScale = self.defaultMaximumZoomScale;
    }
    self.normalRect = self.frame;
    self.saveRect = self.frame;
    self.contentSize = self.picker_size;
    self.zoomingView.frame = self.bounds;
    [self.zoomingView setImage:image durations:durations];
}

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate
{
    CGRect inRect = [self.superview convertRect:rect toView:self.zoomingView];
    /** 参数取整，否则可能会出现1像素偏差 */
    inRect = TFYMediaEditProundRect(inRect);
    
    return [self.zoomingView editOtherImagesInRect:inRect rotate:rotate];
}

- (void)setCropRect:(CGRect)cropRect
{
    /** 记录当前数据 */
    self.old_transform = self.transform;
    self.old_frame = self.frame;
    self.old_zoomScale = self.zoomScale;
    self.old_contentSize = self.contentSize;
    self.old_contentOffset = self.contentOffset;
    self.old_minimumZoomScale = self.minimumZoomScale;
    self.old_maximumZoomScale = self.maximumZoomScale;
    self.old_angle = self.angle;
    
    _cropRect = cropRect;
    
    /** 当前UI位置未改变时，获取contentOffset与contentSize */
    /** 计算未改变前当前视图在contentSize的位置比例 */
    CGPoint contentOffset = self.contentOffset;
    CGFloat scaleX = MAX(contentOffset.x/(self.contentSize.width-self.picker_width), 0);
    CGFloat scaleY = MAX(contentOffset.y/(self.contentSize.height-self.picker_height), 0);
    /** 获取contentOffset必须在设置contentSize之前，否则重置frame 或 contentSize后contentOffset会发送变化 */
    
    CGRect oldFrame = self.frame;
    self.frame = cropRect;
    self.saveRect = self.frame;
    
    CGFloat scale = self.zoomScale;
    /** 视图位移 */
    CGFloat scaleZX = CGRectGetWidth(cropRect)/(CGRectGetWidth(oldFrame)/scale);
    CGFloat scaleZY = CGRectGetHeight(cropRect)/(CGRectGetHeight(oldFrame)/scale);
    
    CGFloat zoomScale = MIN(scaleZX, scaleZY);
    
    [self resetMinimumZoomScale];
    self.maximumZoomScale = (zoomScale > self.defaultMaximumZoomScale ? zoomScale : self.defaultMaximumZoomScale);
    [self setZoomScale:zoomScale];
    
    /** 记录首次最小缩放值 */
    if (self.first_minimumZoomScale == 0) {
        self.first_minimumZoomScale = self.minimumZoomScale;
    }
    
    /** 重设contentSize */
    self.contentSize = self.zoomingView.picker_size;
    /** 获取当前contentOffset的最大限度，根据之前的位置比例计算实际偏移坐标 */
    contentOffset.x = isnan(scaleX) ? contentOffset.x : (scaleX > 0 ? (self.contentSize.width-self.picker_width) * scaleX : contentOffset.x);
    contentOffset.y = isnan(scaleY) ? contentOffset.y : (scaleY > 0 ? (self.contentSize.height-self.picker_height) * scaleY : contentOffset.y);
    /** 计算坐标偏移与保底值 */
    CGRect zoomViewRect = self.zoomingView.frame;
    CGRect selfRect = CGRectApplyAffineTransform(self.frame, self.transform);
    self.contentOffset = CGPointMake(MIN(MAX(contentOffset.x, 0),zoomViewRect.size.width-selfRect.size.width), MIN(MAX(contentOffset.y, 0),zoomViewRect.size.height-selfRect.size.height));
}

/** 取消 */
- (void)cancel
{
    if (!CGRectEqualToRect(self.old_frame, CGRectZero)) {
        self.transform = self.old_transform;
        self.angle = self.old_angle;
        self.frame = self.old_frame;
        self.saveRect = self.frame;
        self.minimumZoomScale = self.old_minimumZoomScale;
        self.maximumZoomScale = self.old_maximumZoomScale;
        self.zoomScale = self.old_zoomScale;
        self.contentSize = self.old_contentSize;
        self.contentOffset = self.old_contentOffset;
    }
}

- (void)reset
{
    [self resetToRect:CGRectZero];
}

- (void)resetToRect:(CGRect)rect
{
    if (!_isReseting) {
        _isReseting = YES;
        if (CGRectEqualToRect(rect, CGRectZero)) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.transform = CGAffineTransformIdentity;
                                 self.angle = 0;
                                 self.minimumZoomScale = self.first_minimumZoomScale;
                                 [self setZoomScale:self.minimumZoomScale];
                                 self.frame = (CGRect){CGPointZero, self.zoomingView.picker_size};
                                 self.center = CGPointMake(self.superview.center.x-self.offsetSuperCenter.x/2, self.superview.center.y-self.offsetSuperCenter.y/2);
                                 self.saveRect = self.frame;
                                 /** 重设contentSize */
                                 self.contentSize = self.zoomingView.picker_size;
                                 /** 重置contentOffset */
                                 self.contentOffset = CGPointZero;
                                 if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginZooming:)]) {
                                     void (^block)(CGRect) = [self.clippingDelegate picker_clippingViewWillBeginZooming:self];
                                     if (block) block(self.frame);
                                 }
                             } completion:^(BOOL finished) {
                                 if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndZooming:)]) {
                                     [self.clippingDelegate picker_clippingViewDidEndZooming:self];
                                 }
                                 self->_isReseting = NO;
                             }];
        } else {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.transform = CGAffineTransformIdentity;
                                 self.angle = 0;
                                 self.minimumZoomScale = self.first_minimumZoomScale;
                                 [self setZoomScale:self.minimumZoomScale];
                                 self.frame = (CGRect){CGPointZero, self.zoomingView.picker_size};
                                 self.center = CGPointMake(self.superview.center.x-self.offsetSuperCenter.x/2, self.superview.center.y-self.offsetSuperCenter.y/2);
                                 /** 重设contentSize */
                                 self.contentSize = self.zoomingView.picker_size;
                                 /** 重置contentOffset */
                                 self.contentOffset = CGPointZero;
                                 [self zoomInToRect:rect];
                                 [self zoomOutToRect:rect completion:^{
                                     self->_isReseting = NO;
                                 }];
                             } completion:nil];
        }
    }
}

- (BOOL)canReset
{
    CGRect superViewRect = self.superview.bounds;
    CGRect trueFrame = CGRectMake((CGRectGetWidth(superViewRect)-CGRectGetWidth(self.zoomingView.frame))/2-self.offsetSuperCenter.x/2
                                  , (CGRectGetHeight(superViewRect)-CGRectGetHeight(self.zoomingView.frame))/2-self.offsetSuperCenter.y/2
                                  , CGRectGetWidth(self.zoomingView.frame)
                                  , CGRectGetHeight(self.zoomingView.frame));
    return [self canResetWithRect:trueFrame];
}

- (BOOL)canResetWithRect:(CGRect)trueFrame
{
    return !(CGAffineTransformIsIdentity(self.transform)
             && kRound(self.zoomScale) == kRound(self.minimumZoomScale)
             && [self verifyRect:trueFrame]);
}

- (CGRect)cappedCropRectInImageRectWithCropRect:(CGRect)cropRect
{
    CGRect rect = [self convertRect:self.zoomingView.frame toView:self.superview];
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(rect)) {
        cropRect.origin.x = CGRectGetMinX(rect);
    }
    if (CGRectGetMinY(cropRect) < CGRectGetMinY(rect)) {
        cropRect.origin.y = CGRectGetMinY(rect);
    }
    if (CGRectGetMaxX(cropRect) > CGRectGetMaxX(rect)) {
        cropRect.size.width = CGRectGetMaxX(rect) - CGRectGetMinX(cropRect);
    }
    if (CGRectGetMaxY(cropRect) > CGRectGetMaxY(rect)) {
        cropRect.size.height = CGRectGetMaxY(rect) - CGRectGetMinY(cropRect);
    }
    
    return cropRect;
}

#pragma mark 缩小到指定坐标
- (void)zoomOutToRect:(CGRect)toRect
{
    [self zoomOutToRect:toRect completion:nil];
}
- (void)zoomOutToRect:(CGRect)toRect completion:(void (^)(void))completion
{
    /** 屏幕在滚动时 不触发该功能 */
    if (self.dragging || self.decelerating) {
        return;
    }
    
    CGRect rect = [self cappedCropRectInImageRectWithCropRect:toRect];
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    /** 新增了放大功能：这里需要重新计算最小缩放系数 */
    [self resetMinimumZoomScale];
    [self setZoomScale:self.zoomScale];
    
    CGFloat scale = MIN(CGRectGetWidth(self.editRect) / width, CGRectGetHeight(self.editRect) / height);
    
    /** 指定位置=当前显示位置 或者 当前缩放已达到最大，并且仍然发生缩放的情况； 免去以下计算，以当前显示大小为准 */
    if (CGRectEqualToRect(kRoundFrame(self.frame), kRoundFrame(rect)) || (kRound(self.zoomScale) == kRound(self.maximumZoomScale) && kRound(scale) > 1.f)) {
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             /** 只需要移动到中点 */
                             self.center = CGPointMake(self.superview.center.x-self.offsetSuperCenter.x/2, self.superview.center.y-self.offsetSuperCenter.y/2);
                             self.saveRect = self.frame;
                             
                             if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginZooming:)]) {
                                 void (^block)(CGRect) = [self.clippingDelegate picker_clippingViewWillBeginZooming:self];
                                 if (block) block(self.frame);
                             }
                         } completion:^(BOOL finished) {
                             if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndZooming:)]) {
                                 [self.clippingDelegate picker_clippingViewDidEndZooming:self];
                             }
                             if (completion) {
                                 completion();
                             }
                         }];
        return;
    }
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    /** 计算缩放比例 */
    CGFloat zoomScale = MIN(self.zoomScale * scale, self.maximumZoomScale);
    /** 特殊图片计算 比例100:1 或 1:100 的情况 */
    CGRect zoomViewRect = CGRectApplyAffineTransform(self.zoomingView.frame, self.transform);
    scaledWidth = MIN(scaledWidth, CGRectGetWidth(zoomViewRect) * (zoomScale / self.minimumZoomScale));
    scaledHeight = MIN(scaledHeight, CGRectGetHeight(zoomViewRect) * (zoomScale / self.minimumZoomScale));
    
    /** 计算实际显示坐标 */
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.superview.bounds) - scaledWidth) / 2 - self.offsetSuperCenter.x/2,
                                 (CGRectGetHeight(self.superview.bounds) - scaledHeight) / 2  - self.offsetSuperCenter.y/2,
                                 scaledWidth,
                                 scaledHeight);
    
    /** 计算偏移值 */
    __block CGPoint contentOffset = self.contentOffset;
    if (!([self verifyRect:cropRect] && zoomScale == self.zoomScale)) { /** 实际位置与当前位置一致不做位移处理 && 缩放系数一致 */
        /** 获取相对坐标 */
        CGRect zoomRect = [self.superview convertRect:rect toView:self];
        contentOffset.x = zoomRect.origin.x * zoomScale / self.zoomScale;
        contentOffset.y = zoomRect.origin.y * zoomScale / self.zoomScale;
        
        /** 计算实际可滚动的范围，避免contentOffset超出滚动范围的情况。 */
        CGSize contentSize = self.zoomingView.picker_size;
        contentSize.width = contentSize.width * zoomScale / self.zoomScale;
        contentSize.height = contentSize.height * zoomScale / self.zoomScale;
        
        CGPoint maxContentOffset = CGPointMake(contentSize.width - cropRect.size.width, contentSize.height - cropRect.size.height);
        if (contentOffset.x > maxContentOffset.x) {
            contentOffset.x = maxContentOffset.x;
        }
        
        if (contentOffset.y > maxContentOffset.y) {
            contentOffset.y = maxContentOffset.y;
        }
    }
    
    
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = cropRect;
                         self.saveRect = self.frame;
                         [self setZoomScale:zoomScale];
                         /** 重新调整contentSize */
                         self.contentSize = self.zoomingView.picker_size;
                         [self setContentOffset:contentOffset];
                         
                         /** 设置完实际大小后再次计算最小缩放系数 */
                         [self resetMinimumZoomScale];
                         [self setZoomScale:self.zoomScale];
                         
                         if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginZooming:)]) {
                             void (^block)(CGRect) = [self.clippingDelegate picker_clippingViewWillBeginZooming:self];
                             if (block) block(self.frame);
                         }
                     } completion:^(BOOL finished) {
                         if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndZooming:)]) {
                             [self.clippingDelegate picker_clippingViewDidEndZooming:self];
                         }
                         if (completion) {
                             completion();
                         }
                     }];
}

#pragma mark 放大到指定坐标(必须大于当前坐标)
- (void)zoomInToRect:(CGRect)toRect
{
    /** 屏幕在滚动时 不触发该功能 */
    if (self.dragging || self.decelerating) {
        return;
    }
    CGRect zoomingRect = [self convertRect:self.zoomingView.frame toView:self.superview];
    /** 判断坐标是否超出当前坐标范围 */
    if ((CGRectGetMinX(toRect) + FLT_EPSILON) < CGRectGetMinX(zoomingRect)
        || (CGRectGetMinY(toRect) + FLT_EPSILON) < CGRectGetMinY(zoomingRect)
        || (CGRectGetMaxX(toRect) - FLT_EPSILON) > (CGRectGetMaxX(zoomingRect)+0.5) /** 兼容计算过程的误差0.几的情况 */
        || (CGRectGetMaxY(toRect) - FLT_EPSILON) > (CGRectGetMaxY(zoomingRect)+0.5)
        ) {
        
        /** 取最大值缩放 */
        CGRect myFrame = self.frame;
        myFrame.origin.x = MIN(myFrame.origin.x, toRect.origin.x);
        myFrame.origin.y = MIN(myFrame.origin.y, toRect.origin.y);
        myFrame.size.width = MAX(myFrame.size.width, toRect.size.width);
        myFrame.size.height = MAX(myFrame.size.height, toRect.size.height);
        self.frame = myFrame;
        
        [self resetMinimumZoomScale];
        [self setZoomScale:self.zoomScale];
    }
    
}

#pragma mark 旋转
- (void)rotateClockwise:(BOOL)clockwise
{
    /** 屏幕在滚动时 不触发该功能 */
    if (self.dragging || self.decelerating) {
        return;
    }
    if (!_isRotating) {
        _isRotating = YES;
        
        NSInteger newAngle = self.angle;
        newAngle = clockwise ? newAngle + 90 : newAngle - 90;
        if (newAngle <= -360 || newAngle >= 360)
            newAngle = 0;
        
        _angle = newAngle;

        [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.8f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            [self transformRotate:self.angle];
            
            if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginZooming:)]) {
                void (^block)(CGRect) = [self.clippingDelegate picker_clippingViewWillBeginZooming:self];
                if (block) block(self.frame);
            }
            
        } completion:^(BOOL complete) {
            self->_isRotating = NO;
            if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndZooming:)]) {
                [self.clippingDelegate picker_clippingViewDidEndZooming:self];
            }
        }];
        
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self.displayView setNeedsDisplay];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginDragging:)]) {
        [self.clippingDelegate picker_clippingViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndDecelerating:)]) {
            [self.clippingDelegate picker_clippingViewDidEndDecelerating:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndDecelerating:)]) {
        [self.clippingDelegate picker_clippingViewDidEndDecelerating:self];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
    if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewWillBeginZooming:)]) {
        void (^block)(CGRect) = [self.clippingDelegate picker_clippingViewWillBeginZooming:self];
        block(self.frame);
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    if (scrollView.isZooming || scrollView.isZoomBouncing) {
        /** 代码调整zoom，会导致居中计算错误，必须2指控制UI自动缩放时才调用 */
        [self refreshImageZoomViewCenter];
    }
//    [self.displayView setNeedsDisplay];
    if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidZoom:)]) {
        [self.clippingDelegate picker_clippingViewDidZoom:self];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if ([self.clippingDelegate respondsToSelector:@selector(picker_clippingViewDidEndZooming:)]) {
        [self.clippingDelegate picker_clippingViewDidEndZooming:self];
    }
}

#pragma mark - Private
- (void)refreshImageZoomViewCenter {
    
    CGRect rect = CGRectApplyAffineTransform(self.frame, self.transform);
    
    CGFloat offsetX = (rect.size.width > self.contentSize.width) ? ((rect.size.width - self.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (rect.size.height > self.contentSize.height) ? ((rect.size.height - self.contentSize.height) * 0.5) : 0.0;
    self.zoomingView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
}

#pragma mark - 验证当前大小是否被修改
- (BOOL)verifyRect:(CGRect)r_rect
{
    /** 计算缩放率 */
    CGRect rect = CGRectApplyAffineTransform(r_rect, self.transform);
    /** 模糊匹配 */
    BOOL isEqual = CGRectEqualToRect(rect, self.frame);
    
    if (isEqual == NO) {
        /** 精准验证 */
        BOOL x = kRound(CGRectGetMinX(rect)) == kRound(CGRectGetMinX(self.frame));
        BOOL y = kRound(CGRectGetMinY(rect)) == kRound(CGRectGetMinY(self.frame));
        BOOL w = kRound(CGRectGetWidth(rect)) == kRound(CGRectGetWidth(self.frame));
        BOOL h = kRound(CGRectGetHeight(rect)) == kRound(CGRectGetHeight(self.frame));
        isEqual = x && y && w && h;
    }
    return isEqual;
}

#pragma mark - 旋转视图
- (void)transformRotate:(NSInteger)angle
{
    //Convert the new angle to radians
    CGFloat angleInRadians = 0.0f;
    switch (angle) {
        case 90:    angleInRadians = M_PI_2;            break;
        case -90:   angleInRadians = -M_PI_2;           break;
        case 180:   angleInRadians = M_PI;              break;
        case -180:  angleInRadians = -M_PI;             break;
        case 270:   angleInRadians = (M_PI + M_PI_2);   break;
        case -270:  angleInRadians = -(M_PI + M_PI_2);  break;
        default:                                        break;
    }
    
    /** 重置变形 */
//    self.transform = CGAffineTransformIdentity;
    /** 不用重置变形，使用center与bounds来计算原来的frame */
    CGPoint center = self.center;
    CGRect bounds = self.bounds;
    CGRect oldRect = CGRectMake(center.x-0.5*bounds.size.width, center.y-0.5*bounds.size.height, bounds.size.width, bounds.size.height);
    CGFloat width = CGRectGetWidth(oldRect);
    CGFloat height = CGRectGetHeight(oldRect);
    if (angle%180 != 0) { /** 旋转基数时需要互换宽高 */
        CGFloat tempWidth = width;
        width = height;
        height = tempWidth;
    }
    /** 改变变形之前获取偏移量，变形后再计算偏移量比例移动 */
    CGPoint contentOffset = self.contentOffset;
    /** 调整变形 */
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, angleInRadians);
    self.transform = transform;
    
    /** 计算变形后的坐标拉伸到编辑范围 */
    self.frame = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(width, height), self.editRect);
    /** 重置最小缩放比例 */
    [self resetMinimumZoomScale];
    /** 计算缩放比例 */
    CGFloat scale = MIN(CGRectGetWidth(self.frame) / width, CGRectGetHeight(self.frame) / height);
    /** 转移缩放目标 */
    self.zoomScale *= scale;
    /** 修正旋转后到偏移量 */
    contentOffset.x *= scale;
    contentOffset.y *= scale;
    self.contentOffset = contentOffset;
}

#pragma mark - 重置最小缩放比例
- (void)resetMinimumZoomScale
{
    /** 重置最小缩放比例 */
    CGRect rotateNormalRect = CGRectApplyAffineTransform(self.normalRect, self.transform);
    if (CGSizeEqualToSize(rotateNormalRect.size, CGSizeZero)) {
        /** size为0时候不能继续，否则minimumZoomScale=+Inf，会无法缩放 */
        return;
    }
    CGFloat minimumZoomScale = MAX(CGRectGetWidth(self.frame) / CGRectGetWidth(rotateNormalRect), CGRectGetHeight(self.frame) / CGRectGetHeight(rotateNormalRect));
    self.minimumZoomScale = minimumZoomScale;
}

#pragma mark - 重写父类方法

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return [super touchesShouldCancelInContentView:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.zoomingView) { /** 不触发下一层UI响应 */
        return self;
    }
    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /** 控制自身手势 */
    return self.useGesture;
}

#pragma mark - TFY_EditingProtocol

#pragma mark - 数据
- (NSDictionary *)photoEditData
{
    NSMutableDictionary *data = [@{} mutableCopy];
    if ([self canReset]) { /** 可还原证明已编辑过 */
        NSDictionary *myData = @{kTFYClippingViewData_frame:[NSValue valueWithCGRect:self.saveRect]
                                 , kTFYClippingViewData_zoomScale:@(self.zoomScale)
                                 , kTFYClippingViewData_contentSize:[NSValue valueWithCGSize:self.contentSize]
                                 , kTFYClippingViewData_contentOffset:[NSValue valueWithCGPoint:self.contentOffset]
                                 , kTFYClippingViewData_minimumZoomScale:@(self.minimumZoomScale)
                                 , kTFYClippingViewData_maximumZoomScale:@(self.maximumZoomScale)
                                 , kTFYClippingViewData_clipsToBounds:@(self.clipsToBounds)
                                 , kTFYClippingViewData_first_minimumZoomScale:@(self.first_minimumZoomScale)
                                 , kTFYClippingViewData_transform:[NSValue valueWithCGAffineTransform:self.transform]
                                 , kTFYClippingViewData_angle:@(self.angle)};
        [data setObject:myData forKey:kTFYClippingViewData];
    }
    
    NSDictionary *zoomingViewData = self.zoomingView.photoEditData;
    if (zoomingViewData) [data setObject:zoomingViewData forKey:kTFYClippingViewData_zoomingView];
    
    if (data.count) {
        return data;
    }
    return nil;
}

- (void)setPhotoEditData:(NSDictionary *)photoEditData
{
    NSDictionary *myData = photoEditData[kTFYClippingViewData];
    if (myData) {
        self.transform = [myData[kTFYClippingViewData_transform] CGAffineTransformValue];
        self.angle = [myData[kTFYClippingViewData_angle] integerValue];
        self.saveRect = [myData[kTFYClippingViewData_frame] CGRectValue];
        self.frame = self.saveRect;
        self.minimumZoomScale = [myData[kTFYClippingViewData_minimumZoomScale] floatValue];
        self.maximumZoomScale = [myData[kTFYClippingViewData_maximumZoomScale] floatValue];
        self.zoomScale = [myData[kTFYClippingViewData_zoomScale] floatValue];
        self.contentSize = [myData[kTFYClippingViewData_contentSize] CGSizeValue];
        self.contentOffset = [myData[kTFYClippingViewData_contentOffset] CGPointValue];
        self.clipsToBounds = [myData[kTFYClippingViewData_clipsToBounds] boolValue];
        self.first_minimumZoomScale = [myData[kTFYClippingViewData_first_minimumZoomScale] floatValue];
    }
    self.zoomingView.photoEditData = photoEditData[kTFYClippingViewData_zoomingView];
}


@end
