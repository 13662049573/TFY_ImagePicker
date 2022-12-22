//
//  UIView+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, OscillatoryAnimationType) {
    OscillatoryAnimationToBigger,
    OscillatoryAnimationToSmaller,
};

@interface UIView (picker)
@property (nonatomic, assign) CGFloat picker_x;
@property (nonatomic, assign) CGFloat picker_y;
@property (nonatomic, assign) CGFloat picker_centerX;
@property (nonatomic, assign) CGFloat picker_centerY;
@property (nonatomic, assign) CGFloat picker_width;
@property (nonatomic, assign) CGFloat picker_height;
@property (nonatomic, assign) CGSize picker_size;
@property (nonatomic, assign) CGPoint picker_origin;

/** 截取图层为图片 */
- (UIImage *)picker_captureImage;
/** 截图图层部分为图片 */
- (UIImage *)picker_captureImageAtFrame:(CGRect)rect;
/** layer坐标颜色 */
- (UIColor *)picker_colorOfPoint:(CGPoint)point;
/** 设置弧边 */
- (void)picker_setCornerRadius:(float)cornerRadius;
/** 设置弧边，需要手动设置masksToBounds */
- (void)picker_setCornerRadiusWithoutMasks:(float)cornerRadius;
/** 设置阴影（方） */
- (void)picker_updateSquareShadow;
/** 设置阴影（圆） */
- (void)picker_updateCircleShadow;

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(OscillatoryAnimationType)type;

@end

NS_ASSUME_NONNULL_END
