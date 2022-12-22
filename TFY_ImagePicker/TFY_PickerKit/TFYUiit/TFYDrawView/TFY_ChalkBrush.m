//
//  TFY_ChalkBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_ChalkBrush.h"
#import "TFY_BrushCache.h"

NSString *const TFYChalkBrushImage = @"ChalkImage";
NSString *const TFYChalkBrushColor = @"ChalkColor";

@interface TFY_ChalkBrush ()
@property (nonatomic, copy) NSString *name;
@end

@implementation TFY_ChalkBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineWidth = 12.5;
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)name
{
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

- (UIColor *)lineColor
{
    TFY_BrushCache *imageCache = [TFY_BrushCache share];
    UIColor *color = [imageCache objectForKey:TFYChalkBrushColor];
    if (color) {
        return color;
    }
    UIImage *image =  [imageCache objectForKey:TFYChalkBrushImage];
    if (image == nil) {
        
        NSAssert(self.name!=nil, @"TFY_ChalkBrush name is nil.");
        
        if (self.bundle) {
            /**
             framework内部加载
             */
            image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:self.name ofType:nil]];
        } else {
            /**
             framework外部加载
             */
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.name ofType:nil]];
        }
        
        [[TFY_BrushCache share] setObject:image forKey:TFYChalkBrushImage];
    }
    
    @autoreleasepool {
        //redraw image using device context
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [super.lineColor setFill];
        CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        UIRectFill(bounds);
        //Draw the tinted image in context
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    color = [UIColor colorWithPatternImage:image];
    [imageCache setObject:color forKey:TFYChalkBrushColor];
    
    return color;
}

- (void)setLineColor:(UIColor *)lineColor
{
    if (super.lineColor != lineColor) {
        [[TFY_BrushCache share] removeObjectForKey:TFYChalkBrushColor];
        [super setLineColor:lineColor];
    }
}


@end
