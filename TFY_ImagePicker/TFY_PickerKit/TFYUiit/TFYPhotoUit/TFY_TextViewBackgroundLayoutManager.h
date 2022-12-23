//
//  TFY_TextViewBackgroundLayoutManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_CGContextDrawTextBackground.h"
NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextViewBackgroundLayoutManager : NSLayoutManager
/** 文字背景颜色 */
@property (nonatomic, strong, nullable) UIColor *usedColor;
/** 文字背景类型 */
@property (nonatomic, assign) TFYCGContextDrawTextBackgroundType type;
/** 圆角度数 0.18 */
@property (nonatomic, assign) CGFloat radius;
/** 所有的绘制位置集合 CGRect */
@property (nonatomic, readonly) NSArray <NSValue *>*allUsedRects;
/** 绘制数据，交由TFY_CGContextDrawTextBackground使用 */
@property (nonatomic, strong) NSDictionary *layoutData;
@end

NS_ASSUME_NONNULL_END
