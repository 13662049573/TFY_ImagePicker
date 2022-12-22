//
//  TFY_PickColorView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TFY_PickColorView;
@protocol TFYPickColorViewDelegate <NSObject>
@optional
- (void)picker_PickColorView:(TFY_PickColorView *)pickColorView didSelectColor:(UIColor *)color;
@end

@interface TFY_PickColorView : UIView
/** 显示选择颜色，默认colors第一个颜色。(如果有colors有相同颜色，取顺序最先的) */
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) NSUInteger index;
/** 是否需要动画（默认开启） */
@property (assign, nonatomic) BOOL animation;
@property (nonatomic, setter=setMagnifierMaskImage:) UIImage *magnifierMaskImage;
/** 代理 */
@property (weak, nonatomic) id<TFYPickColorViewDelegate>delegate;
/** 当前颜色 */
@property (copy, nonatomic) void(^pickColorEndBlock)(UIColor *color);
/** 数组颜色 */
@property (readonly, nonatomic) NSArray <UIColor *>*colors;

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray <UIColor *>*)colors;
@end

NS_ASSUME_NONNULL_END
