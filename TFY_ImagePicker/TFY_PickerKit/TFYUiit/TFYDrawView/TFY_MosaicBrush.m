//
//  TFY_MosaicBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_MosaicBrush.h"
#import "TFY_Brush+create.h"
#import "TFY_BrushCache.h"
#import "UIImage+picker.h"

NSString *const TFYMosaicBrushImageColor = @"TFYMosaicBrushImageColor";

@implementation TFY_MosaicBrush
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
    NSAssert(NO, @"TFY_MosaicBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYMosaicBrushImageColor];
    
    NSAssert(color!=nil, @"call TFY_MosaicBrush loadBrushImage:scale:canvasSize:useCache:complete: method.");
    
    return color;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[TFYPaintBrushLineColor];
    if (lineColor) {
        [[TFY_BrushCache share] setForceObject:lineColor forKey:TFYMosaicBrushImageColor];
    }
    return [super drawLayerWithTrackDict:trackDict];
    
}

+ (void)loadBrushImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[TFY_BrushCache share] removeObjectForKey:TFYMosaicBrushImageColor];
    }
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYMosaicBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIColor *patternColor = [image picker_patternGaussianColorWithSize:canvasSize filterHandler:^CIFilter *(CIImage *ciimage) {
                //高斯模糊滤镜
                CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
                [filter setDefaults];
                [filter setValue:ciimage forKey:kCIInputImageKey];
                //value 改变马赛克的大小
                [filter setValue:@(scale) forKey:kCIInputScaleKey];
                return filter;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (patternColor) {
                    [[TFY_BrushCache share] setForceObject:patternColor forKey:TFYMosaicBrushImageColor];
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

+ (BOOL)mosaicBrushCache
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYMosaicBrushImageColor];
    return (BOOL)color;
}

@end
