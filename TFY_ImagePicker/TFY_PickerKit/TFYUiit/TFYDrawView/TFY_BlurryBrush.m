//
//  TFY_BlurryBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BlurryBrush.h"
#import "TFY_Brush+create.h"
#import "TFY_BrushCache.h"
#import "UIImage+picker.h"
NSString *const TFYBlurryBrushImageColor = @"TFYBlurryBrushImageColor";

@implementation TFY_BlurryBrush
@synthesize lineColor = _lineColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_lineColor = nil;
        self.level = 5;
        self.lineWidth = 25;
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"TFY_BlurryBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYBlurryBrushImageColor];
    
    NSAssert(color!=nil, @"call TFY_BlurryBrush loadBrushImage:radius:canvasSize:useCache:complete: method.");
    
    return color;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[TFYPaintBrushLineColor];
    if (lineColor) {
        [[TFY_BrushCache share] setForceObject:lineColor forKey:TFYBlurryBrushImageColor];
    }
    return [super drawLayerWithTrackDict:trackDict];
    
}

+ (void)loadBrushImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[TFY_BrushCache share] removeObjectForKey:TFYBlurryBrushImageColor];
    }
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYBlurryBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        //                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIColor *patternColor = [image picker_patternGaussianColorWithSize:canvasSize filterHandler:^CIFilter *(CIImage *ciimage) {
                //高斯模糊滤镜
                CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [filter setDefaults];
                [filter setValue:ciimage forKey:kCIInputImageKey];
                //value 改变模糊效果值
                [filter setValue:@(radius) forKey:kCIInputRadiusKey];
                return filter;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                        NSLog(@"used time : %fs", ([[NSDate date] timeIntervalSince1970] - time));
                if (patternColor) {
                    [[TFY_BrushCache share] setForceObject:patternColor forKey:TFYBlurryBrushImageColor];
                }
                
                if (complete) {
                    complete((BOOL)patternColor);
                }
            });
        });
    } else {
        if (complete) {
            complete(NO);
        }
    }
}

+ (BOOL)blurryBrushCache
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYBlurryBrushImageColor];
    return (BOOL)color;
}

@end
