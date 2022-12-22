//
//  TFY_GridLayer.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_GridLayer : CAShapeLayer
/** 圆形 */
@property (nonatomic, assign, getter=isCircle) BOOL circle;

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

//@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@end

NS_ASSUME_NONNULL_END
