//
//  TFY_VideoTrimmerGridView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_VideoTrimmerGridView.h"
#import "TFY_ResizeControl.h"
#import "TFY_VideoTrimmerGridLayer.h"
#import "TFY_GridMaskLayer.h"
#import "TFYCategory.h"

/** 可控范围 */
const CGFloat kVideoTrimmerGridControlWidth = 25.f;
const CGFloat kVideoTrimmerGridLayerLineWidth = 2.f;

@interface TFY_ResizeImageControl : TFY_ResizeControl
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic, nullable) UIColor *color;
@property (nonatomic, assign) CGRect imageRect;
@end

@implementation TFY_ResizeImageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageRect = self.bounds;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (self.image) {
        [self.image drawInRect:self.imageRect];
    } else {
        //// Frames
        CGRect bubbleFrame = self.imageRect;
        
        //// Rounded Rectangle Drawing
        CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame), CGRectGetWidth(bubbleFrame), CGRectGetHeight(bubbleFrame));
        UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: CGSizeMake(3, 3)];
        
        [roundedRectanglePath closePath];
        [self.color setFill];
        [roundedRectanglePath fill];
        
        
        CGFloat lineWidth = 1.5f;
        CGRect decoratingRect = CGRectMake(CGRectGetMinX(bubbleFrame)+CGRectGetWidth(bubbleFrame)/3-lineWidth/2, (CGRectGetHeight(bubbleFrame)-15.f)/2, lineWidth, 15.f);
        UIBezierPath *decoratingPath = [UIBezierPath bezierPathWithRoundedRect:decoratingRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii: CGSizeMake(1, 1)];
        [decoratingPath closePath];
        [[UIColor colorWithWhite:0.5 alpha:1.f] setFill];
        [decoratingPath fill];
        
        CGRect decoratingRect1 = decoratingRect;
        decoratingRect1.origin.x += CGRectGetWidth(bubbleFrame)/3;
        UIBezierPath *decoratingPath1 = [UIBezierPath bezierPathWithRoundedRect:decoratingRect1 byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii: CGSizeMake(1, 1)];
        [decoratingPath1 closePath];
        [[UIColor colorWithWhite:0.5 alpha:1.f] setFill];
        [decoratingPath1 fill];
    }
}

@end

@interface TFY_VideoTrimmerGridView ()<TFYresizeConrolDelegate>

@property (nonatomic, weak) TFY_ResizeImageControl *leftCornerView;

@property (nonatomic, weak) TFY_ResizeImageControl *rightCornerView;

@property (nonatomic, weak) TFY_ResizeControl *centerCornerView;

/** 边框 */
@property (nonatomic, weak) TFY_VideoTrimmerGridLayer *gridLayer;
/** 背景 */
@property (nonatomic, weak) TFY_VideoTrimmerGridLayer *bg_gridLayer;
/** 遮罩 */
@property (nonatomic, weak) TFY_GridMaskLayer *gridMaskLayer;
/** 进度 */
@property (nonatomic, weak) UIView *slider;

@property (nonatomic, assign) CGRect initialRect;
@end

@implementation TFY_VideoTrimmerGridView

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
    /** 进度 */
    UIView *slider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, self.bounds.size.height)];
    slider.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8f];
    slider.userInteractionEnabled = NO;
    [self addSubview:slider];
    _slider = slider;
    
    /** 背景 */
    TFY_VideoTrimmerGridLayer *bg_gridLayer = [[TFY_VideoTrimmerGridLayer alloc] init];
    bg_gridLayer.frame = self.bounds;
    bg_gridLayer.lineWidth = kVideoTrimmerGridLayerLineWidth;
    bg_gridLayer.bgColor = [UIColor clearColor];
    bg_gridLayer.gridColor = [UIColor colorWithWhite:1.f alpha:0.5f];
    bg_gridLayer.gridRect = self.bounds;
    bg_gridLayer.hidden = YES;
    [self.layer addSublayer:bg_gridLayer];
    self.bg_gridLayer = bg_gridLayer;
    
    /** 遮罩 */
    TFY_GridMaskLayer *gridMaskLayer = [[TFY_GridMaskLayer alloc] init];
    gridMaskLayer.frame = self.bounds;
    gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:.5f].CGColor;
    [self.layer addSublayer:gridMaskLayer];
    self.gridMaskLayer = gridMaskLayer;
    
    /** 边框 */
    TFY_VideoTrimmerGridLayer *gridLayer = [[TFY_VideoTrimmerGridLayer alloc] init];
    gridLayer.frame = self.bounds;
    gridLayer.lineWidth = kVideoTrimmerGridLayerLineWidth;
    gridLayer.bgColor = [UIColor clearColor];
    gridLayer.gridColor = [UIColor whiteColor];
    [self.layer addSublayer:gridLayer];
    self.gridLayer = gridLayer;
    
    /** 左右控制器 */
    self.leftCornerView = [self createResizeControl];
    self.rightCornerView = [self createResizeControl];
    self.centerCornerView = [self createCenterResizeControl];
    
    self.gridRect = self.bounds;
    self.controlMinWidth = self.frame.size.width * 0.33f;
    self.controlMaxWidth = self.frame.size.width;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gridLayer.frame = self.bounds;
    self.bg_gridLayer.frame = self.bounds;
    self.gridMaskLayer.frame = self.bounds;
    
    CGRect rect = self.gridRect;
    
    self.leftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.leftCornerView.bounds) / 2, (CGRectGetHeight(rect) - CGRectGetHeight(self.leftCornerView.bounds)) / 2, self.leftCornerView.bounds.size};
    self.rightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.rightCornerView.bounds) / 2, (CGRectGetHeight(rect) - CGRectGetHeight(self.rightCornerView.bounds)) / 2, self.rightCornerView.bounds.size};
    
    self.centerCornerView.frame = CGRectMake(CGRectGetMaxX(self.leftCornerView.frame), CGRectGetMinY(self.leftCornerView.frame), CGRectGetMinX(self.rightCornerView.frame)-CGRectGetMaxX(self.leftCornerView.frame), CGRectGetHeight(self.leftCornerView.frame));
}

- (BOOL)isEnabledLeftCorner
{
    return self.leftCornerView.userInteractionEnabled;
}

- (void)setEnabledLeftCorner:(BOOL)enabledLeftCorner
{
    self.leftCornerView.userInteractionEnabled = enabledLeftCorner;
}

- (BOOL)isEnabledRightCorner
{
    return self.rightCornerView.userInteractionEnabled;
}

- (void)setEnabledRightCorner:(BOOL)enabledRightCorner
{
    self.rightCornerView.userInteractionEnabled = enabledRightCorner;
}

- (void)setProgress:(double)progress
{
    if (isnan(progress) || progress < 0) {
        return;
    }
    _progress = progress;
    _slider.picker_x = progress*self.picker_width;
}

- (void)setHiddenProgress:(BOOL)hidden
{
    _slider.hidden = hidden;
}

#pragma mark - TFY_resizeConrolDelegate

- (void)picker_resizeConrolDidBeginResizing:(TFY_ResizeControl *)resizeConrol
{
    [self bringSubviewToFront:resizeConrol];
    
    self.bg_gridLayer.hidden = NO;
    self.initialRect = self.gridRect;
    
    if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerGridViewDidBeginResizing:)]) {
        [self.delegate picker_videoTrimmerGridViewDidBeginResizing:self];
    }
}

- (void)picker_resizeConrolDidResizing:(TFY_ResizeControl *)resizeConrol
{
    CGRect gridRect = [self cropRectMakeWithResizeControlView:resizeConrol];
    
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        [self setGridRect:gridRect animated:NO];
        if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerGridViewDidResizing:)]) {
            [self.delegate picker_videoTrimmerGridViewDidResizing:self];
        }
    }
}

- (void)picker_resizeConrolDidEndResizing:(TFY_ResizeControl *)resizeConrol
{
    self.bg_gridLayer.hidden = YES;
    self.leftCornerView.enabled = YES;
    self.rightCornerView.enabled = YES;
    self.centerCornerView.enabled = YES;
    if ([self.delegate respondsToSelector:@selector(picker_videoTrimmerGridViewDidEndResizing:)]) {
        [self.delegate picker_videoTrimmerGridViewDidEndResizing:self];
    }
}

- (void)setGridRect:(CGRect)gridRect
{
    [self setGridRect:gridRect animated:NO];
}

- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated
{
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        [self.gridLayer setGridRect:gridRect animated:animated];
        self.gridMaskLayer.maskRect = self.gridRect;
        [self setNeedsLayout];
    }
}

#pragma mark - private
- (TFY_ResizeImageControl *)createResizeControl
{
    TFY_ResizeImageControl *control = [[TFY_ResizeImageControl alloc] initWithFrame:(CGRect){CGPointMake(0, -kVideoTrimmerGridLayerLineWidth/2), CGSizeMake(kVideoTrimmerGridControlWidth, self.bounds.size.height+kVideoTrimmerGridLayerLineWidth)}];
    control.color = [UIColor whiteColor];
    CGFloat imageWidth = 10.f;
    control.imageRect = CGRectMake((control.frame.size.width-imageWidth)/2, 0, imageWidth, control.frame.size.height);
    control.delegate = self;
    [self addSubview:control];
    return control;
}

- (TFY_ResizeControl *)createCenterResizeControl
{
    TFY_ResizeControl *control = [[TFY_ResizeControl alloc] initWithFrame:self.bounds];
    control.delegate = self;
    control.backgroundColor = [UIColor clearColor];
    [self addSubview:control];
    return control;
}

- (CGRect)cropRectMakeWithResizeControlView:(TFY_ResizeControl *)resizeControlView
{
    CGRect rect = self.gridRect;
    if (resizeControlView == self.leftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    } else if (resizeControlView == self.rightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    } else if (resizeControlView == self.centerCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect));
    }
    /** ps：
     此处判断 不能使用CGRectGet开头的方法，计算会有问题；
     当rect = (origin = (x = 50, y = 618), size = (width = 61, height = -488)) 时，
     CGRectGetMaxY(rect) = 618；CGRectGetHeight(rect) = 488
     */
    if (resizeControlView == self.leftCornerView) {
        /** 限制宽度 超出 最大限度 */
        if (rect.size.width > self.controlMaxWidth || rect.origin.x < 0) {
            if (rect.size.width > self.controlMaxWidth) {
                CGFloat diff = (self.controlMaxWidth - rect.size.width);
                rect.origin.x -= diff;
                rect.size.width += diff;
            } else {
                rect.origin.x = 0;
            }
        } else
        /** 限制宽度 超出 最小限度 */
        if (rect.size.width < self.controlMinWidth) {
            CGFloat diff = self.controlMinWidth - rect.size.width;
            rect.origin.x -= diff;
            rect.size.width += diff;
            /** 最小值大于自身宽度 */
            if (rect.origin.x < 0) {
                rect.size.width += rect.origin.x;
                rect.origin.x = 0;
            }
        }
    } else if (resizeControlView == self.rightCornerView) {
        /** 限制宽度 超出 最大限度 */
        if (rect.size.width > self.controlMaxWidth || rect.origin.x+rect.size.width > self.frame.size.width) {
            CGFloat diff = rect.size.width > self.controlMaxWidth ? (self.controlMaxWidth - rect.size.width) : (self.frame.size.width-(rect.origin.x+rect.size.width));
            rect.size.width += diff;
        } else
        /** 限制宽度 超出 最小限度 */
        if (rect.size.width < self.controlMinWidth) {
            CGFloat diff = self.controlMinWidth - rect.size.width;
            rect.size.width += diff;
            /** 最小值大于自身宽度 */
            if (rect.origin.x+rect.size.width > self.frame.size.width) {
                rect.size.width = self.frame.size.width - rect.origin.x;
            }
        }
    } else if (resizeControlView == self.centerCornerView) {
        if (rect.origin.x < 0.f){
            rect.origin.x = 0.f;
        } else if ((rect.origin.x+rect.size.width) > self.frame.size.width) {
            rect.origin.x = self.frame.size.width - rect.size.width;
        }
    }
    return rect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self.leftCornerView == view) {
        self.rightCornerView.enabled = NO;
        self.centerCornerView.enabled = NO;
    } else if (self.rightCornerView == view) {
        self.leftCornerView.enabled = NO;
        self.centerCornerView.enabled = NO;
    } else if (self.centerCornerView == view) {
        self.leftCornerView.enabled = NO;
        self.rightCornerView.enabled = NO;
    }
    return view;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    BOOL isHit = [super pointInside:point withEvent:event];
    
    if (!isHit) {
        return (CGRectContainsPoint(self.leftCornerView.frame, point) || CGRectContainsPoint(self.rightCornerView.frame, point)) || CGRectContainsPoint(self.centerCornerView.frame, point);
    }
    
    return isHit;
}

@end
