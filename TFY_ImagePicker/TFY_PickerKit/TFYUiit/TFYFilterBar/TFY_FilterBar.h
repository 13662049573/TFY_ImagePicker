//
//  TFY_FilterBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

extern CGFloat const TFY_FilterBar_MAX_WIDTH;

NS_ASSUME_NONNULL_BEGIN

@class TFY_FilterBar;

@protocol TFYFilterBarDelegate <NSObject>

- (void)picker_filterBar:(TFY_FilterBar *)picker_filterBar didSelectImage:(UIImage *)image effectType:(NSInteger)effectType;

@end

@protocol TFYFilterBarDataSource <NSObject>

- (UIImage *)picker_async_filterBarImageForEffectType:(NSInteger)type;

- (NSString *)picker_filterBarNameForEffectType:(NSInteger)type;

@end


@interface TFY_FilterBar : UIView
/** 默认选择图片类型 */
@property (nonatomic, readonly) NSInteger defalutEffectType;
/** 默认字体和框框颜色 */
@property (nonatomic, strong) UIColor *defaultColor;
/** 已选字体和框框颜色 */
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, weak) id<TFYFilterBarDelegate> delegate;

@property (nonatomic, weak) id<TFYFilterBarDataSource>dataSource;

- (instancetype)initWithFrame:(CGRect)frame defalutEffectType:(NSInteger)defalutEffectType dataSource:(NSArray<NSNumber *> *)dataSource;

@end

NS_ASSUME_NONNULL_END
