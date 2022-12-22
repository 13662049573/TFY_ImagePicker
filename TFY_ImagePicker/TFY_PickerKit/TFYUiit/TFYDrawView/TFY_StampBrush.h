//
//  TFY_StampBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const TFYStampBrushPatterns;
OBJC_EXTERN NSString *const TFYStampBrushSpacing;
OBJC_EXTERN NSString *const TFYStampBrushScale;

@interface TFY_StampBrush : TFY_Brush
/** 图案间隔 默认1 */
@property (nonatomic, assign) CGFloat spacing;
/** 线粗的缩放系数（图案大小） 默认4 */
@property (nonatomic, assign) CGFloat scale;
/** 印章图案名称 */
@property (nonatomic, strong) NSArray <NSString *> *patterns;

@end

NS_ASSUME_NONNULL_END
