//
//  TFY_DropMainMenu.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import "TFY_DropItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DropMainMenu : UIView

/**
 自动收起 默认YES
 */
@property (nonatomic, assign, getter=isAutoDismiss) BOOL autoDismiss;

/**
 显示最大数量 默认4
 */
@property (nonatomic, assign) NSUInteger displayMaxNum;

/**
 显示位置（上下，默认TFYDropMainMenuDirectionBottom）
 */
@property (nonatomic, assign) TFYDropMainMenuDirection direction;

/**
 添加数据源
 */
- (void)addItem:(id <TFY_DropItemProtocol>)item;

/**
 数据源集合
 */
@property (nonatomic, readonly) NSArray<id <TFY_DropItemProtocol>> *items;

/**
 背景颜色
 */
@property (nonatomic, strong) UIColor *containerViewbackgroundColor;

#pragma mark - show

/**
 从坐标展示
 */
- (void)showFromPoint:(CGPoint)point;
/**
 从坐标展示，动画
 */
- (void)showFromPoint:(CGPoint)point animated:(BOOL)animated;

/**
 从视图边缘展示
 */
- (void)showInView:(UIView *)view;
/**
 从视图边缘展示，动画
 */
- (void)showInView:(UIView *)view animated:(BOOL)animated;

#pragma mark - hidden

/**
 隐藏菜单
 */
- (void)dismiss;
/**
 隐藏菜单，动画
 */
- (void)dismissWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
