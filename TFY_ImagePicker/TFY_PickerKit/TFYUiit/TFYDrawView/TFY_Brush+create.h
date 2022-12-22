//
//  TFY_Brush+create.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Brush (create)

+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point;

+ (CAShapeLayer *)createShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor;

@end

@interface UIImage (TFY_BlurryBrush)
/**
 创建图案
 */
- (UIImage *)picker_patternGaussianImageWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler;
/**
 创建图案颜色
 */
- (UIColor *)picker_patternGaussianColorWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler;

@end

NS_ASSUME_NONNULL_END
