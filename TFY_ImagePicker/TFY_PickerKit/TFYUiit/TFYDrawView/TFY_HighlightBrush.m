//
//  TFY_HighlightBrush.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_HighlightBrush.h"
#import "TFY_Brush+create.h"

NSString *const TFYHighlightBrushLineColor = @"TFYHighlightBrushLineColor";
NSString *const TFYHighlightBrushOuterLineWidth = @"TFYHighlightBrushOuterLineWidth";
NSString *const TFYHighlightBrushOuterLineColor = @"TFYHighlightBrushOuterLineColor";

CGFloat const TFYHighlightBrushAlpha = 0.6;

@interface TFY_HighlightBrush ()
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, weak) CAShapeLayer *innerLayer;
@property (nonatomic, weak) CAShapeLayer *outerLayer;
@end

@implementation TFY_HighlightBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineColor = [UIColor whiteColor];
        _outerLineColor = [UIColor redColor];
        _outerLineWidth = self.lineWidth/1.6;
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
        
        self.outerLayer.path = self.path.CGPath;
        self.innerLayer.path = self.path.CGPath;
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    if (self.lineColor && self.outerLineColor) {
        [super createDrawLayerWithPoint:point];
        
        /**
         首次创建UIBezierPath
         */
        self.path = [[self class] createBezierPathWithPoint:point];
        
        CALayer *layer = [CALayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.picker_level = self.level;
        self.layer = layer;
        
        CAShapeLayer *outerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth+self.outerLineWidth*2 strokeColor:self.outerLineColor];
        [layer addSublayer:outerLayer];
        self.outerLayer = outerLayer;
        
        CAShapeLayer *innerLayer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth strokeColor:self.lineColor];
        [layer addSublayer:innerLayer];
        self.innerLayer = innerLayer;
        
        return layer;
    }
    return nil;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.lineColor && self.outerLineColor) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{TFYHighlightBrushLineColor:self.lineColor,
                                                TFYHighlightBrushOuterLineColor:self.outerLineColor,
                                                TFYHighlightBrushOuterLineWidth:@(self.outerLineWidth)
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[TFYBrushLineWidth] floatValue];
    UIColor *lineColor = trackDict[TFYHighlightBrushLineColor];
    CGFloat outerLineWidth = [trackDict[TFYHighlightBrushOuterLineWidth] floatValue];
    UIColor *outerLineColor = trackDict[TFYHighlightBrushOuterLineColor];
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
        CALayer *layer = [CALayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        
        CAShapeLayer *outerLayer = [[self class] createShapeLayerWithPath:path lineWidth:lineWidth+outerLineWidth*2 strokeColor:outerLineColor];
        [layer addSublayer:outerLayer];
        
        CAShapeLayer *innerLayer = [[self class] createShapeLayerWithPath:path lineWidth:lineWidth strokeColor:lineColor];
        [layer addSublayer:innerLayer];
        
        return layer;
    }
    return nil;
}

@end
