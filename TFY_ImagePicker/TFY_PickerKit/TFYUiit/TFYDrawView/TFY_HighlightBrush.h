//
//  TFY_HighlightBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const TFYHighlightBrushLineColor;
OBJC_EXTERN NSString *const TFYHighlightBrushOuterLineWidth;
OBJC_EXTERN NSString *const TFYHighlightBrushOuterLineColor;

@interface TFY_HighlightBrush : TFY_Brush
/** 外边颜色 默认红色 */
@property (nonatomic, strong) UIColor *outerLineColor;
/** 外边线粗（一边） 默认3 */
@property (nonatomic, assign) CGFloat outerLineWidth;
/** 线颜色 默认白色 */
@property (nonatomic, strong) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
