//
//  TFY_VideoTrimmerGridLayer.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_VideoTrimmerGridLayer.h"

@implementation TFY_VideoTrimmerGridLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        _lineWidth = 1.f;
        self.contentsScale = [[UIScreen mainScreen] scale];
        _bgColor = [UIColor clearColor];
        _gridColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setGridRect:(CGRect)gridRect
{
    [self setGridRect:gridRect animated:NO];
}

- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated
{
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        
        CGPathRef path = [self drawGrid];
        if (animated) {
            CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
            animate.duration = 0.25f;
            animate.fromValue = (__bridge id _Nullable)(self.path);
            animate.toValue = (__bridge id _Nullable)(path);
            //            animate.fillMode=kCAFillModeForwards;
            [self addAnimation:animate forKey:@"picker_videoGridLayer_contentsRectAnimate"];
        }
        
        self.path = path;
    }
}

- (CGPathRef)drawGrid
{
    self.fillColor = self.bgColor.CGColor;
    self.strokeColor = self.gridColor.CGColor;
    
    CGRect rct = self.gridRect;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rct];
    
    return path.CGPath;
}

@end
