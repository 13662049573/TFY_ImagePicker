//
//  TFY_SmearBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_SmearBrush.h"
#import "TFY_Brush+create.h"
#import "TFY_BrushCache.h"
#import "UIImage+picker.h"

NSString *const TFYSmearBrushImage = @"TFYSmearBrushImage";
NSString *const TFYSmearBrushName = @"TFYSmearBrushName";

NSString *const TFYSmearBrushPoints = @"TFYSmearBrushPoints";

// points sub data
NSString *const TFYSmearBrushPoint = @"TFYSmearBrushPoint";
NSString *const TFYSmearBrushAngle = @"TFYSmearBrushAngle";
NSString *const TFYSmearBrushColor = @"TFYSmearBrushColor";

@interface TFY_SmearBrush (color)
@end

@implementation TFY_SmearBrush (color)

#pragma mark - 获取屏幕的颜色块
- (UIColor *)colorOfPoint:(CGPoint)point
{
    UIImage *cacheImage = [[TFY_BrushCache share] objectForKey:TFYSmearBrushImage];
    
    NSAssert(cacheImage!=nil, @"call TFY_SmearBrush loadBrushImage:canvasSize:useCache:complete: method.");
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, cacheImage.size.width, cacheImage.size.height), point)) {
        return nil;
    }
    UIColor *color = nil;
    @autoreleasepool {
        
        NSUInteger width = cacheImage.size.width;
        NSUInteger height = cacheImage.size.height;
        
        unsigned char pixel[4] = {0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel,
                                                     1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextTranslateCTM(context, -point.x, point.y-(CGFloat)height);
        
//        [[[UIApplication sharedApplication] keyWindow].layer renderInContext:context];
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cacheImage.CGImage);
        
        CGContextRelease(context);
        color = [UIColor colorWithRed:pixel[0]/255.0
                                green:pixel[1]/255.0 blue:pixel[2]/255.0
                                alpha:pixel[3]/255.0];
    }
    return color;
}

@end

@interface TFY_SmearBrush ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*points;
@end

@implementation TFY_SmearBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.level = 5;
        self.lineWidth = 100;
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)name;
{
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

+ (void)loadBrushImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[TFY_BrushCache share] removeObjectForKey:TFYSmearBrushImage];
    }
    UIImage *cacheImage = [[TFY_BrushCache share] objectForKey:TFYSmearBrushImage];
    if (cacheImage) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIImage *patternImage = [image picker_patternGaussianImageWithSize:canvasSize filterHandler:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (patternImage) {
                    [[TFY_BrushCache share] setForceObject:patternImage forKey:TFYSmearBrushImage];
                }
                
                if (complete) {
                    complete((BOOL)patternImage);
                }
            });
        });
    } else {
        if (complete) {
            complete(NO);
        }
    }
}

+ (BOOL)smearBrushCache
{
    UIImage *cacheImage = [[TFY_BrushCache share] objectForKey:TFYSmearBrushImage];
    return (BOOL)cacheImage;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    
    UIImage *image = [[self class] cacheImageWithName:self.name bundle:self.bundle];
    
    CGFloat angle = TFYBrushAngleBetweenPoint(self.previousPoint, point);
    // 调整角度，顺着绘画方向。
    angle = 360-angle;
    // 随机坐标
    point.x += floorf(arc4random()%((int)(image.size.width)+1)) - image.size.width/2;
    point.y += floorf(arc4random()%((int)(image.size.height)+1)) - image.size.width/2;
    
    //转换屏幕坐标，获取颜色块
    UIColor *color = nil;
    UIView *drawView = (UIView *)self.layer.superlayer.delegate;
    if ([drawView isKindOfClass:[UIView class]]) {
//        CGPoint screenPoint = [drawView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        color = [self colorOfPoint:point];
    }

    CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:self.lineWidth point:point angle:angle color:color];
    
    [self.layer addSublayer:subLayer];
    
    // 记录坐标数据
    NSMutableDictionary *pointDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [pointDict setObject:NSStringFromCGPoint(point) forKey:TFYSmearBrushPoint];
    [pointDict setObject:@(angle) forKey:TFYSmearBrushAngle];
    
    if (color) {
        [pointDict setObject:color forKey:TFYSmearBrushColor];
    }
    [self.points addObject:pointDict];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    [super createDrawLayerWithPoint:point];
    _points = [NSMutableArray array];
    
    CALayer *layer = [[self class] createLayer];
    layer.picker_level = self.level;
    self.layer = layer;
    return layer;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.points.count) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{
                                                TFYSmearBrushPoints:self.points,
                                                TFYSmearBrushName:self.name
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[TFYBrushLineWidth] floatValue];
//    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[LFBrushAllPoints];
    NSArray <NSDictionary *>*points = trackDict[TFYSmearBrushPoints];
    NSString *name = trackDict[TFYSmearBrushName];
    NSBundle *bundle = trackDict[TFYBrushBundle];
    
    if (points.count > 0) {
        CALayer *layer = [[self class] createLayer];
        UIImage *image = [[self class] cacheImageWithName:name bundle:bundle];
        NSDictionary *pointDict = nil;
        for (NSInteger i=0; i<points.count; i++) {
            
            pointDict = points[i];
            
            CGPoint point = CGPointFromString(pointDict[TFYSmearBrushPoint]);
            
            CGFloat angle = [pointDict[TFYSmearBrushAngle] floatValue];
            
            UIColor *color = pointDict[TFYSmearBrushColor];
            
            CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:lineWidth point:point angle:angle color:color];
            
            [layer addSublayer:subLayer];
        }
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIImage *)cacheImageWithName:(NSString *)name bundle:(NSBundle *)bundle
{
    if (0==name.length) return nil;
    
    TFY_BrushCache *imageCache = [TFY_BrushCache share];
    UIImage *image = [imageCache objectForKey:name];
    if (image) {
        return image;
    }
    
    if (image == nil) {
        NSAssert(name!=nil, @"LFSmearBrush name is nil.");
        
        if (bundle) {
            /**
             framework内部加载
             */
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
        } else {
            /**
             framework外部加载
             */
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
        }
    }
    
    if (image) {
        @autoreleasepool {
            //redraw image using device context
            UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
            [image drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [imageCache setObject:image forKey:name];
    }
    
    return image;
}

+ (CALayer *)createLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

+ (CALayer *)createSubLayerWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth point:(CGPoint)point angle:(CGFloat)angle color:(UIColor *)color
{
    if (image == nil) return nil;
    
    CGFloat height = lineWidth;
    CGSize size = CGSizeMake(image.size.width*height/image.size.height, height);
    CGRect rect = CGRectMake(point.x-size.width/2, point.y-size.height/2, size.width, size.height);
    
    CALayer *subLayer = [CALayer layer];
    subLayer.frame = rect;
    subLayer.contentsScale = [UIScreen mainScreen].scale;
    subLayer.contentsGravity = kCAGravityResizeAspect;
    subLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    if (color) {
        CALayer *markLayer = [CALayer layer];
        markLayer.frame = rect;
        markLayer.contentsScale = [UIScreen mainScreen].scale;
        markLayer.backgroundColor = color.CGColor;
        subLayer.frame = markLayer.bounds;
        
        markLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
        markLayer.mask = subLayer;
        markLayer.masksToBounds = YES;
        
        return markLayer;
    }
    subLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
    
    return subLayer;
}


@end
