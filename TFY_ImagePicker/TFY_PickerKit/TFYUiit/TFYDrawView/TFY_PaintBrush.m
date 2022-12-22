//
//  TFY_PaintBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_PaintBrush.h"
#import "TFY_Brush+create.h"

NSString *const TFYPaintBrushLineColor = @"TFYPaintBrushLineColor";

@interface TFY_PaintBrush ()
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, weak) CAShapeLayer *layer;
@end

@implementation TFY_PaintBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineColor = [UIColor redColor];
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    if (self.path) {
        CGPoint midPoint = TFYBrushMidPoint(self.previousPoint, point);
        // 使用二次曲线方程式
        [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousPoint];
        self.layer.path = self.path.CGPath;
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    if (self.lineColor) {
        [super createDrawLayerWithPoint:point];
        /**
         首次创建UIBezierPath
         */
        self.path = [[self class] createBezierPathWithPoint:point];
        
        CAShapeLayer *layer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth strokeColor:self.lineColor];
        layer.picker_level = self.level;
        self.layer = layer;
        
        return layer;
    }
    return nil;
}
- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.lineColor) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{TFYPaintBrushLineColor:self.lineColor}];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[TFYBrushLineWidth] floatValue];
    UIColor *lineColor = trackDict[TFYPaintBrushLineColor];
    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[TFYBrushAllPoints];
    
    if (allPoints) {
        CGPoint previousPoint = CGPointFromString(allPoints.firstObject);
        UIBezierPath *path = [[self class] createBezierPathWithPoint:previousPoint];
        
        for (NSInteger i=1; i<allPoints.count; i++) {
            
            CGPoint point = CGPointFromString(allPoints[i]);
            
            CGPoint midPoint = TFYBrushMidPoint(previousPoint, point);
            // 使用二次曲线方程式
            [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            previousPoint = point;
        }
        return [[self class] createShapeLayerWithPath:path lineWidth:lineWidth strokeColor:lineColor];
    }
    return nil;
}


@end
