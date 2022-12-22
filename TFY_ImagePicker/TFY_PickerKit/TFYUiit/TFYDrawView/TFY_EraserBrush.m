//
//  TFY_EraserBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_EraserBrush.h"
#import "TFY_Brush+create.h"
#import "TFY_BrushCache.h"
#import "UIImage+picker.h"

NSString *const TFYEraserBrushImageColor = @"TFYEraserBrushImageColor";
NSString *const TFYEraserBrushImageLayers = @"TFYEraserBrushImageLayers";

@implementation TFY_EraserBrush
@synthesize lineColor = _lineColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_lineColor = nil;
        self.lineWidth += 4;
    }
    return self;
}


- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"TFY_EraserBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageColor];
    
    NSAssert(color!=nil, @"call TFY_EraserBrush loadBrushImage:radius:canvasSize:useCache:complete: method.");
    
    return color;
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    CALayer *layer = [super createDrawLayerWithPoint:point];
    if (layer) {
        
        NSHashTable *layers = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageLayers];
        [layers addObject:layer];
    }
    return layer;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[TFYPaintBrushLineColor];
    if (lineColor) {
        [[TFY_BrushCache share] setForceObject:lineColor forKey:TFYEraserBrushImageColor];
    }
    CALayer *layer = [super drawLayerWithTrackDict:trackDict];
    if (layer) {
        NSHashTable *layers = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageLayers];
        [layers addObject:layer];
    }
    return layer;
}

+ (void)loadEraserImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    
    NSHashTable *layers = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageLayers];
    if (layers == nil) {
        layers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [[TFY_BrushCache share] setForceObject:layers forKey:TFYEraserBrushImageLayers];
    }
    
    if (!useCache) {
        [[TFY_BrushCache share] removeObjectForKey:TFYEraserBrushImageColor];
    }
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        //                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIColor *patternColor = [image picker_patternGaussianColorWithSize:canvasSize filterHandler:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                        NSLog(@"used time : %fs", ([[NSDate date] timeIntervalSince1970] - time));
                if (patternColor) {
                    [[TFY_BrushCache share] setForceObject:patternColor forKey:TFYEraserBrushImageColor];
                }
                for (CAShapeLayer *layer in layers) {
                    layer.strokeColor = patternColor.CGColor;
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

+ (BOOL)eraserBrushCache
{
    UIColor *color = [[TFY_BrushCache share] objectForKey:TFYEraserBrushImageColor];
    return (BOOL)color;
}

@end
