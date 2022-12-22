//
//  TFY_StampBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_StampBrush.h"
#import "TFY_Brush+create.h"
#import "TFY_BrushCache.h"

NSString *const TFYStampBrushPatterns = @"TFYStampBrushPatterns";
NSString *const TFYStampBrushSpacing = @"TFYStampBrushSpacing";
NSString *const TFYStampBrushScale = @"TFYStampBrushScale";

@interface TFY_StampBrush ()
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) CALayer *layer;
@end

@implementation TFY_StampBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _spacing = 1.f;
        _scale = 4.f;
        _patterns = @[];
        self.level = 3;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    CGFloat distance = TFYBrushDistancePoint(self.currentPoint, point);
    CGFloat width = self.lineWidth*self.scale;
    if(distance == 0 || distance >= (width + self.spacing)){

        CGRect rect = CGRectMake(point.x-width/2, point.y-width/2, width, width);
        
        if ([self drawSubLayerInLayerAtRect:rect]) {
            
            [super addPoint:point];
        }
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    /**
     忽略第一个落点。可能是误操作，直到真正滑动时才记录点。
     */
    [super createDrawLayerWithPoint:TFYBrushPointNull];
    self.index = 0;
    
    CALayer *layer = [[self class] createLayer];
    layer.picker_level = self.level;
    self.layer = layer;
    
    return layer;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{TFYStampBrushPatterns:self.patterns,
                                                TFYStampBrushSpacing:@(self.spacing),
                                                TFYStampBrushScale:@(self.scale)
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[TFYBrushLineWidth] floatValue];
    NSArray <NSString *> *patterns = trackDict[TFYStampBrushPatterns];
//    CGFloat spacing = [trackDict[LFStampBrushSpacing] floatValue];
    CGFloat scale = [trackDict[TFYStampBrushScale] floatValue];
    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[TFYBrushAllPoints];
    NSBundle *bundle = trackDict[TFYBrushBundle];
    
    if (allPoints) {
        CGFloat width = lineWidth*scale;
        CALayer *layer = [[self class] createLayer];
        NSInteger index = 0;
        for (NSString *pointStr in allPoints) {
            CGPoint point = CGPointFromString(pointStr);
            
            UIImage *image = [[self class] cacheImageIndex:index patterns:patterns bundle:bundle];
            if (image == nil) continue;
            
            CGRect rect = CGRectMake(point.x-width/2, point.y-width/2, width, width);
            
            CALayer *subLayer = [[self class] createSubLayerWithImage:image rect:rect];
            
            [layer addSublayer:subLayer];
            
            index++;
        }
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIImage *)cacheImageIndex:(NSInteger)index patterns:(NSArray <NSString *>*)patterns bundle:(NSBundle *)bundle
{
    TFY_BrushCache *imageCache = [TFY_BrushCache share];
    NSInteger count = patterns.count;
    NSString *name = patterns[index%count];
    if (0==name.length) return nil;
    
    UIImage *image = nil;
    
    if (imageCache) {
        image = [imageCache objectForKey:name];
        if (image) {
            return image;
        }
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

+ (CALayer *)createSubLayerWithImage:(UIImage *)image rect:(CGRect)rect
{
    if (image == nil) return nil;
    
    CALayer *subLayer = [CALayer layer];
    subLayer.frame = rect;
    subLayer.contentsScale = [UIScreen mainScreen].scale;
    subLayer.contentsGravity = kCAGravityResizeAspect;
    subLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    return subLayer;
}

- (BOOL)drawSubLayerInLayerAtRect:(CGRect)rect
{
    UIImage *image = [[self class] cacheImageIndex:self.index patterns:self.patterns bundle:self.bundle];
    
    if (image == nil) return NO;
    
    CALayer *subLayer = [[self class] createSubLayerWithImage:image rect:rect];
    
    [self.layer addSublayer:subLayer];
    
    self.index++;
    
    return YES;
}

@end
