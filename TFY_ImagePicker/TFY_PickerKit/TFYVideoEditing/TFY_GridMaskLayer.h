//
//  TFY_GridMaskLayer.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_GridMaskLayer : CAShapeLayer
/** 遮罩颜色 */
@property (nonatomic, assign) CGColorRef maskColor;
/** 圆形 */
@property (nonatomic, assign, getter=isCircle) BOOL circle;
/** 遮罩范围 */
@property (nonatomic, assign, setter=setMaskRect:) CGRect maskRect;
- (void)setMaskRect:(CGRect)maskRect animated:(BOOL)animated;
/** 取消遮罩 */
- (void)clearMask;
- (void)clearMaskWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
