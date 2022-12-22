//
//  UIView+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "UIView+picker.h"

@implementation UIView (picker)

- (void)setPicker_x:(CGFloat)picker_x {
    CGRect frame = self.frame;
    frame.origin.x = picker_x;
    self.frame = frame;
}

- (void)setPicker_y:(CGFloat)picker_y {
    CGRect frame = self.frame;
    frame.origin.y = picker_y;
    self.frame = frame;
}

- (CGFloat)picker_x {
    return self.frame.origin.x;
}

- (CGFloat)picker_y {
    return self.frame.origin.y;
}

- (void)setPicker_centerX:(CGFloat)picker_centerX {
    CGPoint center = self.center;
    center.x = picker_centerX;
    self.center = center;
}

- (CGFloat)picker_centerX {
    return self.center.x;
}

- (void)setPicker_centerY:(CGFloat)picker_centerY {
    CGPoint center = self.center;
    center.y = picker_centerY;
    self.center = center;
}

- (CGFloat)picker_centerY {
    return self.center.y;
}

- (void)setPicker_width:(CGFloat)picker_width {
    CGRect frame = self.frame;
    frame.size.width = picker_width;
    self.frame = frame;
}

- (void)setPicker_height:(CGFloat)picker_height {
    CGRect frame = self.frame;
    frame.size.height = picker_height;
    self.frame = frame;
}

- (CGFloat)picker_width {
    return self.frame.size.width;
}

- (CGFloat)picker_height {
    return self.frame.size.height;
}

- (void)setPicker_size:(CGSize)picker_size {
    CGRect frame = self.frame;
    frame.size = picker_size;
    self.frame = frame;
}

- (CGSize)picker_size {
    return self.frame.size;
}

- (void)setPicker_origin:(CGPoint)picker_origin {
    CGRect frame = self.frame;
    frame.origin = picker_origin;
    self.frame = frame;
}

- (CGPoint)picker_origin {
    return self.frame.origin;
}


- (UIImage *)picker_captureImage
{
    return [self picker_captureImageAtFrame:CGRectZero];
}

- (UIImage *)picker_captureImageAtFrame:(CGRect)rect
{
    UIImage* image = nil;
    if (/* DISABLES CODE */ (YES)) {
        CGSize size = self.bounds.size;
        CGPoint point = self.bounds.origin;
        if (!CGRectEqualToRect(CGRectZero, rect)) {
            size = rect.size;
            point = CGPointMake(-rect.origin.x, -rect.origin.y);
        }
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [self drawViewHierarchyInRect:(CGRect){point, self.bounds.size} afterScreenUpdates:YES];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
    } else {
        
            BOOL translateCTM = !CGRectEqualToRect(CGRectZero, rect);
        
            if (!translateCTM) {
                rect = self.frame;
            }
        
            /** 参数取整，否则可能会出现1像素偏差 */
            /** 有小数部分才调整差值 */
#define lfme_fixDecimal(d) ((fmod(d, (int)d)) > 0.59f ? ((int)(d+0.5)*1.f) : (((fmod(d, (int)d)) < 0.59f && (fmod(d, (int)d)) > 0.1f) ? ((int)(d)*1.f+0.5f) : (int)(d)*1.f))
            rect.origin.x = lfme_fixDecimal(rect.origin.x);
            rect.origin.y = lfme_fixDecimal(rect.origin.y);
            rect.size.width = lfme_fixDecimal(rect.size.width);
            rect.size.height = lfme_fixDecimal(rect.size.height);
#undef lfme_fixDecimal
            CGSize size = rect.size;
        
        @autoreleasepool {
            //1.开启上下文
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (translateCTM) {
                /** 移动上下文 */
                CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
            }
            //2.绘制图层
            [self.layer renderInContext: context];
            
            //3.从上下文中获取新图片
            image = UIGraphicsGetImageFromCurrentImageContext();
            
            //4.关闭图形上下文
            UIGraphicsEndImageContext();
        }
    }
    return image;
}

- (UIColor *)picker_colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (void)picker_setCornerRadius:(float)cornerRadius
{
    if (cornerRadius > 0) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = cornerRadius;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 0;
        self.layer.shouldRasterize = NO;
        self.layer.rasterizationScale = 1.f;
    }
}

- (void)picker_setCornerRadiusWithoutMasks:(float)cornerRadius
{
    if (cornerRadius > 0) {
        self.layer.cornerRadius = cornerRadius;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.shouldRasterize = NO;
        self.layer.rasterizationScale = 1.f;
    }
}

/** 设置阴影 */
- (void)picker_updateSquareShadow
{
    CGFloat shadowRadius = self.layer.shadowRadius;
    
    if (shadowRadius == 0) {
        self.layer.shadowPath = nil;
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(-shadowRadius/2, 0, shadowRadius, self.bounds.size.height-shadowRadius)];
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(shadowRadius/2, -shadowRadius/2, self.bounds.size.width-shadowRadius, shadowRadius)];
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.size.width-shadowRadius/2, shadowRadius, shadowRadius, self.bounds.size.height-shadowRadius)];
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.bounds.size.height-shadowRadius/2, self.bounds.size.width-shadowRadius, shadowRadius)];
    [path appendPath:topPath];
    [path appendPath:leftPath];
    [path appendPath:rightPath];
    [path appendPath:bottomPath];
    
    self.layer.shadowPath = path.CGPath;
}

/** 设置阴影（圆） */
- (void)picker_updateCircleShadow
{
    CGFloat shadowRadius = self.layer.shadowRadius;
    
    if (shadowRadius == 0) {
        self.layer.shadowPath = nil;
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -shadowRadius/2, -shadowRadius/2) cornerRadius:self.bounds.size.width/2];
    path.lineJoinStyle = kCGLineJoinRound;
    
    self.layer.shadowPath = path.CGPath;
}

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(OscillatoryAnimationType)type{
    NSNumber *animationScale1 = type == OscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == OscillatoryAnimationToBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

@end
