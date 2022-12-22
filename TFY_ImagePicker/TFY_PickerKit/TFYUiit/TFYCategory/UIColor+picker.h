//
//  UIColor+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (picker)
+ (nonnull UIColor *)picker_colorTransformFrom:(nonnull UIColor *)fromColor to:(nonnull UIColor *)toColor progress:(CGFloat)progress;

- (BOOL)picker_isEqualToColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
