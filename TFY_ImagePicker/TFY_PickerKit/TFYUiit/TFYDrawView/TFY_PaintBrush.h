//
//  TFY_PaintBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const TFYPaintBrushLineColor;

@interface TFY_PaintBrush : TFY_Brush
/** 线颜色 默认红色 */
@property (nonatomic, strong, nullable) UIColor *lineColor;
@end

NS_ASSUME_NONNULL_END
