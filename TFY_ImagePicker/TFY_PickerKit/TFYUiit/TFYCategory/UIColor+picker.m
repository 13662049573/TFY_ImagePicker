//
//  UIColor+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "UIColor+picker.h"

@implementation UIColor (picker)

+ (UIColor *)picker_colorTransformFrom:(UIColor*)fromColor to:(UIColor *)toColor progress:(CGFloat)progress {

    if (!fromColor || !toColor) {
        NSLog(@"Warning !!! color is nil");
        return [UIColor blackColor];
    }

    progress = progress >= 1 ? 1 : progress;

    progress = progress <= 0 ? 0 : progress;
    
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);
    
    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    
    CGFloat red = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat green = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat blue = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

- (BOOL)picker_isEqualToColor:(UIColor *)color{
    return CGColorEqualToColor(self.CGColor, color.CGColor);;
}

@end
