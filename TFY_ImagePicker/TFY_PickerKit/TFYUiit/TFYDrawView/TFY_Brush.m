//
//  TFY_Brush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"
#import <UIKit/UIKit.h>

NSString *const TFYBrushClassName = @"TFYBrushClassName";
NSString *const TFYBrushAllPoints = @"TFYBrushAllPoints";
NSString *const TFYBrushLineWidth = @"TFYBrushLineWidth";
NSString *const TFYBrushLevel = @"TFYBrushLevel";
NSString *const TFYBrushBundle = @"TFYBrushBundle";

const CGPoint TFYBrushPointNull = {INFINITY, INFINITY};

bool TFYBrushPointIsNull(CGPoint point)
{
    return isinf(point.x) || isinf(point.y);
}

CGPoint TFYBrushMidPoint(CGPoint p0, CGPoint p1) {
    if (TFYBrushPointIsNull(p0) || TFYBrushPointIsNull(p1)) {
        return CGPointZero;
    }
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

CGFloat TFYBrushDistancePoint(CGPoint p0, CGPoint p1) {
    if (TFYBrushPointIsNull(p0) || TFYBrushPointIsNull(p1)) {
        return 0;
    }
    return sqrt(pow(p0.x - p1.x, 2) + pow(p0.y - p1.y, 2));
}

CGFloat TFYBrushAngleBetweenPoint(CGPoint p0, CGPoint p1) {
    
    if (TFYBrushPointIsNull(p0) || TFYBrushPointIsNull(p1)) {
        return 0;
    }
    
    CGPoint p = CGPointMake(p0.x, p0.y+100);
    
    CGFloat x1 = p.x - p0.x;
    CGFloat y1 = p.y - p0.y;
    CGFloat x2 = p1.x - p0.x;
    CGFloat y2 = p1.y - p0.y;
    
    CGFloat x = x1 * x2 + y1 * y2;
    CGFloat y = x1 * y2 - x2 * y1;
    
    CGFloat angle = acos(x/sqrt(x*x+y*y));
    
    if (p1.x < p0.x) {
        angle = M_PI*2 - angle;
    }
    
    return (180.0 * angle / M_PI);
}

@interface TFY_Brush ()

@property (nonatomic, strong) NSMutableArray <NSString /*CGPoint*/*>*allPoints;
/** NSBundle 资源 */
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation TFY_Brush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = 5.f;
        _level = 0;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [self.allPoints addObject:NSStringFromCGPoint(point)];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    NSAssert(![self isMemberOfClass:[TFY_Brush class]], @"Use subclasses of TFY_Brush.");
    self.allPoints = [NSMutableArray array];
    if (TFYBrushPointIsNull(point)) {
        return nil;
    }
    [self.allPoints addObject:NSStringFromCGPoint(point)];
    return nil;
}

- (CGPoint)currentPoint
{
    NSString *pointStr = self.allPoints.lastObject;
    if (pointStr) {
        return CGPointFromString(pointStr);
    }
    return TFYBrushPointNull;
}

- (CGPoint)previousPoint
{
    if (self.allPoints.count > 1) {
        NSString *pointStr = [self.allPoints objectAtIndex:self.allPoints.count-2];
        return CGPointFromString(pointStr);
    }
    return TFYBrushPointNull;
}

- (NSDictionary *)allTracks
{
    if (self.allPoints.count) {
        NSMutableDictionary *trackDict = [NSMutableDictionary dictionaryWithDictionary:@{
            TFYBrushClassName:NSStringFromClass(self.class),
            TFYBrushAllPoints:self.allPoints,
            TFYBrushLineWidth:@(self.lineWidth),
            TFYBrushLevel:@(self.level)
        }];
        if (self.bundle) {
            [trackDict setObject:self.bundle forKey:TFYBrushBundle];
        }
        return trackDict;
    }
    return nil;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    NSString *className = trackDict[TFYBrushClassName];
    NSInteger level = [trackDict[TFYBrushLevel] integerValue];
    Class class = NSClassFromString(className);
    if (class && ![class isMemberOfClass:[self class]]) {
        CALayer *layer = [class drawLayerWithTrackDict:trackDict];
        layer.picker_level = level;
        return layer;
    }
    return nil;
}


@end
